import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'models.dart';

class OcrResult {
  const OcrResult({
    required this.lines,
    required this.width,
    required this.height,
    required this.imagePath,
  });

  final List<OcrLine> lines;
  final double width;
  final double height;

  /// Pfad des (richtig gedrehten) Originalbilds.
  final String imagePath;
}

/// Zeilen unter dieser Sicherheit werden einzeln nachgelesen.
const double recheckBelowConfidence = 0.6;
const int maxRechecks = 80;

class _Prepared {
  _Prepared(this.width, this.height, this.path);
  final int width, height;
  final String path;
}

/// EXIF-Drehung anwenden und als JPEG speichern (Hintergrund-Isolate).
Future<_Prepared> _prepare((Uint8List, String) args) async {
  final (bytes, dir) = args;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Bild konnte nicht gelesen werden');
  final upright = img.bakeOrientation(decoded);
  final path = p.join(dir, 'scan_${DateTime.now().microsecondsSinceEpoch}.jpg');
  await File(path).writeAsBytes(img.encodeJpg(upright, quality: 95));
  return _Prepared(upright.width, upright.height, path);
}

/// Ausschnitt einer Zeile für das Nachlesen.
class CropSpec {
  const CropSpec(this.corners);
  final List<Pt> corners;
}

/// Schneidet jede Zeile aus und dreht sie so, dass die Schrift waagerecht
/// liegt – einmal in der von ML Kit angenommenen Leserichtung (a) und einmal
/// um 180° gedreht (b). Gibt die Dateipfade zurück.
Future<List<(String, String)>> _cropLines((String, List<List<double>>, String) args) async {
  final (path, specs, dir) = args;
  final image = img.decodeJpg(await File(path).readAsBytes());
  if (image == null) return const [];
  final out = <(String, String)>[];
  final stamp = DateTime.now().microsecondsSinceEpoch;
  for (var i = 0; i < specs.length; i++) {
    final c = specs[i]; // x0,y0,x1,y1,x2,y2,x3,y3
    final p0 = Pt(c[0], c[1]), p1 = Pt(c[2], c[3]), p3 = Pt(c[6], c[7]);
    final dir0 = p1 - p0;
    final th = (p3 - p0).length;
    final angle = math.atan2(dir0.y, dir0.x) * 180 / math.pi;
    final pad = th * 0.6;
    final xs = [c[0], c[2], c[4], c[6]], ys = [c[1], c[3], c[5], c[7]];
    final left = math.max(0, xs.reduce(math.min) - pad).floor();
    final top = math.max(0, ys.reduce(math.min) - pad).floor();
    final right = math.min(image.width.toDouble(), xs.reduce(math.max) + pad).ceil();
    final bottom = math.min(image.height.toDouble(), ys.reduce(math.max) + pad).ceil();
    if (right - left < 8 || bottom - top < 8) {
      out.add(('', ''));
      continue;
    }
    final crop = img.copyCrop(image, x: left, y: top, width: right - left, height: bottom - top);
    // copyRotate dreht im Uhrzeigersinn; -angle legt die Schrift waagerecht.
    final a = img.copyRotate(crop, angle: -angle, interpolation: img.Interpolation.linear);
    final b = img.copyRotate(a, angle: 180);
    final pa = p.join(dir, 'crop_${stamp}_${i}_a.jpg');
    final pb = p.join(dir, 'crop_${stamp}_${i}_b.jpg');
    await File(pa).writeAsBytes(img.encodeJpg(a, quality: 92));
    await File(pb).writeAsBytes(img.encodeJpg(b, quality: 92));
    out.add((pa, pb));
  }
  return out;
}

/// Texterkennung mit Google ML Kit (auf dem Gerät).
///
/// 1. Ein Durchlauf über das ganze Foto. ML Kit erkennt auch senkrechte
///    Schrift, legt die Leserichtung aber offenbar für größere Bereiche fest –
///    Titel, die von unten nach oben laufen, kommen dann „auf dem Kopf“ als
///    Buchstabensalat mit geringer Sicherheit heraus.
/// 2. Jede unsichere Zeile wird deshalb einzeln ausgeschnitten und in beiden
///    Leserichtungen nachgelesen; die sicherere Lesung gewinnt.
class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrResult> recognize(
    Uint8List bytes, {
    void Function(String step)? onStep,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final scans = Directory(p.join(dir.path, 'scans'));
    await scans.create(recursive: true);
    final tmp = await getTemporaryDirectory();
    onStep?.call('prepare');
    final prepared = await compute(_prepare, (bytes, scans.path));
    final w = prepared.width.toDouble(), h = prepared.height.toDouble();

    onStep?.call('ocr');
    final result = await _recognizer.processImage(InputImage.fromFilePath(prepared.path));
    var lines = <OcrLine>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        final r = line.boundingBox;
        final corners = line.cornerPoints.length == 4
            ? [for (final c in line.cornerPoints) Pt(c.x.toDouble(), c.y.toDouble())]
            : null;
        lines.add(OcrLine(
          text: line.text,
          box: Box(r.left, r.top, r.right, r.bottom),
          rotation: ScanRotation.none,
          confidence: line.confidence,
          corners: corners,
        ));
      }
    }

    // Unsichere Zeilen nachlesen.
    final candidates = [
      for (var i = 0; i < lines.length; i++)
        if ((lines[i].confidence ?? 0) < recheckBelowConfidence) i,
    ]..sort((a, b) => (lines[a].confidence ?? 0).compareTo(lines[b].confidence ?? 0));
    final chosen = candidates.take(maxRechecks).toList();
    if (chosen.isNotEmpty) {
      onStep?.call('recheck');
      final specs = [
        for (final i in chosen) [for (final c in lines[i].corners) ...[c.x, c.y]],
      ];
      final crops = await compute(_cropLines, (prepared.path, specs, tmp.path));
      for (var k = 0; k < chosen.length && k < crops.length; k++) {
        final (pa, pb) = crops[k];
        if (pa.isEmpty) continue;
        final original = lines[chosen[k]];
        var best = (text: original.text, conf: original.confidence ?? 0, flipped: false);
        for (final (path, flipped) in [(pa, false), (pb, true)]) {
          final read = await _readCrop(path);
          if (read != null && read.conf > best.conf + 0.05) {
            best = (text: read.text, conf: read.conf, flipped: flipped);
          }
          await File(path).delete().catchError((_) => File(path));
        }
        if (best.text != original.text) {
          // Umgedreht gelesen: Leserichtung der Eckpunkte umkehren.
          final c = original.corners;
          lines[chosen[k]] = OcrLine(
            text: best.text,
            box: original.box,
            rotation: original.rotation,
            confidence: best.conf,
            corners: best.flipped ? [c[2], c[3], c[0], c[1]] : c,
          );
        }
      }
    }
    return OcrResult(lines: lines, width: w, height: h, imagePath: prepared.path);
  }

  /// Liest einen Ausschnitt; alle Zeilen von links nach rechts zusammengefügt.
  Future<({String text, double conf})?> _readCrop(String path) async {
    final r = await _recognizer.processImage(InputImage.fromFilePath(path));
    final ls = [for (final b in r.blocks) ...b.lines]
      ..sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
    if (ls.isEmpty) return null;
    // Nur die größte Zeile (die nachzulesende) und gleich hohe daneben.
    final maxH = ls.map((l) => l.boundingBox.height).reduce(math.max);
    final main = ls.where((l) => l.boundingBox.height >= maxH * 0.6).toList();
    final text = main.map((l) => l.text).join(' ');
    final confs = main.map((l) => l.confidence ?? 0).toList();
    final conf = confs.reduce((a, b) => a + b) / confs.length;
    return (text: text, conf: conf);
  }

  Future<void> dispose() => _recognizer.close();
}

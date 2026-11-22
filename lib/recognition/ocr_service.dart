import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'blocklist.dart';
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
const double recheckBelowConfidence = 0.5;
const int maxRechecks = 40;

/// Ausschnitte werden auf diese Schrifthöhe verkleinert (spart Zeit).
const double recheckTargetThickness = 56;

class _Prepared {
  _Prepared(this.width, this.height, this.path, this.rotated);
  final int width, height;
  final String path;

  /// Um ±90° gedrehte Kopien (temporär).
  final Map<ScanRotation, String> rotated;
}

/// EXIF-Drehung anwenden, als JPEG speichern und ±90° gedrehte Kopien
/// anlegen (Hintergrund-Isolate).
Future<_Prepared> _prepare((Uint8List, String, String) args) async {
  final (bytes, dir, tmp) = args;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Bild konnte nicht gelesen werden');
  final upright = img.bakeOrientation(decoded);
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final path = p.join(dir, 'scan_$stamp.jpg');
  await File(path).writeAsBytes(img.encodeJpg(upright, quality: 95));
  final rotated = <ScanRotation, String>{};
  for (final (r, angle) in [(ScanRotation.cw90, 90), (ScanRotation.ccw90, -90)]) {
    final rp = p.join(tmp, 'scan_${stamp}_${r.name}.jpg');
    await File(rp).writeAsBytes(img.encodeJpg(img.copyRotate(upright, angle: angle), quality: 92));
    rotated[r] = rp;
  }
  return _Prepared(upright.width, upright.height, path, rotated);
}

/// Ausschnitt einer Zeile für das Nachlesen.
class CropSpec {
  const CropSpec(this.corners);
  final List<Pt> corners;
}

/// Schneidet jede Zeile aus und dreht sie so, dass die Schrift waagerecht
/// liegt – entgegen der von ML Kit angenommenen Leserichtung (die ja zu
/// einer unsicheren Lesung geführt hat). Gibt die Dateipfade zurück.
Future<List<String>> _cropLines((String, List<List<double>>, String) args) async {
  final (path, specs, dir) = args;
  final image = img.decodeJpg(await File(path).readAsBytes());
  if (image == null) return const [];
  final out = <String>[];
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
      out.add('');
      continue;
    }
    var crop = img.copyCrop(image, x: left, y: top, width: right - left, height: bottom - top);
    if (th > recheckTargetThickness * 1.3) {
      final f = recheckTargetThickness / th;
      crop = img.copyResize(crop, width: math.max(8, (crop.width * f).round()),
          interpolation: img.Interpolation.average);
    }
    // copyRotate dreht im Uhrzeigersinn; 180-angle legt die Schrift
    // waagerecht, aber umgekehrt zur bisherigen Leserichtung.
    final b = img.copyRotate(crop, angle: 180 - angle, interpolation: img.Interpolation.linear);
    final pb = p.join(dir, 'crop_${stamp}_$i.jpg');
    await File(pb).writeAsBytes(img.encodeJpg(b, quality: 92));
    out.add(pb);
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
    final prepared = await compute(_prepare, (bytes, scans.path, tmp.path));
    final w = prepared.width.toDouble(), h = prepared.height.toDouble();

    // Drei Durchläufe: ML Kit findet in den gedrehten Bildern zusätzliche
    // Zeilen (gemessen 22.11.2026), auch wenn es Schrift meist selbst dreht.
    final lines = <OcrLine>[];
    for (final rotation in ScanRotation.values) {
      onStep?.call(rotation == ScanRotation.none ? 'ocr' : 'ocr2');
      final path = rotation == ScanRotation.none ? prepared.path : prepared.rotated[rotation]!;
      final result = await _recognizer.processImage(InputImage.fromFilePath(path));
      for (final block in result.blocks) {
        for (final line in block.lines) {
          final r = line.boundingBox;
          final corners = line.cornerPoints.length == 4
              ? [
                  for (final c in line.cornerPoints)
                    mapPointFromRotated(Pt(c.x.toDouble(), c.y.toDouble()), rotation, w, h),
                ]
              : null;
          lines.add(OcrLine(
            text: line.text,
            box: mapFromRotated(Box(r.left, r.top, r.right, r.bottom), rotation, w, h),
            rotation: rotation,
            confidence: line.confidence,
            corners: corners,
          ));
        }
      }
      if (rotation != ScanRotation.none) {
        await File(path).delete().catchError((_) => File(path));
      }
    }

    // Unsichere Zeilen nachlesen (Logos und Nummern nicht).
    final candidates = [
      for (var i = 0; i < lines.length; i++)
        if ((lines[i].confidence ?? 0) < recheckBelowConfidence &&
            lines[i].isVertical &&
            cleanLine(lines[i].text) != null)
          i,
    ]..sort((a, b) => (lines[a].confidence ?? 0).compareTo(lines[b].confidence ?? 0));
    final chosen = candidates.take(maxRechecks).toList();
    if (chosen.isNotEmpty) {
      onStep?.call('recheck');
      final specs = [
        for (final i in chosen) [for (final c in lines[i].corners) ...[c.x, c.y]],
      ];
      final crops = await compute(_cropLines, (prepared.path, specs, tmp.path));
      for (var k = 0; k < chosen.length && k < crops.length; k++) {
        final path = crops[k];
        if (path.isEmpty) continue;
        final original = lines[chosen[k]];
        final read = await _readCrop(path);
        await File(path).delete().catchError((_) => File(path));
        if (read != null && read.conf > (original.confidence ?? 0) + 0.05) {
          // Umgedreht gelesen: Leserichtung der Eckpunkte umkehren.
          final c = original.corners;
          lines[chosen[k]] = OcrLine(
            text: read.text,
            box: original.box,
            rotation: original.rotation,
            confidence: read.conf,
            corners: [c[2], c[3], c[0], c[1]],
          );
        }
      }
    }
    return OcrResult(lines: lines, width: w, height: h, imagePath: prepared.path);
  }

  /// Liest einen Ausschnitt. Es zählen nur Zeilen auf der Mittellinie des
  /// Ausschnitts (dort liegt die nachzulesende Zeile), von links nach rechts.
  Future<({String text, double conf})?> _readCrop(String path) async {
    final r = await _recognizer.processImage(InputImage.fromFilePath(path));
    final size = await decodeImageFromList(await File(path).readAsBytes());
    final midY = size.height / 2;
    final ls = [
      for (final b in r.blocks)
        for (final l in b.lines)
          if (l.boundingBox.top <= midY && l.boundingBox.bottom >= midY) l,
    ]..sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
    size.dispose();
    if (ls.isEmpty) return null;
    final text = ls.map((l) => l.text).join(' ');
    final confs = ls.map((l) => l.confidence ?? 0).toList();
    final conf = confs.reduce((a, b) => a + b) / confs.length;
    return (text: text, conf: conf);
  }

  Future<void> dispose() => _recognizer.close();
}

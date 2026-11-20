import 'dart:io';
import 'dart:typed_data';

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

class _Prepared {
  _Prepared(this.width, this.height, this.paths);
  final int width, height;
  final Map<ScanRotation, String> paths;
}

/// Bereitet das Foto vor (EXIF-Drehung anwenden, ±90° gedrehte Kopien) –
/// läuft in einem Hintergrund-Isolate, weil große Fotos Sekunden brauchen.
Future<_Prepared> _prepare((Uint8List, String) args) async {
  final (bytes, dir) = args;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Bild konnte nicht gelesen werden');
  final upright = img.bakeOrientation(decoded);
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final paths = <ScanRotation, String>{};
  Future<void> save(ScanRotation r, img.Image im) async {
    final path = p.join(dir, 'scan_${stamp}_${r.name}.jpg');
    await File(path).writeAsBytes(img.encodeJpg(im, quality: 95));
    paths[r] = path;
  }

  await save(ScanRotation.none, upright);
  await save(ScanRotation.cw90, img.copyRotate(upright, angle: 90));
  await save(ScanRotation.ccw90, img.copyRotate(upright, angle: -90));
  return _Prepared(upright.width, upright.height, paths);
}

/// Texterkennung mit Google ML Kit (offline, auf dem Gerät).
///
/// Läuft dreimal: auf dem Original und auf den um ±90° gedrehten Bildern,
/// weil die Schrift auf Hüllenrücken senkrecht steht. Alle Koordinaten
/// werden auf das Original zurückgerechnet.
class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrResult> recognize(
    Uint8List bytes, {
    void Function(String step)? onStep,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final scans = Directory(p.join(dir.path, 'scans'));
    await scans.create(recursive: true);
    onStep?.call('prepare');
    final prepared = await compute(_prepare, (bytes, scans.path));
    final w = prepared.width.toDouble(), h = prepared.height.toDouble();

    final lines = <OcrLine>[];
    for (final rotation in ScanRotation.values) {
      onStep?.call(rotation.name);
      final path = prepared.paths[rotation]!;
      final result =
          await _recognizer.processImage(InputImage.fromFilePath(path));
      for (final block in result.blocks) {
        for (final line in block.lines) {
          final r = line.boundingBox;
          final box = mapFromRotated(
            Box(r.left, r.top, r.right, r.bottom),
            rotation,
            w,
            h,
          );
          lines.add(OcrLine(
            text: line.text,
            box: box,
            rotation: rotation,
            confidence: line.confidence,
          ));
        }
      }
      if (rotation != ScanRotation.none) {
        // Gedrehte Hilfsbilder werden nicht mehr gebraucht.
        await File(path).delete().catchError((_) => File(path));
      }
    }
    return OcrResult(
      lines: lines,
      width: w,
      height: h,
      imagePath: prepared.paths[ScanRotation.none]!,
    );
  }

  Future<void> dispose() => _recognizer.close();
}

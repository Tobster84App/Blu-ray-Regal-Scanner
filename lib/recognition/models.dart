import 'dart:math' as math;

import 'format_detector.dart';

/// Rechteck in Bildpixeln des Originalfotos (unabhängig von Flutter, damit
/// die Logik ohne Gerät testbar ist).
class Box {
  const Box(this.left, this.top, this.right, this.bottom);

  final double left, top, right, bottom;

  double get width => right - left;
  double get height => bottom - top;
  double get centerX => (left + right) / 2;
  double get area => math.max(0, width) * math.max(0, height);

  /// Dünne Seite – bei Text etwa die Schrifthöhe.
  double get thickness => math.min(width, height);

  Box union(Box o) => Box(
        math.min(left, o.left),
        math.min(top, o.top),
        math.max(right, o.right),
        math.max(bottom, o.bottom),
      );

  double intersectionArea(Box o) {
    final w = math.min(right, o.right) - math.max(left, o.left);
    final h = math.min(bottom, o.bottom) - math.max(top, o.top);
    if (w <= 0 || h <= 0) return 0;
    return w * h;
  }

  double iou(Box o) {
    final i = intersectionArea(o);
    if (i == 0) return 0;
    return i / (area + o.area - i);
  }

  Box inflate(double dx, double dy) =>
      Box(left - dx, top - dy, right + dx, bottom + dy);

  Map<String, double> toJson() =>
      {'l': left, 't': top, 'r': right, 'b': bottom};

  static Box fromJson(Map<String, dynamic> j) => Box(
        (j['l'] as num).toDouble(),
        (j['t'] as num).toDouble(),
        (j['r'] as num).toDouble(),
        (j['b'] as num).toDouble(),
      );

  @override
  String toString() =>
      'Box(${left.round()},${top.round()},${right.round()},${bottom.round()})';
}

/// Drehung, mit der ML Kit das Bild gelesen hat.
enum ScanRotation { none, cw90, ccw90 }

/// Eine von ML Kit erkannte Textzeile, Koordinaten im Originalbild.
class OcrLine {
  const OcrLine({
    required this.text,
    required this.box,
    required this.rotation,
    this.confidence,
  });

  final String text;
  final Box box;
  final ScanRotation rotation;
  final double? confidence;

  /// Senkrecht im Originalbild (typisch für Hüllenrücken).
  bool get isVertical => box.height > box.width * 1.3;

  @override
  String toString() => 'OcrLine("$text", $box, $rotation)';
}

/// Rechnet ein Rechteck aus einem gedrehten Bild auf das Original zurück.
/// [origW]/[origH] sind die Maße des ORIGINALS.
Box mapFromRotated(Box r, ScanRotation rotation, double origW, double origH) {
  switch (rotation) {
    case ScanRotation.none:
      return r;
    case ScanRotation.cw90:
      // Original (x,y) -> gedreht (H - y, x)  =>  x = y', y = H - x'
      return Box(r.top, origH - r.right, r.bottom, origH - r.left);
    case ScanRotation.ccw90:
      // Original (x,y) -> gedreht (y, W - x)  =>  x = W - y', y = x'
      return Box(origW - r.bottom, r.left, origW - r.top, r.right);
  }
}

/// Eine Hülle (senkrechter Streifen) mit ihren Textzeilen.
class Spine {
  Spine({
    required this.box,
    required this.lines,
    required this.cleanedLines,
    required this.format,
    required this.cutOff,
  });

  final Box box;
  final List<OcrLine> lines;

  /// Zeilen nach Sperrliste (leere entfernt), Reihenfolge wie [lines].
  final List<String> cleanedLines;
  final DiscFormat? format;

  /// Am Bildrand angeschnitten.
  final bool cutOff;

  String get rawText => lines.map((l) => l.text).join(' | ');
  String get cleanedText => cleanedLines.join(' ');
  bool get hasText => cleanedLines.isNotEmpty;
}

import 'dart:math' as math;

import 'format_detector.dart';

/// Punkt in Bildpixeln des Originalfotos.
class Pt {
  const Pt(this.x, this.y);
  final double x, y;
  Pt operator +(Pt o) => Pt(x + o.x, y + o.y);
  Pt operator -(Pt o) => Pt(x - o.x, y - o.y);
  Pt operator *(double f) => Pt(x * f, y * f);
  double dot(Pt o) => x * o.x + y * o.y;
  double get length => math.sqrt(x * x + y * y);
  Pt get unit => length == 0 ? const Pt(0, 1) : this * (1 / length);
  Map<String, double> toJson() => {'x': x, 'y': y};
  @override
  String toString() => '(${x.round()},${y.round()})';
}

/// Liegt [p] im (konvexen oder einfachen) Vieleck [poly]?
bool pointInPolygon(Pt p, List<Pt> poly) {
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final a = poly[i], b = poly[j];
    if ((a.y > p.y) != (b.y > p.y) &&
        p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x) {
      inside = !inside;
    }
  }
  return inside;
}

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

  List<Pt> get corners =>
      [Pt(left, top), Pt(right, top), Pt(right, bottom), Pt(left, bottom)];

  static Box around(Iterable<Pt> pts) {
    var l = double.infinity, t = double.infinity;
    var r = -double.infinity, b = -double.infinity;
    for (final p in pts) {
      l = math.min(l, p.x);
      t = math.min(t, p.y);
      r = math.max(r, p.x);
      b = math.max(b, p.y);
    }
    return Box(l, t, r, b);
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
///
/// [corners] sind die vier Eckpunkte in Leserichtung (oben links, oben
/// rechts, unten rechts, unten links – bezogen auf die Schrift). Damit lassen
/// sich auch schräg stehende Hüllen richtig erfassen.
class OcrLine {
  OcrLine({
    required this.text,
    required this.box,
    required this.rotation,
    this.confidence,
    List<Pt>? corners,
  }) : corners = corners ?? _defaultCorners(box, rotation);

  final String text;
  final Box box;
  final ScanRotation rotation;
  final double? confidence;
  final List<Pt> corners;

  /// Andere Lesungen derselben Zeile (aus weiteren Durchläufen).
  final List<String> alternatives = [];

  /// Ohne Eckpunkte (Tests): Leserichtung aus der Drehung ableiten.
  static List<Pt> _defaultCorners(Box b, ScanRotation r) {
    final c = b.corners; // tl, tr, br, bl
    switch (r) {
      case ScanRotation.none:
        return b.height > b.width * 1.3 ? [c[0], c[3], c[2], c[1]] : c;
      case ScanRotation.cw90:
        // im Uhrzeigersinn gedrehtes Bild gelesen: Schrift läuft im
        // Original von unten nach oben
        return [c[3], c[0], c[1], c[2]];
      case ScanRotation.ccw90:
        // Schrift läuft im Original von oben nach unten
        return [c[1], c[2], c[3], c[0]];
    }
  }

  Pt get center => (corners[0] + corners[1] + corners[2] + corners[3]) * 0.25;

  /// Richtung der Schrift (Einheitsvektor).
  Pt get direction => (corners[1] - corners[0]).unit;

  /// Länge der Zeile entlang der Schrift.
  double get length => (corners[1] - corners[0]).length;

  /// Schrifthöhe (quer zur Schrift).
  double get thickness =>
      math.max(1, ((corners[3] - corners[0]).length + (corners[2] - corners[1]).length) / 2);

  /// Senkrecht im Originalbild (typisch für Hüllenrücken), auch wenn leicht
  /// schräg.
  bool get isVertical {
    final d = direction;
    return d.y.abs() > d.x.abs();
  }

  /// Neigung einer senkrechten Zeile: x-Änderung pro Pixel nach unten.
  double get tilt {
    var d = direction;
    if (d.y < 0) d = d * -1;
    return d.y.abs() < 1e-6 ? 0 : d.x / d.y;
  }

  @override
  String toString() => 'OcrLine("$text", $box, $rotation)';
}

/// Rechnet einen Punkt aus einem gedrehten Bild auf das Original zurück.
Pt mapPointFromRotated(Pt p, ScanRotation rotation, double origW, double origH) {
  switch (rotation) {
    case ScanRotation.none:
      return p;
    case ScanRotation.cw90:
      return Pt(p.y, origH - p.x);
    case ScanRotation.ccw90:
      return Pt(origW - p.y, p.x);
  }
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
    required this.polygon,
    required this.lines,
    required this.cleanedLines,
    this.altTexts = const [],
    required this.format,
    required this.cutOff,
  });

  final Box box;

  /// Schräges Rechteck um die Hülle (4 Punkte).
  final List<Pt> polygon;
  final List<OcrLine> lines;

  /// Zeilen nach Sperrliste (leere entfernt), Reihenfolge wie [lines].
  final List<String> cleanedLines;

  /// Bereinigter Gesamttext mit anderen Lesungen einzelner Zeilen.
  final List<String> altTexts;
  final DiscFormat? format;

  /// Am Bildrand angeschnitten.
  final bool cutOff;

  String get rawText => lines.map((l) => l.text).join(' | ');
  String get cleanedText => cleanedLines.join(' ');
  bool get hasText => cleanedLines.isNotEmpty;
}

import 'dart:math' as math;

import '../config/app_config.dart';
import 'blocklist.dart';
import 'format_detector.dart';
import 'models.dart';

/// x-Position einer senkrechten Zeile, verlängert entlang ihrer Neigung bis
/// zur Höhe [refY]. So landen alle Zeilen derselben (schrägen) Hülle bei
/// ähnlichem Wert, auch wenn sie unterschiedlich hoch stehen.
double _xAt(OcrLine l, double refY, double tilt) {
  final c = l.center;
  return c.x + (refY - c.y) * tilt;
}

/// Neigung, die für eine Zeile verwendet wird: eigene Neigung bei langen
/// Zeilen (zuverlässig), sonst die typische Neigung des Fotos.
double _lineTilt(OcrLine l, double fallback) =>
    l.length >= l.thickness * 3 ? l.tilt : fallback;

double _median(List<double> v) {
  if (v.isEmpty) return 0;
  final s = [...v]..sort();
  return s[s.length ~/ 2];
}

double _quality(OcrLine l) {
  final letters = RegExp(r'[A-Za-zÄÖÜäöüß]').allMatches(l.text).length;
  return (l.confidence ?? 0.7) * 100 + letters;
}

/// Entfernt Zeilen mit sehr geringer Konfidenz und Doppelte, die in
/// mehreren Drehungen gefunden wurden (gleiche Lage, gleiche Achse).
List<OcrLine> dedupeLines(List<OcrLine> lines, RecognitionConfig cfg) {
  final filtered = lines
      .where((l) => l.text.trim().isNotEmpty)
      .where((l) => l.confidence == null || l.confidence! >= cfg.minLineConfidence)
      .toList()
    ..sort((a, b) => _quality(b).compareTo(_quality(a)));
  final kept = <OcrLine>[];
  for (final l in filtered) {
    final dup = kept.any((k) => _sameSpot(k, l));
    if (!dup) kept.add(l);
  }
  return kept;
}

bool _sameSpot(OcrLine a, OcrLine b) {
  if (a.isVertical != b.isVertical) {
    // Unterschiedliche Ausrichtung: nur doppelt, wenn fast deckungsgleich.
    final inter = a.box.intersectionArea(b.box);
    final smaller = math.min(a.box.area, b.box.area);
    return smaller > 0 && inter / smaller > 0.8;
  }
  // Gleiche Ausrichtung: Abstand quer zur Schrift und Überlappung entlang.
  final u = a.direction;
  final n = Pt(-u.y, u.x);
  final across = (b.center - a.center).dot(n).abs();
  if (across > 0.5 * math.max(a.thickness, b.thickness)) return false;
  double proj(Pt p) => p.dot(u);
  final a0 = math.min(proj(a.corners[0]), proj(a.corners[1]));
  final a1 = math.max(proj(a.corners[0]), proj(a.corners[1]));
  final b0 = math.min(proj(b.corners[0]), proj(b.corners[1]));
  final b1 = math.max(proj(b.corners[0]), proj(b.corners[1]));
  final overlap = math.min(a1, b1) - math.max(a0, b0);
  final shorter = math.min(a1 - a0, b1 - b0);
  return shorter > 0 && overlap / shorter > 0.6;
}

/// Gruppiert Textzeilen zu Hüllen.
///
/// Senkrechte Zeilen werden anhand ihrer Lage auf einer gemeinsamen
/// Bezugshöhe (Bildmitte, entlang der Neigung verlängert) zu Streifen
/// zusammengefasst. Zwei Zeilen gehören zur selben Hülle, wenn ihr Abstand
/// quer zur Schrift kleiner als [RecognitionConfig.spineGapFactor] mal die
/// mittlere Schrifthöhe ist. Waagerechte Zeilen (z. B. „4K“-Logo) werden der
/// Hülle zugeordnet, auf deren Achse sie liegen.
List<Spine> groupSpines(
  List<OcrLine> rawLines, {
  required double imageWidth,
  required double imageHeight,
  RecognitionConfig cfg = const RecognitionConfig(),
}) {
  final lines = dedupeLines(rawLines, cfg);
  final vertical = lines.where((l) => l.isVertical).toList();
  final horizontal = lines.where((l) => !l.isVertical).toList();
  if (vertical.isEmpty) return const [];

  final longTilts = [
    for (final l in vertical)
      if (l.length >= l.thickness * 3) l.tilt,
  ];
  final photoTilt = _median(longTilts);
  final refY = imageHeight / 2;

  final entries = [
    for (final l in vertical) (line: l, x: _xAt(l, refY, _lineTilt(l, photoTilt))),
  ]..sort((a, b) => a.x.compareTo(b.x));

  // Cluster: neue Hülle, wenn der Abstand zum Mittelwert des aktuellen
  // Clusters zu groß ist.
  final clusters = <List<({OcrLine line, double x})>>[];
  for (final e in entries) {
    if (clusters.isNotEmpty) {
      final c = clusters.last;
      final cx = c.map((x) => x.x).reduce((a, b) => a + b) / c.length;
      final ct = c.map((x) => x.line.thickness).reduce(math.max);
      final limit = cfg.spineGapFactor * (ct + e.line.thickness);
      if ((e.x - cx).abs() <= limit) {
        c.add(e);
        continue;
      }
    }
    clusters.add([e]);
  }

  final groups = [for (final c in clusters) c.map((e) => e.line).toList()];
  final tilts = [
    for (final g in groups)
      () {
        final t = [for (final l in g) if (l.length >= l.thickness * 3) l.tilt];
        return t.isEmpty ? photoTilt : _median(t);
      }(),
  ];

  // Waagerechte Zeilen der nächstgelegenen Achse zuordnen.
  for (final h in horizontal) {
    final hc = h.center;
    var best = -1;
    var bestDist = double.infinity;
    for (var i = 0; i < groups.length; i++) {
      final g = groups[i];
      final gc = g.first.center;
      final axisX = gc.x + (hc.y - gc.y) * tilts[i];
      final dist = (hc.x - axisX).abs();
      final width = g.map((l) => l.thickness).reduce(math.max) * 2;
      if (dist < width && dist < bestDist && h.box.width <= width * 2) {
        best = i;
        bestDist = dist;
      }
    }
    if (best >= 0) groups[best].add(h);
  }

  final edge = imageWidth * cfg.edgeMarginFraction;
  final spines = <Spine>[];
  for (var i = 0; i < groups.length; i++) {
    final g = groups[i];
    // Achse der Hülle: nach unten zeigend, mit der Neigung der Gruppe.
    final u = Pt(tilts[i], 1).unit;
    final n = Pt(u.y, -u.x); // quer, zeigt nach rechts
    // Lesereihenfolge: entlang der Achse, dann quer.
    g.sort((a, b) {
      final da = a.center.dot(n) - b.center.dot(n);
      if (da.abs() > math.min(a.thickness, b.thickness) * 0.5) {
        return da.sign.toInt();
      }
      return a.center.dot(u).compareTo(b.center.dot(u));
    });
    final pts = [for (final l in g) ...l.corners];
    var minU = double.infinity, maxU = -double.infinity;
    var minN = double.infinity, maxN = -double.infinity;
    for (final p in pts) {
      minU = math.min(minU, p.dot(u));
      maxU = math.max(maxU, p.dot(u));
      minN = math.min(minN, p.dot(n));
      maxN = math.max(maxN, p.dot(n));
    }
    final pad = g.map((l) => l.thickness).reduce(math.max) * 0.25;
    minU -= pad;
    maxU += pad;
    minN -= pad;
    maxN += pad;
    Pt at(double a, double b) => u * a + n * b;
    final polygon = [at(minU, minN), at(minU, maxN), at(maxU, maxN), at(maxU, minN)];
    final raw = Box.around(polygon);
    final box = Box(
      math.max(0, raw.left),
      math.max(0, raw.top),
      math.min(imageWidth, raw.right),
      math.min(imageHeight, raw.bottom),
    );
    final cleaned = <String>[];
    for (final l in g) {
      final cl = cleanLine(l.text);
      if (cl != null) cleaned.add(cl);
    }
    spines.add(Spine(
      box: box,
      polygon: polygon,
      lines: g,
      cleanedLines: cleaned,
      format: detectFormat(g.map((l) => l.text)),
      cutOff: raw.left <= edge || raw.right >= imageWidth - edge,
    ));
  }
  return spines;
}

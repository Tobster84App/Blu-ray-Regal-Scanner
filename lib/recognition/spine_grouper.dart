import 'dart:math' as math;

import '../config/app_config.dart';
import 'blocklist.dart';
import 'format_detector.dart';
import 'models.dart';

/// Entfernt doppelte Zeilen, die in mehreren Drehungen gefunden wurden,
/// und Zeilen mit sehr geringer Konfidenz.
List<OcrLine> dedupeLines(List<OcrLine> lines, RecognitionConfig cfg) {
  final filtered = lines
      .where((l) => l.text.trim().isNotEmpty)
      .where((l) => l.confidence == null || l.confidence! >= cfg.minLineConfidence)
      .toList()
    ..sort((a, b) => _quality(b).compareTo(_quality(a)));
  final kept = <OcrLine>[];
  for (final l in filtered) {
    final dup = kept.any((k) {
      final inter = k.box.intersectionArea(l.box);
      final smaller = math.min(k.box.area, l.box.area);
      return smaller > 0 && inter / smaller > 0.6;
    });
    if (!dup) kept.add(l);
  }
  return kept;
}

double _quality(OcrLine l) {
  final letters = RegExp(r'[A-Za-zÄÖÜäöüß]').allMatches(l.text).length;
  return (l.confidence ?? 0.7) * 100 + letters;
}

/// Gruppiert Textzeilen zu Hüllen.
///
/// Einfacher Ansatz: senkrechte Zeilen werden nach x-Position zu Streifen
/// zusammengefasst (Überlappung oder kleiner Abstand). Waagerechte Zeilen
/// (z. B. „4K“-Logo) werden dem Streifen zugeordnet, in dem ihre Mitte liegt.
List<Spine> groupSpines(
  List<OcrLine> rawLines, {
  required double imageWidth,
  required double imageHeight,
  RecognitionConfig cfg = const RecognitionConfig(),
}) {
  final lines = dedupeLines(rawLines, cfg);
  final vertical = lines.where((l) => l.isVertical).toList()
    ..sort((a, b) => a.box.left.compareTo(b.box.left));
  final horizontal = lines.where((l) => !l.isVertical).toList();
  if (vertical.isEmpty) return const [];

  final thicknesses = vertical.map((l) => l.box.thickness).toList()..sort();
  final medianThickness = thicknesses[thicknesses.length ~/ 2];
  final maxGap = medianThickness * cfg.spineGapFactor;

  final clusters = <List<OcrLine>>[];
  double clusterRight = -double.infinity;
  for (final l in vertical) {
    if (clusters.isNotEmpty && l.box.left - clusterRight <= maxGap) {
      clusters.last.add(l);
      clusterRight = math.max(clusterRight, l.box.right);
    } else {
      clusters.add([l]);
      clusterRight = l.box.right;
    }
  }

  // Waagerechte Zeilen zuordnen.
  final boxes = clusters
      .map((c) => c.map((l) => l.box).reduce((a, b) => a.union(b)))
      .toList();
  for (final h in horizontal) {
    for (var i = 0; i < clusters.length; i++) {
      final b = boxes[i];
      final slack = medianThickness * 0.5;
      if (h.box.centerX >= b.left - slack &&
          h.box.centerX <= b.right + slack &&
          h.box.width <= b.width + medianThickness * 2) {
        clusters[i].add(h);
        break;
      }
    }
  }

  final edge = imageWidth * cfg.edgeMarginFraction;
  final spines = <Spine>[];
  for (final c in clusters) {
    // Lesereihenfolge: von oben nach unten, dann von links nach rechts.
    c.sort((a, b) {
      final dy = a.box.top - b.box.top;
      if (dy.abs() > medianThickness) return dy.sign.toInt();
      return a.box.left.compareTo(b.box.left);
    });
    var box = c.map((l) => l.box).reduce((a, b) => a.union(b));
    box = box.inflate(medianThickness * 0.3, medianThickness * 0.3);
    box = Box(
      math.max(0, box.left),
      math.max(0, box.top),
      math.min(imageWidth, box.right),
      math.min(imageHeight, box.bottom),
    );
    final cleaned = <String>[];
    for (final l in c) {
      final cl = cleanLine(l.text);
      if (cl != null) cleaned.add(cl);
    }
    spines.add(Spine(
      box: box,
      lines: c,
      cleanedLines: cleaned,
      format: detectFormat(c.map((l) => l.text)),
      cutOff: box.left <= edge || box.right >= imageWidth - edge,
    ));
  }
  return spines;
}

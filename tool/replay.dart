// Spielt echte ML-Kit-Rohdaten (aus der Emulator-Messung) offline durch:
// Gruppierung + Treffersuche gegen das echte TMDB.
//   TMDB_API_KEY=... dart run tool/replay.dart test/fixtures/ocr_lines_run15.json [shelf_01.jpg]
import 'dart:convert';
import 'dart:io';

import 'package:discscanner/metadata/tmdb_provider.dart';
import 'package:discscanner/recognition/models.dart';
import 'package:discscanner/recognition/spine_grouper.dart';
import 'package:discscanner/recognition/spine_matcher.dart';

Future<void> main(List<String> args) async {
  final all = jsonDecode(File(args[0]).readAsStringSync()) as Map<String, dynamic>;
  final only = args.length > 1 ? args[1] : null;
  final provider = TmdbProvider(apiKey: () => Platform.environment['TMDB_API_KEY'] ?? '');
  final matcher = SpineMatcher(provider);
  final totals = <String, int>{};
  for (final entry in all.entries) {
    if (only != null && entry.key != only) continue;
    final d = entry.value as Map<String, dynamic>;
    final lines = [
      for (final l in (d['lines'] as List).cast<Map<String, dynamic>>())
        () {
          final corners = [
            for (final c in (l['corners'] as List).cast<Map<String, dynamic>>())
              Pt((c['x'] as num).toDouble(), (c['y'] as num).toDouble()),
          ];
          return OcrLine(
            text: l['text'] as String,
            box: Box.around(corners),
            rotation: ScanRotation.values.byName(l['rot'] as String),
            confidence: (l['conf'] as num?)?.toDouble(),
            corners: corners,
          );
        }(),
    ];
    final spines = groupSpines(lines,
        imageWidth: (d['width'] as num).toDouble(), imageHeight: (d['height'] as num).toDouble());
    final results = await matcher.matchAll(spines, language: 'de-DE');
    stdout.writeln('## ${entry.key}');
    for (var i = 0; i < spines.length; i++) {
      final r = results[i];
      totals[r.status.name] = (totals[r.status.name] ?? 0) + 1;
      final best = r.best == null ? '' : '${r.best!.label} ${(r.candidates.first.score * 100).round()}';
      stdout.writeln('${r.status.name.padRight(6)} ${spines[i].cleanedText.padRight(45).substring(0, 45)} -> $best');
    }
  }
  stdout.writeln('Gesamt: $totals');
  exit(0);
}

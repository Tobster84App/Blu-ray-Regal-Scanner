// Prüft die Treffersuche gegen das echte TMDB (nur für Entwicklung):
//   TMDB_API_KEY=... dart run tool/live_match.dart
import 'dart:io';

import 'package:discscanner/metadata/tmdb_provider.dart';
import 'package:discscanner/recognition/blocklist.dart';
import 'package:discscanner/recognition/models.dart';
import 'package:discscanner/recognition/spine_matcher.dart';

const samples = <List<String>>[
  ['JOHN WICK', 'KEANU REEVES', 'Blu-ray'],
  ['JOHN WICK KAPITEL 3', '4K ULTRA HD'],
  ['4K ULTRA HD', 'JOHN WICK', 'LIONSGATE'],
  ['JOKER', '4K ULTRA HD'],
  ["ZACK SNYDER'S", 'JUSTICE LEAGUE'],
  ['HOTEL ARTEMIS'],
  ['PACIFIC RIM', 'UPRISING', 'ULTRA HD'],
  ['DUNE'],
  ['PACIFIC RIM', 'ULTRAHD'],
  ['DER SUPER MARIO BROS. FILM'],
  ['BOHEMIAN RHAPSODY'],
  ['VENOM', 'ULTRA HD'],
  ['GODZILLA II', 'KING OF THE MONSTERS'],
  ['SPIDER-MAN', 'No Way Home'],
  ['NOBODY'],
  ['UNCHARTED'],
  ['DUNGEONS & DRAGONS', 'EHRE UNTER DIEBEN'],
  ['THE FLASH', '4K ULTRA HD'],
  ['HACKSAW RIDGE', 'DIE ENTSCHEIDUNG'],
  ['KONG', 'SKULL ISLAND'],
  ['STAR WARS', 'DIE LETZTEN JEDI'],
  ['MAD MAX', 'FURY ROAD'],
  ['DEADPOOL'],
  ['FALLOUT', '3-DISC SET'],
];

Future<void> main() async {
  final key = Platform.environment['TMDB_API_KEY'] ?? '';
  final provider = TmdbProvider(apiKey: () => key);
  final matcher = SpineMatcher(provider);
  for (final lines in samples) {
    final ocr = [for (final t in lines) OcrLine(text: t, box: const Box(0, 0, 10, 100), rotation: ScanRotation.ccw90)];
    final spine = Spine(
      box: const Box(100, 0, 110, 100),
      polygon: const Box(100, 0, 110, 100).corners,
      lines: ocr,
      cleanedLines: [for (final t in lines) ?cleanLine(t)],
      format: null,
      cutOff: false,
    );
    final r = await matcher.match(spine, language: 'de-DE');
    final c = r.candidates.map((c) => '${c.hit.label} ${(c.score * 100).round()}').join(' | ');
    stdout.writeln('${r.status.name.padRight(6)} ${lines.join(' / ').padRight(42)} -> $c${r.error != null ? '  ERR ${r.error}' : ''}');
  }
  exit(0);
}

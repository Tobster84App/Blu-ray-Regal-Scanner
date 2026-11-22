// Misst die Erkennung auf den Testfotos in test/fixtures – läuft auf einem
// Android-Gerät oder Emulator (ML Kit gibt es nur dort). Die Fotos werden
// zur Laufzeit von GitHub geladen (öffentliches Repository), damit sie die
// App nicht aufblähen:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/ocr_eval_test.dart \
//     --dart-define=FIXTURE_BASE_URL=https://raw.githubusercontent.com/<owner>/<repo>/<sha>/test/fixtures \
//     --dart-define=FIXTURES=shelf_01.jpg,shelf_02.jpg --dart-define=TMDB_API_KEY=...
import 'dart:convert';

import 'package:discscanner/config/app_config.dart';
import 'package:discscanner/metadata/tmdb_provider.dart';
import 'package:discscanner/recognition/matcher.dart';
import 'package:discscanner/recognition/ocr_service.dart';
import 'package:discscanner/recognition/spine_grouper.dart';
import 'package:discscanner/recognition/spine_matcher.dart';
import 'package:discscanner/recognition/text_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';

import '../test/fixtures/shelf_01_expected.dart';

const _baseUrl = String.fromEnvironment('FIXTURE_BASE_URL');
const _fixtures = String.fromEnvironment('FIXTURES');

/// Erwartete Titel je Foto (soweit bekannt).
final _expected = <String, List<String>>{
  'shelf_01.jpg': shelf01Expected.map((e) => e.title).toList(),
};

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Erkennung auf den Testfotos', (tester) async {
    final names = _fixtures.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (_baseUrl.isEmpty || names.isEmpty) {
      binding.reportData = {'report': 'Keine Testfotos angegeben.', 'lines': '{}'};
      return;
    }
    final result = await tester.runAsync(() async {
      final report = StringBuffer();
      final allLines = <String, dynamic>{};
      final provider = TmdbProvider(apiKey: () => buildTmdbApiKey);
      const cfg = RecognitionConfig();
      final ocr = OcrService();
      if (!provider.isConfigured) {
        report.writeln('_Kein TMDB-Schlüssel – nur Texterkennung, keine Treffersuche._\n');
      }
      final totals = <String, int>{};
      for (final name in names) {
        final res0 = await http.get(Uri.parse('$_baseUrl/$name'));
        if (res0.statusCode != 200) {
          report.writeln('## $name\n\nDownload fehlgeschlagen: ${res0.statusCode}\n');
          continue;
        }
        final sw = Stopwatch()..start();
        final res = await ocr.recognize(res0.bodyBytes);
        final ocrMs = sw.elapsedMilliseconds;
        final spines = groupSpines(res.lines, imageWidth: res.width, imageHeight: res.height, cfg: cfg);
        final results = provider.isConfigured
            ? await SpineMatcher(provider, cfg: cfg).matchAll(spines, language: 'de-DE')
            : <SpineResult>[];
        final expected = _expected[name];
        bool isExpected(String? t) =>
            expected != null && t != null &&
            expected.any((e) => normalize(e) == normalize(t) || scoreTitle(e, t) >= 0.95);

        report
          ..writeln('## $name')
          ..writeln()
          ..writeln('${res.width.round()} × ${res.height.round()} px · ${res.lines.length} Textzeilen '
              '(3 Durchläufe) · ${spines.length} Hüllen · Texterkennung ${(ocrMs / 1000).toStringAsFixed(1)} s')
          ..writeln()
          ..writeln('| # | x | Status | Erkannter Text | Bereinigt | Fmt | Treffer | ok? |')
          ..writeln('|---|---|---|---|---|---|---|---|');
        final tally = <String, int>{};
        String esc(String t) => t.replaceAll('|', '/').replaceAll('\n', ' ');
        for (var i = 0; i < spines.length; i++) {
          final s = spines[i];
          final r = results.isEmpty ? null : results[i];
          final status = r?.status ?? (s.cutOff ? MatchStatus.grey : null);
          final best = r?.best;
          final ok = expected == null || best == null
              ? ''
              : (isExpected(best.title) || isExpected(best.originalTitle) ? '✅' : '❌');
          final key = '${status?.name ?? '-'}${ok == '✅' ? '_ok' : ok == '❌' ? '_falsch' : ''}';
          tally[key] = (tally[key] ?? 0) + 1;
          totals[status?.name ?? '-'] = (totals[status?.name ?? '-'] ?? 0) + 1;
          report.writeln('| ${i + 1} | ${s.box.left.round()} | ${status?.name ?? '-'} | '
              '${esc(s.rawText)} | ${esc(s.cleanedText)} | ${s.format?.name ?? ''} | '
              '${best == null ? '' : esc('${best.label} ${(r!.candidates.first.score * 100).round()}%')} | $ok |');
        }
        report
          ..writeln()
          ..writeln('**Zusammenfassung:** ${tally.entries.map((e) => '${e.key}: ${e.value}').join(', ')}');
        if (expected != null && results.isNotEmpty) {
          final found = results.map((r) => r.best?.title).whereType<String>().toList();
          final missing = expected
              .where((e) => !found.any((f) => normalize(f) == normalize(e) || scoreTitle(e, f) >= 0.95))
              .toSet();
          report.writeln('\nErwartet ${expected.length} Hüllen. Nicht gefunden: ${missing.isEmpty ? '–' : missing.join(', ')}');
        }
        report.writeln();
        allLines[name] = {
          'width': res.width,
          'height': res.height,
          'lines': [
            for (final l in res.lines)
              {
                'text': l.text,
                'rot': l.rotation.name,
                'conf': l.confidence,
                'corners': [for (final c in l.corners) c.toJson()],
              },
          ],
        };
      }
      await ocr.dispose();
      final head = '# Erkennung Testfotos\n\nGesamt: ${totals.entries.map((e) => '${e.key}: ${e.value}').join(', ')}\n\n';
      return {'report': head + report.toString(), 'lines': jsonEncode(allLines)};
    });
    binding.reportData = result;
  });
}

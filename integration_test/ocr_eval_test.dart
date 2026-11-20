// Misst die Erkennung auf dem Referenzfoto – läuft auf einem Android-Gerät
// oder Emulator (ML Kit gibt es nur dort):
//   python3 tool/embed_fixture.py
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/ocr_eval_test.dart --dart-define=TMDB_API_KEY=...
import 'dart:convert';

import 'package:discscanner/config/app_config.dart';
import 'package:discscanner/metadata/tmdb_provider.dart';
import 'package:discscanner/recognition/matcher.dart';
import 'package:discscanner/recognition/ocr_service.dart';
import 'package:discscanner/recognition/spine_grouper.dart';
import 'package:discscanner/recognition/spine_matcher.dart';
import 'package:discscanner/recognition/text_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/fixtures/shelf_01_expected.dart';
import 'fixture_data.g.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Trefferquote auf shelf_01.jpg', (tester) async {
    if (!hasFixture) {
      binding.reportData = {'report': 'Kein Testfoto eingebettet.', 'lines': '[]'};
      return;
    }
    final report = await tester.runAsync(() async {
      final sw = Stopwatch()..start();
      final ocr = OcrService();
      final res = await ocr.recognize(base64Decode(shelfJpegBase64));
      await ocr.dispose();
      final ocrMs = sw.elapsedMilliseconds;
      const cfg = RecognitionConfig();
      final spines = groupSpines(res.lines,
          imageWidth: res.width, imageHeight: res.height, cfg: cfg);

      final provider = TmdbProvider(apiKey: () => buildTmdbApiKey);
      final results = provider.isConfigured
          ? await SpineMatcher(provider, cfg: cfg).matchAll(spines, language: 'de-DE')
          : <SpineResult>[];

      final expectedTitles = shelf01Expected.map((e) => e.title).toList();
      bool isExpected(String? t) =>
          t != null && expectedTitles.any((e) => normalize(e) == normalize(t) || scoreTitle(e, t) >= 0.95);

      final sb = StringBuffer()
        ..writeln('## Erkennung shelf_01.jpg')
        ..writeln()
        ..writeln('Bild ${res.width.round()} × ${res.height.round()} px, '
            '${res.lines.length} Textzeilen (3 Durchläufe), ${spines.length} Hüllen, '
            'Texterkennung ${ocrMs ~/ 1000} s')
        ..writeln();
      if (!provider.isConfigured) {
        sb.writeln('_Kein TMDB-Schlüssel – nur Texterkennung, keine Treffersuche._\n');
      }
      sb
        ..writeln('| # | x | Status | Erkannter Text | Bereinigt | Format | Treffer | korrekt? |')
        ..writeln('|---|---|---|---|---|---|---|---|');
      final tally = <String, int>{};
      for (var i = 0; i < spines.length; i++) {
        final s = spines[i];
        final r = results.isEmpty ? null : results[i];
        final status = r?.status ?? (s.cutOff ? MatchStatus.grey : null);
        final best = r?.best;
        final ok = best == null ? '' : (isExpected(best.title) || isExpected(best.originalTitle) ? '✅' : '❌');
        final key = '${status?.name ?? '-'}${ok == '✅' ? '_ok' : ok == '❌' ? '_falsch' : ''}';
        tally[key] = (tally[key] ?? 0) + 1;
        String esc(String t) => t.replaceAll('|', '/').replaceAll('\n', ' ');
        sb.writeln('| ${i + 1} | ${s.box.left.round()} | ${status?.name ?? '-'} | '
            '${esc(s.rawText)} | ${esc(s.cleanedText)} | ${s.format?.name ?? ''} | '
            '${best == null ? '' : esc('${best.label} ${(r!.candidates.first.score * 100).round()}%')} | $ok |');
      }
      sb
        ..writeln()
        ..writeln('**Zusammenfassung:** ${tally.entries.map((e) => '${e.key}: ${e.value}').join(', ')}')
        ..writeln()
        ..writeln('Erwartet: ${shelf01Expected.length} Hüllen.');
      final found = results.map((r) => r.best?.title).whereType<String>().toList();
      final missing = expectedTitles.where((e) => !found.any((f) => normalize(f) == normalize(e) || scoreTitle(e, f) >= 0.95)).toSet();
      sb.writeln('Nicht gefunden: ${missing.isEmpty ? '–' : missing.join(', ')}');

      final linesJson = jsonEncode({
        'width': res.width,
        'height': res.height,
        'lines': [
          for (final l in res.lines)
            {'text': l.text, 'box': l.box.toJson(), 'rot': l.rotation.name, 'conf': l.confidence},
        ],
      });
      return {'report': sb.toString(), 'lines': linesJson};
    });
    binding.reportData = report;
  });
}

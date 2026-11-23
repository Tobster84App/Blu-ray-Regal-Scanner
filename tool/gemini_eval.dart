// Messversuch: Erkennt Gemini die Hüllenrücken besser als ML Kit?
//   GEMINI_MODEL=... TMDB_API_KEY=... dart run tool/gemini_eval.dart [shelf_01.jpg ...]
// Nutzt die OpenAI-kompatible Gemini-Schnittstelle (Schlüssel als
// „Authorization: Bearer“). In dieser Cloud-Umgebung setzt der Proxy den
// Schlüssel ein; lokal: GEMINI_API_KEY setzen.
import 'dart:convert';
import 'dart:io';

import 'package:discscanner/metadata/tmdb_provider.dart';
import 'package:discscanner/recognition/matcher.dart';
import 'package:discscanner/recognition/models.dart';
import 'package:discscanner/recognition/spine_matcher.dart';
import 'package:discscanner/recognition/text_utils.dart';
import 'package:http/http.dart' as http;

const prompt = '''
Auf dem Foto stehen Hüllen von Filmen oder Serien (Blu-ray, 4K UHD, DVD) in einem Regal.
Lies jeden sichtbaren Hüllenrücken von links nach rechts.
Gib für jede Hülle den Titel genau so an, wie er auf dem Rücken steht – inklusive Zusätzen
wie „Kapitel 3“, „Uprising“ oder Untertiteln. Schauspielernamen, Studios, Logos und
Artikelnummern gehören nicht zum Titel.
Antworte ausschließlich mit JSON:
{"spines": [{"title": "...", "format": "UHD|BD|DVD|unbekannt", "cut_off": true/false}]}
cut_off = true, wenn die Hülle am linken oder rechten Bildrand abgeschnitten ist.
Kannst du einen Titel nicht lesen, setze "title": null.''';

Future<void> main(List<String> args) async {
  final model = Platform.environment['GEMINI_MODEL'] ?? 'gemini-3.5-flash-lite';
  final key = Platform.environment['GEMINI_API_KEY'] ?? 'proxy-injected';
  final expected = (jsonDecode(File('test/fixtures/expected.json').readAsStringSync()) as Map)
      .cast<String, dynamic>();
  final photos = args.isNotEmpty
      ? args
      : (Directory('test/fixtures').listSync().map((f) => f.uri.pathSegments.last)
          .where((n) => n.endsWith('.jpg')).toList()..sort());
  final tmdb = TmdbProvider(apiKey: () => Platform.environment['TMDB_API_KEY'] ?? '');
  final matcher = SpineMatcher(tmdb);
  var totalExpected = 0, totalCorrect = 0, totalGreenCorrect = 0, totalWrongGreen = 0;
  for (final name in photos) {
    final bytes = File('test/fixtures/$name').readAsBytesSync();
    final sw = Stopwatch()..start();
    final res = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/openai/chat/completions'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $key'},
      body: jsonEncode({
        'model': model,
        'temperature': 0,
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,${base64Encode(bytes)}'},
              },
            ],
          },
        ],
      }),
    );
    final secs = sw.elapsedMilliseconds / 1000;
    if (res.statusCode != 200) {
      stdout.writeln('## $name: Gemini-Fehler ${res.statusCode}: ${res.body.substring(0, res.body.length.clamp(0, 400))}');
      continue;
    }
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    var text = ((body['choices'] as List).first as Map)['message']['content'] as String;
    text = text.replaceAll(RegExp(r'^```(json)?|```$', multiLine: true), '').trim();
    final usage = body['usage'] as Map?;
    final decoded = jsonDecode(text);
    final items = ((decoded is Map ? decoded['spines'] : decoded) as List).cast<Map<String, dynamic>>();
    final exp = (expected[name] as List?)?.cast<String>() ?? const [];
    final expTitles = exp.map((e) => e.replaceFirst('cut:', '')).where((e) => !e.startsWith('?')).toList();
    stdout.writeln('## $name – ${items.length} Hüllen von Gemini, ${secs.toStringAsFixed(1)} s, Tokens: ${usage?['prompt_tokens']}/${usage?['completion_tokens']}');
    final found = <String>[];
    final pool = [...expTitles]; // jeder Soll-Titel zählt nur einmal
    for (final it in items) {
      final title = it['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        stdout.writeln('   ?      (unlesbar)');
        continue;
      }
      final spine = Spine(
        box: const Box(0, 0, 1, 1), polygon: const Box(0, 0, 1, 1).corners,
        lines: [OcrLine(text: title, box: const Box(0, 0, 1, 10), rotation: ScanRotation.none)],
        cleanedLines: [normalize(title)], format: null, cutOff: it['cut_off'] == true,
      );
      final r = await matcher.match(spine, language: 'de-DE');
      final best = r.best;
      int idx(String? t) => t == null ? -1 : pool.indexWhere((e) =>
          normalize(e.replaceAll('?', '')) == normalize(t) || scoreTitle(e.replaceAll('?', ''), t) >= 0.9);
      var i = best == null ? -1 : idx(best.title);
      if (i < 0 && best != null) i = idx(best.originalTitle);
      final ok = i >= 0;
      if (ok) pool.removeAt(i);
      if (ok) found.add(best!.title);
      if (ok) totalCorrect++;
      if (ok && r.status == MatchStatus.green) totalGreenCorrect++;
      if (!ok && r.status == MatchStatus.green) totalWrongGreen++;
      stdout.writeln('   ${ok ? '✅' : '❌'} ${r.status.name.padRight(6)} „$title“ ${it['format']} -> ${best?.label ?? '–'}');
    }
    totalExpected += expTitles.length;
    stdout.writeln('   Soll ${expTitles.length}, richtig ${found.length}${pool.isEmpty ? '' : ' · fehlt: ${pool.join(', ')}'}');
  }
  stdout.writeln('\nGESAMT: Soll $totalExpected · richtig erkannt $totalCorrect '
      '(${totalExpected == 0 ? 0 : (100 * totalCorrect / totalExpected).round()} %) · davon grün $totalGreenCorrect · falsch grün $totalWrongGreen');
  exit(0);
}

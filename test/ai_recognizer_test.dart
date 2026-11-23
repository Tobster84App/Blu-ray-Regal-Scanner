import 'package:discscanner/metadata/metadata_provider.dart';
import 'package:discscanner/recognition/ai_recognizer.dart';
import 'package:discscanner/recognition/format_detector.dart';
import 'package:discscanner/recognition/matcher.dart';
import 'package:discscanner/recognition/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('KI-Antwort einlesen: Code-Zaun, verschachtelte Rahmen, fehlende Titel', () {
    const content = '''```json
{"spines": [
  {"title": "JOKER", "format": "UHD", "cut_off": false, "box_2d": [[100, 200, 900, 250]]},
  {"title": null, "format": "BD"},
  {"title": "Dune", "format": "unknown", "cut_off": true, "box_2d": [0, 950, 1000, 1000]}
]}
```''';
    final r = AiRecognizer.parseResponse(content, width: 4000, height: 3000);
    expect(r.length, 2);
    expect(r[0].title, 'JOKER');
    expect(r[0].format, DiscFormat.uhd);
    expect(r[0].box!.left, 800);
    expect(r[0].box!.top, 300);
    expect(r[0].box!.right, 1000);
    expect(r[1].cutOff, isTrue);
    expect(r[1].format, isNull);
  });

  test('Kaputtes JSON (fehlende Klammer) wird trotzdem gelesen', () {
    const broken = '{"spines": [{"title": "JOHN WICK", "format": "UHD", "cut_off": true, "box_2d": [74, 0, 898, 93]}, "title": "JOHN WICK", "format": "BD", "cut_off": false, "box_2d": [70, 40, 900, 120]}]}';
    final r = AiRecognizer.parseResponse(broken, width: 1000, height: 1000);
    expect(r.length, 2);
    expect(r[1].format, DiscFormat.bluray);
    expect(r[1].box!.left, 40);
  });

  test('Liste statt Objekt wird auch verstanden', () {
    final r = AiRecognizer.parseResponse('[{"title": "Venom"}]', width: 100, height: 100);
    expect(r.single.title, 'Venom');
    expect(r.single.box, isNull);
  });

  test('KI-Rahmen rasten auf ML-Kit-Hüllen ein', () {
    Spine spine(double l, double r) => Spine(
          box: Box(l, 0, r, 100), polygon: Box(l, 0, r, 100).corners, lines: const [],
          cleanedLines: const ['x'], format: null, cutOff: false);
    final ocr = [spine(100, 140), spine(160, 200), spine(220, 260)];
    final ai = [
      const AiSpine(title: 'A', box: Box(95, 0, 150, 100)),
      const AiSpine(title: 'B', box: Box(300, 0, 340, 100)), // keine passende Hülle
      const AiSpine(title: 'C', box: Box(215, 0, 250, 100)),
    ];
    expect(snapToOcrSpines(ai, ocr), [0, -1, 2]);
  });

  test('Fortsetzung: „Peter Hase 2“ bevorzugt Teil 2', () {
    final hits = [
      const SearchHit(id: '1', type: MediaType.movie, title: 'Peter Hase', popularity: 20),
      const SearchHit(id: '2', type: MediaType.movie,
          title: 'Peter Hase 2 - Ein Hase macht sich vom Acker', originalTitle: 'Peter Rabbit 2: The Runaway', popularity: 15),
    ];
    expect(rankHits(hits, 'peter hase 2').first.hit.id, '2');
  });
}

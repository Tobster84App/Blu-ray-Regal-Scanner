// Regressionstests mit echten ML-Kit-Rohdaten aus der Emulator-Messung
// (test/fixtures/ocr_lines_run13.json, Fotos test/fixtures/shelf_0x.jpg).
import 'dart:convert';
import 'dart:io';

import 'package:discscanner/recognition/blocklist.dart';
import 'package:discscanner/recognition/format_detector.dart';
import 'package:discscanner/recognition/models.dart';
import 'package:discscanner/recognition/spine_grouper.dart';
import 'package:flutter_test/flutter_test.dart';

({List<OcrLine> lines, double w, double h}) load(String photo) {
  final all = jsonDecode(File('test/fixtures/ocr_lines_run13.json').readAsStringSync())
      as Map<String, dynamic>;
  final d = all[photo] as Map<String, dynamic>;
  final lines = <OcrLine>[
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
  return (lines: lines, w: (d['width'] as num).toDouble(), h: (d['height'] as num).toDouble());
}

void main() {
  test('Formatlogos mit Lesefehlern werden entfernt', () {
    for (final t in ['4K UTRAHD', '4KUTRAHD', 'JLTRAHD', 'ULTAAHD', 'Blusay', 'BlutaY', 'Bluay', 'AK ULTRAHD', 'ULTRAHE']) {
      expect(cleanLine(t), isNull, reason: t);
    }
    expect(cleanLine('NVERSA Do87402'), 'nversa');
    expect(cleanLine('ULTRA HD PACIFIC RIM'), 'pacific rim');
    expect(cleanLine('JUSTICE 1EAGUE'), 'justice league');
    expect(cleanLine('JOHN WICK KA PITil / LIONSOATE'), 'john wick ka pitil');
    expect(cleanLine('Universal Soldier'), 'universal soldier');
    expect(cleanLine('BLURAYDLSC DIE ZWEI TURME'), 'die zwei turme');
    expect(cleanLine('BLUSAYDISE'), isNull);
    expect(cleanLine('DEADPOOL 2'), 'deadpool 2');
    expect(detectFormat(['4K UTRAHD']), DiscFormat.uhd);
    expect(detectFormat(['Blusay']), DiscFormat.bluray);
  });

  test('shelf_01: Nachbarhüllen bleiben getrennt, Zeilen derselben Hülle zusammen', () {
    final d = load('shelf_01.jpg');
    final spines = groupSpines(d.lines, imageWidth: d.w, imageHeight: d.h);
    int spineOf(String text) => spines.indexWhere((s) => s.lines.any((l) => l.text == text));
    expect(spineOf('HACKSAW RIDGE'), isNot(spineOf('KONG')));
    expect(spineOf('KONG'), spineOf('SKULL ISLAND'));
    expect(spineOf('HACKSAW RIDGE'), spineOf('DIE ENTSCHEIDUNG'));
    expect(spineOf('JUSTICE LEAGUE'), spineOf('ZACKISNYDERS'));
    expect(spineOf('JOKER'), isNot(spineOf('JUSTICE LEAGUE')));
    expect(spineOf('STARWARS'), spineOf('DIE LETZTEN JEDI'));
    expect(spineOf('BOHEMIAN RHAPSODY'), isNot(spineOf('VENOM')));
  });

  test('Andere Lesungen derselben Zeile bleiben als Alternative erhalten', () {
    final d = load('shelf_01.jpg');
    final spines = groupSpines(d.lines, imageWidth: d.w, imageHeight: d.h);
    final jl = spines.firstWhere((s) => s.lines.any((l) => l.text.startsWith('JUSTICE')));
    expect([jl.cleanedText, ...jl.altTexts].any((t) => t.contains('justice league')), isTrue);
  });
}

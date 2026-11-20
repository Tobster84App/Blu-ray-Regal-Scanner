import 'package:discscanner/config/app_config.dart';
import 'package:discscanner/metadata/metadata_provider.dart';
import 'package:discscanner/recognition/blocklist.dart';
import 'package:discscanner/recognition/format_detector.dart';
import 'package:discscanner/recognition/matcher.dart';
import 'package:discscanner/recognition/models.dart';
import 'package:discscanner/recognition/query_builder.dart';
import 'package:discscanner/recognition/spine_grouper.dart';
import 'package:discscanner/recognition/text_utils.dart';
import 'package:flutter_test/flutter_test.dart';

SearchHit hit(String id, String title,
        {String? original, int? year, double pop = 10, MediaType type = MediaType.movie}) =>
    SearchHit(id: id, type: type, title: title, originalTitle: original, year: year, popularity: pop);

/// Typische TMDB-Kandidaten (deutsche Titel).
final candidates = [
  hit('245891', 'John Wick', year: 2014, pop: 60),
  hit('324552', 'John Wick: Kapitel 2', original: 'John Wick: Chapter 2', year: 2017, pop: 50),
  hit('458156', 'John Wick: Kapitel 3', original: 'John Wick: Chapter 3 - Parabellum', year: 2019, pop: 55),
  hit('603692', 'John Wick: Kapitel 4', original: 'John Wick: Chapter 4', year: 2023, pop: 70),
  hit('68726', 'Pacific Rim', year: 2013, pop: 40),
  hit('268896', 'Pacific Rim: Uprising', year: 2018, pop: 30),
  hit('438631', 'Dune', year: 2021, pop: 90),
  hit('841', 'Der Wüstenplanet', original: 'Dune', year: 1984, pop: 20),
  hit('693134', 'Dune: Part Two', year: 2024, pop: 80),
  hit('106912', 'Fallout', year: 2024, pop: 120, type: MediaType.tv),
  hit('502356', 'Der Super Mario Bros. Film', original: 'The Super Mario Bros. Movie', year: 2023, pop: 70),
  hit('373571', 'Godzilla II: King of the Monsters', original: 'Godzilla: King of the Monsters', year: 2019, pop: 40),
  hit('929', 'Godzilla', year: 1998, pop: 30),
  hit('493922', 'Dungeons & Dragons: Ehre unter Dieben', original: 'Dungeons & Dragons: Honor Among Thieves', year: 2023, pop: 50),
  hit('324857', 'Hacksaw Ridge - Die Entscheidung', original: 'Hacksaw Ridge', year: 2016, pop: 30),
  hit('791373', "Zack Snyder's Justice League", year: 2021, pop: 40),
  hit('141052', 'Justice League', year: 2017, pop: 40),
  hit('181808', 'Star Wars: Die letzten Jedi', original: 'Star Wars: The Last Jedi', year: 2017, pop: 40),
  hit('76341', 'Mad Max: Fury Road', year: 2015, pop: 50),
];

SearchHit? bestFor(String spineText) {
  final r = rankHits(candidates, spineText);
  return r.isEmpty ? null : r.first.hit;
}

MatchStatus statusFor(String spineText) =>
    classify(rankHits(candidates, spineText),
        cutOff: false, cfg: const RecognitionConfig());

void main() {
  group('Sperrliste', () {
    test('Formatlogos werden entfernt', () {
      expect(cleanLine('JOHN WICK 4K ULTRA HD'), 'john wick');
      expect(cleanLine('BLU-RAY DISC'), isNull);
      expect(cleanLine('Blu-ray'), isNull);
      expect(cleanLine('UltraHD'), isNull);
    });
    test('Studio-Zeilen fallen weg, Titel mit Studio-Wort bleiben', () {
      expect(cleanLine('LIONSGATE'), isNull);
      expect(cleanLine('Warner Bros. Pictures'), isNull);
      expect(cleanLine('WB'), isNull);
      expect(cleanLine('20th Century Studios'), isNull);
      expect(cleanLine('Universal Soldier'), 'universal soldier');
    });
    test('Nummern und Sonstiges', () {
      expect(cleanLine('1234567'), isNull);
      expect(cleanLine('Best.-Nr. 88985 412349'), isNull);
      expect(cleanLine('3-Disc Set'), isNull);
      expect(cleanLine('FALLOUT 3-DISC SET'), 'fallout');
      expect(cleanLine('STEELBOOK'), isNull);
      expect(cleanLine('JOHN WICK KAPITEL 3'), 'john wick kapitel 3');
    });
  });

  group('Formaterkennung', () {
    test('UHD hat Vorrang', () {
      expect(detectFormat(['4K ULTRA HD', 'BLU-RAY']), DiscFormat.uhd);
      expect(detectFormat(['ULTRA HD BLU-RAY']), DiscFormat.uhd);
      expect(detectFormat(['UHD']), DiscFormat.uhd);
    });
    test('Blu-ray und DVD', () {
      expect(detectFormat(['Blu-ray Disc']), DiscFormat.bluray);
      expect(detectFormat(['BLURAY']), DiscFormat.bluray);
      expect(detectFormat(['DVD']), DiscFormat.dvd);
      expect(detectFormat(['John Wick']), isNull);
    });
    test('4K mitten im Wort zählt nicht', () {
      expect(detectFormat(['AK47K4']), isNull);
    });
  });

  group('Textvergleich', () {
    test('Tippfehler bei langen Wörtern erlaubt, bei Zahlen nicht', () {
      expect(tokensMatch('uncharted', 'uncharied'), isTrue);
      expect(tokensMatch('wick', 'wiek'), isTrue);
      expect(tokensMatch('3', '2'), isFalse);
      expect(tokensMatch('dc', 'de'), isFalse);
    });
    test('römische Zahlen', () {
      expect(tokenize('Godzilla II'), ['godzilla', '2']);
    });
  });

  group('Treffer-Bewertung', () {
    test('John Wick mit Schauspielername -> John Wick', () {
      expect(bestFor('john wick keanu reeves')!.id, '245891');
      expect(statusFor('john wick keanu reeves'), MatchStatus.green);
    });
    test('Zusatz entscheidet: Kapitel 3', () {
      expect(bestFor('john wick kapitel 3')!.id, '458156');
      expect(statusFor('john wick kapitel 3'), MatchStatus.green);
    });
    test('OCR-Fehler im Zusatz: "KAPlTEL 3"', () {
      expect(bestFor('john wick kapltel 3')!.id, '458156');
    });
    test('Pacific Rim vs. Uprising', () {
      expect(bestFor('pacific rim')!.id, '68726');
      expect(bestFor('pacific rim uprising')!.id, '268896');
      expect(statusFor('pacific rim uprising'), MatchStatus.green);
      expect(statusFor('pacific rim'), MatchStatus.green);
    });
    test('Dune: neuere Verfilmung deutlich bekannter -> grün', () {
      expect(bestFor('dune')!.id, '438631');
    });
    test('Serie Fallout', () {
      final b = bestFor('fallout')!;
      expect(b.type, MediaType.tv);
    });
    test('Originaltitel zählt auch', () {
      expect(bestFor('the super mario bros movie')!.id, '502356');
      expect(bestFor('der super mario bros film')!.id, '502356');
    });
    test('Godzilla II mit römischer Zahl', () {
      expect(bestFor('godzilla ii king of the monsters')!.id, '373571');
    });
    test('Zusammengeklebte Wörter', () {
      expect(bestFor('madmax furyroad')!.id, '76341');
    });
    test('Zack Snyder\'s Justice League vs. Justice League', () {
      expect(bestFor('zack snyders justice league')!.id, '791373');
      expect(bestFor('justice league')!.id, '141052');
    });
    test('Dungeons & Dragons mit Tippfehler', () {
      expect(bestFor('dungeons dragons ehre unter dieben')!.id, '493922');
      expect(bestFor('dungeons dragons ehre unter dleben')!.id, '493922');
    });
    test('Unsinn -> rot', () {
      expect(statusFor('xqz ptrw'), MatchStatus.red);
    });
  });

  group('Suchvarianten', () {
    test('ganzer Text, längste Zeile, Kombinationen', () {
      final q = buildQueries(['keanu reeves', 'john wick']);
      expect(q.first, 'keanu reeves john wick');
      expect(q, contains('john wick'));
      expect(q, contains('keanu reeves'));
    });
  });

  group('Koordinaten', () {
    test('Rückrechnung aus gedrehten Bildern', () {
      // Original 100 x 50. Punkt-Box links oben (10..20, 5..15).
      const w = 100.0, h = 50.0;
      // Im Uhrzeigersinn gedreht (50 x 100): x' = H - y, y' = x
      const cw = Box(h - 15, 10, h - 5, 20);
      final back = mapFromRotated(cw, ScanRotation.cw90, w, h);
      expect([back.left, back.top, back.right, back.bottom], [10, 5, 20, 15]);
      // Gegen den Uhrzeigersinn (50 x 100): x' = y, y' = W - x
      const ccw = Box(5, w - 20, 15, w - 10);
      final back2 = mapFromRotated(ccw, ScanRotation.ccw90, w, h);
      expect([back2.left, back2.top, back2.right, back2.bottom], [10, 5, 20, 15]);
    });
  });

  group('Hüllen trennen', () {
    OcrLine v(String t, double x, double w, {double top = 100, double h = 600}) =>
        OcrLine(text: t, box: Box(x, top, x + w, top + h), rotation: ScanRotation.cw90);
    OcrLine hz(String t, double x, double w, double y) =>
        OcrLine(text: t, box: Box(x, y, x + w, y + 20), rotation: ScanRotation.none);

    test('drei Hüllen nebeneinander, eine mit zwei Zeilen', () {
      final spines = groupSpines([
        v('JOHN WICK', 100, 30),
        v('KEANU REEVES', 135, 15, top: 300, h: 200), // gleiche Hülle
        v('JOKER', 200, 30),
        v('DUNE', 300, 30),
        hz('4K', 102, 25, 20),
      ], imageWidth: 1000, imageHeight: 800);
      expect(spines.length, 3);
      expect(spines[0].cleanedText, 'john wick keanu reeves');
      expect(spines[0].format, DiscFormat.uhd);
      expect(spines[1].cleanedText, 'joker');
    });
    test('Hülle am Rand ist angeschnitten', () {
      final spines = groupSpines([v('THE TRIP', 2, 30), v('JOKER', 500, 30)],
          imageWidth: 1000, imageHeight: 800);
      expect(spines[0].cutOff, isTrue);
      expect(spines[1].cutOff, isFalse);
    });
    test('doppelt erkannte Zeile (zwei Drehungen) zählt einmal', () {
      final spines = groupSpines([
        v('JOKER', 200, 30),
        OcrLine(text: 'ɹǝʞoſ', box: const Box(201, 101, 229, 699), rotation: ScanRotation.ccw90, confidence: 0.2),
      ], imageWidth: 1000, imageHeight: 800);
      expect(spines.single.cleanedLines, ['joker']);
    });
  });
}

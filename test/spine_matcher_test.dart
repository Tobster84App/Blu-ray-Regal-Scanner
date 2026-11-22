import 'package:discscanner/metadata/metadata_provider.dart';
import 'package:discscanner/recognition/format_detector.dart';
import 'package:discscanner/recognition/matcher.dart';
import 'package:discscanner/recognition/models.dart';
import 'package:discscanner/recognition/spine_grouper.dart';
import 'package:discscanner/recognition/spine_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

/// Nachgebautes TMDB: liefert Treffer, wenn alle Suchwörter im Titel stehen.
class FakeProvider implements MetadataProvider {
  FakeProvider(this.catalog);
  final List<SearchHit> catalog;
  final queries = <String>[];
  @override
  String get name => 'tmdb';
  @override
  bool get isConfigured => true;
  @override
  Future<List<SearchHit>> search(String query, {required String language}) async {
    queries.add(query);
    final words = query.toLowerCase().split(' ');
    return catalog.where((h) => words.every((w) => h.title.toLowerCase().contains(w))).toList();
  }
  @override
  Future<MediaDetails> details(String id, MediaType type, {required String language}) =>
      throw UnimplementedError();
}

void main() {
  test('Ganzes Foto: Zeilen -> Hüllen -> Treffer', () async {
    final provider = FakeProvider(const [
      SearchHit(id: '1', type: MediaType.movie, title: 'John Wick', popularity: 60),
      SearchHit(id: '3', type: MediaType.movie, title: 'John Wick: Kapitel 3', popularity: 55),
      SearchHit(id: '9', type: MediaType.movie, title: 'Joker', popularity: 70),
    ]);
    OcrLine v(String t, double x) =>
        OcrLine(text: t, box: Box(x, 100, x + 30, 700), rotation: ScanRotation.ccw90);
    final spines = groupSpines([
      v('JOHN WICK', 100),
      OcrLine(text: 'KEANU REEVES', box: const Box(128, 400, 140, 600), rotation: ScanRotation.ccw90),
      OcrLine(text: '4K ULTRA HD', box: const Box(100, 20, 130, 40), rotation: ScanRotation.none),
      v('JOHN WICK', 200),
      OcrLine(text: 'KAPITEL 3', box: const Box(225, 300, 240, 500), rotation: ScanRotation.ccw90),
      v('LIONSGATE', 300),
      v('J0KER', 400),
      v('XKCD QWERTZ', 500),
    ], imageWidth: 1000, imageHeight: 800);
    final results = await SpineMatcher(provider).matchAll(spines, language: 'de-DE');
    expect(results.length, 5);
    expect(results[0].best!.id, '1');
    expect(results[0].format, DiscFormat.uhd);
    expect(results[0].status, MatchStatus.green);
    expect(results[1].best!.id, '3');
    expect(results[2].status, MatchStatus.red); // nur Studio
    expect(results[3].status, isNot(MatchStatus.green)); // "J0KER" findet die Fake-Suche nicht
    expect(results[4].status, MatchStatus.red);
  });
}

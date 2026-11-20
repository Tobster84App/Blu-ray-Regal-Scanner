import 'package:discscanner/data/collection_repository.dart';
import 'package:discscanner/data/database.dart';
import 'package:discscanner/metadata/metadata_provider.dart';
import 'package:discscanner/recognition/format_detector.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

MediaDetails details(String id, String title) => MediaDetails(
      provider: 'tmdb', id: id, type: MediaType.movie, language: 'de-DE',
      title: title, genres: const ['Action'],
    );

void main() {
  late AppDatabase db;
  late CollectionRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CollectionRepository(db);
  });
  tearDown(() => db.close());

  test('Vorhandener Titel wird nicht doppelt angelegt, Format ergänzt', () async {
    final (o1, id1) = await repo.addOrMerge(details('245891', 'John Wick'), formats: {DiscFormat.bluray});
    final (o2, id2) = await repo.addOrMerge(details('245891', 'John Wick'), formats: {DiscFormat.uhd});
    final (o3, _) = await repo.addOrMerge(details('245891', 'John Wick'), formats: {DiscFormat.uhd});
    expect(o1, AddOutcome.created);
    expect(o2, AddOutcome.merged);
    expect(o3, AddOutcome.unchanged);
    expect(id1, id2);
    final all = await repo.all();
    expect(all.length, 1);
    expect(all.single.formats, {DiscFormat.bluray, DiscFormat.uhd});
  });

  test('Film und Serie mit gleicher ID sind verschiedene Einträge', () async {
    await repo.addOrMerge(details('1', 'A'), formats: {DiscFormat.dvd});
    await repo.addOrMerge(
      const MediaDetails(provider: 'tmdb', id: '1', type: MediaType.tv, language: 'de-DE', title: 'B'),
      formats: {DiscFormat.dvd},
    );
    expect((await repo.all()).length, 2);
  });

  test('Filter und Sortierung', () async {
    await repo.addOrMerge(details('1', 'Zulu'), formats: {DiscFormat.dvd});
    await repo.addOrMerge(details('2', 'alpha'), formats: {DiscFormat.uhd});
    final all = await repo.all();
    expect(applyFilter(all, const CollectionFilter()).map((e) => e.title), ['alpha', 'Zulu']);
    expect(applyFilter(all, const CollectionFilter(format: DiscFormat.uhd)).single.title, 'alpha');
    expect(applyFilter(all, const CollectionFilter(query: 'zu')).single.title, 'Zulu');
  });
}

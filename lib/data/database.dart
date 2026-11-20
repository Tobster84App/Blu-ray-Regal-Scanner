import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Ein Eintrag pro Film oder Serie.
@DataClassName('MediaItem')
class MediaItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Herkunft der Daten (austauschbar, siehe MetadataProvider).
  TextColumn get provider => text().withDefault(const Constant('tmdb'))();
  TextColumn get externalId => text()();
  TextColumn get mediaType => text()(); // 'movie' | 'tv'
  TextColumn get language => text()(); // z. B. 'de-DE'

  // Filmdaten
  TextColumn get title => text()();
  TextColumn get originalTitle => text().nullable()();
  IntColumn get year => integer().nullable()();
  IntColumn get runtimeMinutes => integer().nullable()();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get overview => text().nullable()();
  TextColumn get certification => text().nullable()();
  RealColumn get voteAverage => real().nullable()();
  TextColumn get directorsJson => text().withDefault(const Constant('[]'))();
  TextColumn get castJson => text().withDefault(const Constant('[]'))();
  TextColumn get posterUrl => text().nullable()();
  TextColumn get backdropUrl => text().nullable()();
  TextColumn get trailerKey => text().nullable()();
  IntColumn get seasons => integer().nullable()();
  DateTimeColumn get lastFetched => dateTime()();

  // Formate (mehrfach)
  BoolColumn get hasDvd => boolean().withDefault(const Constant(false))();
  BoolColumn get hasBluray => boolean().withDefault(const Constant(false))();
  BoolColumn get hasUhd => boolean().withDefault(const Constant(false))();

  // Ausgabe
  BoolColumn get isSteelbook => boolean().withDefault(const Constant(false))();
  BoolColumn get isMediabook => boolean().withDefault(const Constant(false))();
  BoolColumn get isBoxset => boolean().withDefault(const Constant(false))();

  // Eigene Felder
  BoolColumn get watched => boolean().withDefault(const Constant(false))();
  IntColumn get userRating => integer().nullable()(); // 1–10
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  TextColumn get scanPhotoPath => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {provider, externalId, mediaType},
      ];
}

@DriftDatabase(tables: [MediaItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'discscanner'));

  @override
  int get schemaVersion => 1;
}

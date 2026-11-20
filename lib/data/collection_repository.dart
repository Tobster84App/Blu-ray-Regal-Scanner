import 'dart:convert';

import 'package:drift/drift.dart';

import '../config/app_config.dart';
import '../metadata/metadata_provider.dart';
import '../recognition/format_detector.dart';
import 'database.dart';

enum SortField { title, year, added, rating }

class CollectionFilter {
  const CollectionFilter({
    this.query = '',
    this.format,
    this.genre,
    this.watched,
    this.type,
    this.sort = SortField.title,
    this.descending = false,
  });

  final String query;
  final DiscFormat? format;
  final String? genre;
  final bool? watched;
  final MediaType? type;
  final SortField sort;
  final bool descending;

  CollectionFilter copyWith({
    String? query,
    DiscFormat? Function()? format,
    String? Function()? genre,
    bool? Function()? watched,
    MediaType? Function()? type,
    SortField? sort,
    bool? descending,
  }) =>
      CollectionFilter(
        query: query ?? this.query,
        format: format != null ? format() : this.format,
        genre: genre != null ? genre() : this.genre,
        watched: watched != null ? watched() : this.watched,
        type: type != null ? type() : this.type,
        sort: sort ?? this.sort,
        descending: descending ?? this.descending,
      );
}

enum AddOutcome { created, merged, unchanged }

extension MediaItemX on MediaItem {
  List<String> get genres =>
      (jsonDecode(genresJson) as List).cast<String>();
  List<String> get directors =>
      (jsonDecode(directorsJson) as List).cast<String>();
  List<CastMember> get cast => (jsonDecode(castJson) as List)
      .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
      .toList();
  MediaType get type => mediaTypeFromString(mediaType);
  Set<DiscFormat> get formats => {
        if (hasDvd) DiscFormat.dvd,
        if (hasBluray) DiscFormat.bluray,
        if (hasUhd) DiscFormat.uhd,
      };
  bool get isStale =>
      DateTime.now().difference(lastFetched) > metadataMaxAge;
}

/// Lese- und Schreibzugriff auf die Sammlung.
class CollectionRepository {
  CollectionRepository(this.db);
  final AppDatabase db;

  Stream<List<MediaItem>> watchAll() => db.select(db.mediaItems).watch();

  Stream<MediaItem?> watchItem(int id) =>
      (db.select(db.mediaItems)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<List<MediaItem>> all() => db.select(db.mediaItems).get();

  Future<MediaItem?> find(String provider, String externalId, MediaType type) =>
      (db.select(db.mediaItems)
            ..where((t) =>
                t.provider.equals(provider) &
                t.externalId.equals(externalId) &
                t.mediaType.equals(type.name)))
          .getSingleOrNull();

  static MediaItemsCompanion _metadataCompanion(MediaDetails d) =>
      MediaItemsCompanion(
        provider: Value(d.provider),
        externalId: Value(d.id),
        mediaType: Value(d.type.name),
        language: Value(d.language),
        title: Value(d.title),
        originalTitle: Value(d.originalTitle),
        year: Value(d.year),
        runtimeMinutes: Value(d.runtimeMinutes),
        genresJson: Value(jsonEncode(d.genres)),
        overview: Value(d.overview),
        certification: Value(d.certification),
        voteAverage: Value(d.voteAverage),
        directorsJson: Value(jsonEncode(d.directors)),
        castJson: Value(jsonEncode(d.cast.map((c) => c.toJson()).toList())),
        posterUrl: Value(d.posterUrl),
        backdropUrl: Value(d.backdropUrl),
        trailerKey: Value(d.youtubeTrailerKey),
        seasons: Value(d.seasons),
        lastFetched: Value(DateTime.now()),
      );

  /// Legt einen Eintrag an oder ergänzt beim vorhandenen nur das Format.
  Future<(AddOutcome, int)> addOrMerge(
    MediaDetails details, {
    required Set<DiscFormat> formats,
    String? scanPhotoPath,
  }) async {
    final existing = await find(details.provider, details.id, details.type);
    if (existing != null) {
      final newFormats = {...existing.formats, ...formats};
      if (newFormats.length == existing.formats.length) {
        return (AddOutcome.unchanged, existing.id);
      }
      await (db.update(db.mediaItems)..where((t) => t.id.equals(existing.id)))
          .write(MediaItemsCompanion(
        hasDvd: Value(newFormats.contains(DiscFormat.dvd)),
        hasBluray: Value(newFormats.contains(DiscFormat.bluray)),
        hasUhd: Value(newFormats.contains(DiscFormat.uhd)),
      ));
      return (AddOutcome.merged, existing.id);
    }
    final id = await db.into(db.mediaItems).insert(
          _metadataCompanion(details).copyWith(
            hasDvd: Value(formats.contains(DiscFormat.dvd)),
            hasBluray: Value(formats.contains(DiscFormat.bluray)),
            hasUhd: Value(formats.contains(DiscFormat.uhd)),
            addedAt: Value(DateTime.now()),
            scanPhotoPath: Value(scanPhotoPath),
          ),
        );
    return (AddOutcome.created, id);
  }

  /// Ersetzt nur die Filmdaten (eigene Felder bleiben).
  Future<void> updateMetadata(int id, MediaDetails details) =>
      (db.update(db.mediaItems)..where((t) => t.id.equals(id)))
          .write(_metadataCompanion(details));

  Future<void> updateFields(int id, MediaItemsCompanion fields) =>
      (db.update(db.mediaItems)..where((t) => t.id.equals(id))).write(fields);

  Future<void> delete(int id) =>
      (db.delete(db.mediaItems)..where((t) => t.id.equals(id))).go();

  /// Lädt Filmdaten neu: alle älteren als [olderThan] oder alle, wenn null.
  /// Gibt die Anzahl der aktualisierten Einträge zurück.
  Future<int> refresh(
    MetadataProvider provider, {
    required String language,
    Duration? olderThan,
    void Function(int done, int total)? onProgress,
  }) async {
    var items = await all();
    items = items.where((i) => i.provider == provider.name).toList();
    if (olderThan != null) {
      items = items
          .where((i) => DateTime.now().difference(i.lastFetched) > olderThan)
          .toList();
    }
    var done = 0;
    for (final i in items) {
      try {
        final d = await provider.details(i.externalId, i.type,
            language: language);
        await updateMetadata(i.id, d);
      } on Exception {
        // Einzelne Fehler überspringen, nächster Versuch beim nächsten Start.
      }
      done++;
      onProgress?.call(done, items.length);
    }
    return done;
  }
}

/// Filtert und sortiert im Speicher (Sammlungen mit einigen tausend Titeln
/// sind dafür klein genug).
List<MediaItem> applyFilter(List<MediaItem> items, CollectionFilter f) {
  final q = f.query.trim().toLowerCase();
  final out = items.where((i) {
    if (q.isNotEmpty &&
        !i.title.toLowerCase().contains(q) &&
        !(i.originalTitle?.toLowerCase().contains(q) ?? false)) {
      return false;
    }
    if (f.format != null && !i.formats.contains(f.format)) return false;
    if (f.genre != null && !i.genres.contains(f.genre)) return false;
    if (f.watched != null && i.watched != f.watched) return false;
    if (f.type != null && i.type != f.type) return false;
    return true;
  }).toList();
  int cmp(MediaItem a, MediaItem b) {
    switch (f.sort) {
      case SortField.title:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      case SortField.year:
        return (a.year ?? 0).compareTo(b.year ?? 0);
      case SortField.added:
        return a.addedAt.compareTo(b.addedAt);
      case SortField.rating:
        return (a.userRating ?? 0).compareTo(b.userRating ?? 0);
    }
  }

  out.sort(f.descending ? (a, b) => cmp(b, a) : cmp);
  return out;
}

/// Austauschbare Datenquelle für Filmdaten.
///
/// Ein späterer Wechsel (z. B. zu Wikidata) braucht nur eine neue
/// Implementierung dieses Interfaces.
library;

enum MediaType { movie, tv }

MediaType mediaTypeFromString(String s) =>
    s == 'tv' ? MediaType.tv : MediaType.movie;

/// Ein Suchtreffer (kurz, für die Auswahl).
class SearchHit {
  const SearchHit({
    required this.id,
    required this.type,
    required this.title,
    this.originalTitle,
    this.year,
    this.posterUrl,
    this.popularity,
  });

  final String id;
  final MediaType type;
  final String title;
  final String? originalTitle;
  final int? year;
  final String? posterUrl;
  final double? popularity;

  String get key => '${type.name}:$id';

  String get label => year == null ? title : '$title ($year)';
}

class CastMember {
  const CastMember({required this.name, this.character, this.profileUrl});
  final String name;
  final String? character;
  final String? profileUrl;

  Map<String, dynamic> toJson() =>
      {'name': name, 'character': character, 'profileUrl': profileUrl};

  static CastMember fromJson(Map<String, dynamic> j) => CastMember(
        name: j['name'] as String,
        character: j['character'] as String?,
        profileUrl: j['profileUrl'] as String?,
      );
}

/// Vollständige Daten eines Films oder einer Serie.
class MediaDetails {
  const MediaDetails({
    required this.provider,
    required this.id,
    required this.type,
    required this.language,
    required this.title,
    this.originalTitle,
    this.year,
    this.runtimeMinutes,
    this.genres = const [],
    this.overview,
    this.certification,
    this.voteAverage,
    this.directors = const [],
    this.cast = const [],
    this.posterUrl,
    this.backdropUrl,
    this.youtubeTrailerKey,
    this.seasons,
  });

  final String provider;
  final String id;
  final MediaType type;

  /// Sprache der Daten, z. B. `de-DE`.
  final String language;
  final String title;
  final String? originalTitle;
  final int? year;
  final int? runtimeMinutes;
  final List<String> genres;
  final String? overview;

  /// z. B. „FSK 12“ (DE) oder „PG-13“ (US).
  final String? certification;
  final double? voteAverage;
  final List<String> directors;
  final List<CastMember> cast;
  final String? posterUrl;
  final String? backdropUrl;
  final String? youtubeTrailerKey;
  final int? seasons;
}

class MetadataException implements Exception {
  MetadataException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'MetadataException($statusCode): $message';
}

abstract class MetadataProvider {
  /// Kurzname, wird mit jedem Eintrag gespeichert (z. B. `tmdb`).
  String get name;

  bool get isConfigured;

  /// Sucht Filme UND Serien.
  Future<List<SearchHit>> search(String query, {required String language});

  Future<MediaDetails> details(
    String id,
    MediaType type, {
    required String language,
  });
}

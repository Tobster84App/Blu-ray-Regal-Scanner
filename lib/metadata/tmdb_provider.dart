import 'dart:convert';

import 'package:http/http.dart' as http;

import 'metadata_provider.dart';

/// Filmdaten von The Movie Database (TMDB).
///
/// Akzeptiert sowohl den v3-API-Schlüssel als auch das v4-Lesezugriffstoken
/// („API Read Access Token“, beginnt mit `eyJ`).
class TmdbProvider implements MetadataProvider {
  TmdbProvider({required String Function() apiKey, http.Client? client})
      : _apiKey = apiKey, // ignore: prefer_initializing_formals
        _client = client ?? http.Client();

  final String Function() _apiKey;
  final http.Client _client;
  final Map<String, List<SearchHit>> _searchCache = {};

  static const _base = 'api.themoviedb.org';
  static const imageBase = 'https://image.tmdb.org/t/p/';

  @override
  String get name => 'tmdb';

  @override
  bool get isConfigured => _apiKey().trim().isNotEmpty;

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> params,
  ) async {
    final key = _apiKey().trim();
    if (key.isEmpty) throw MetadataException('Kein TMDB-Schlüssel');
    final isBearer = key.startsWith('eyJ');
    final uri = Uri.https(_base, '/3$path', {
      ...params,
      if (!isBearer) 'api_key': key,
    });
    final res = await _client.get(uri, headers: {
      'Accept': 'application/json',
      if (isBearer) 'Authorization': 'Bearer $key',
    }).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw MetadataException(
        'TMDB ${res.statusCode}: ${res.body.length > 200 ? res.body.substring(0, 200) : res.body}',
        statusCode: res.statusCode,
      );
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static int? _year(String? date) =>
      (date == null || date.length < 4) ? null : int.tryParse(date.substring(0, 4));

  static String? _img(String? path, String size) =>
      (path == null || path.isEmpty) ? null : '$imageBase$size$path';

  @override
  Future<List<SearchHit>> search(String query, {required String language}) async {
    final cacheKey = '$language|$query';
    final cached = _searchCache[cacheKey];
    if (cached != null) return cached;
    final json = await _get('/search/multi', {
      'query': query,
      'language': language,
      'include_adult': 'false',
    });
    final hits = <SearchHit>[];
    for (final r in (json['results'] as List? ?? const [])) {
      final m = r as Map<String, dynamic>;
      final mt = m['media_type'];
      if (mt != 'movie' && mt != 'tv') continue;
      final isTv = mt == 'tv';
      hits.add(SearchHit(
        id: '${m['id']}',
        type: isTv ? MediaType.tv : MediaType.movie,
        title: (isTv ? m['name'] : m['title']) as String? ?? '',
        originalTitle: (isTv ? m['original_name'] : m['original_title']) as String?,
        year: _year((isTv ? m['first_air_date'] : m['release_date']) as String?),
        posterUrl: _img(m['poster_path'] as String?, 'w185'),
        popularity: (m['popularity'] as num?)?.toDouble(),
      ));
    }
    _searchCache[cacheKey] = hits;
    return hits;
  }

  @override
  Future<MediaDetails> details(
    String id,
    MediaType type, {
    required String language,
  }) async {
    final lang2 = language.split('-').first;
    final country = language.contains('-') ? language.split('-').last : 'US';
    final isTv = type == MediaType.tv;
    final json = await _get('/${isTv ? 'tv' : 'movie'}/$id', {
      'language': language,
      'append_to_response':
          isTv ? 'credits,videos,content_ratings' : 'credits,videos,release_dates',
      'include_video_language': '$lang2,en,null',
    });
    return parseDetails(json, type: type, language: language, country: country);
  }

  /// Öffentlich für Tests.
  static MediaDetails parseDetails(
    Map<String, dynamic> j, {
    required MediaType type,
    required String language,
    required String country,
  }) {
    final isTv = type == MediaType.tv;
    final lang2 = language.split('-').first;

    final credits = j['credits'] as Map<String, dynamic>? ?? const {};
    final castList = (credits['cast'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .take(10)
        .map((c) => CastMember(
              name: c['name'] as String? ?? '',
              character: c['character'] as String?,
              profileUrl: _img(c['profile_path'] as String?, 'w185'),
            ))
        .toList();

    List<String> directors;
    if (isTv) {
      directors = (j['created_by'] as List? ?? const [])
          .map((c) => (c as Map<String, dynamic>)['name'] as String)
          .toList();
    } else {
      directors = (credits['crew'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .where((c) => c['job'] == 'Director')
          .map((c) => c['name'] as String)
          .toList();
    }

    int? runtime;
    if (isTv) {
      final rt = j['episode_run_time'] as List?;
      if (rt != null && rt.isNotEmpty) runtime = (rt.first as num).toInt();
    } else {
      runtime = (j['runtime'] as num?)?.toInt();
      if (runtime == 0) runtime = null;
    }

    return MediaDetails(
      provider: 'tmdb',
      id: '${j['id']}',
      type: type,
      language: language,
      title: (isTv ? j['name'] : j['title']) as String? ?? '',
      originalTitle: (isTv ? j['original_name'] : j['original_title']) as String?,
      year: _year((isTv ? j['first_air_date'] : j['release_date']) as String?),
      runtimeMinutes: runtime,
      genres: (j['genres'] as List? ?? const [])
          .map((g) => (g as Map<String, dynamic>)['name'] as String)
          .toList(),
      overview: (j['overview'] as String?)?.trim().isEmpty ?? true
          ? null
          : (j['overview'] as String).trim(),
      certification: _certification(j, isTv: isTv, country: country),
      voteAverage: (j['vote_average'] as num?)?.toDouble(),
      directors: directors,
      cast: castList,
      posterUrl: _img(j['poster_path'] as String?, 'w500'),
      backdropUrl: _img(j['backdrop_path'] as String?, 'w1280'),
      youtubeTrailerKey: pickTrailer(
        (j['videos'] as Map<String, dynamic>?)?['results'] as List? ?? const [],
        lang2,
      ),
      seasons: isTv ? (j['number_of_seasons'] as num?)?.toInt() : null,
    );
  }

  static String? _certification(
    Map<String, dynamic> j, {
    required bool isTv,
    required String country,
  }) {
    String? raw;
    if (isTv) {
      final list = (j['content_ratings'] as Map?)?['results'] as List? ?? const [];
      for (final r in list.cast<Map<String, dynamic>>()) {
        if (r['iso_3166_1'] == country) raw = r['rating'] as String?;
      }
    } else {
      final list = (j['release_dates'] as Map?)?['results'] as List? ?? const [];
      for (final r in list.cast<Map<String, dynamic>>()) {
        if (r['iso_3166_1'] != country) continue;
        for (final d in (r['release_dates'] as List).cast<Map<String, dynamic>>()) {
          final c = (d['certification'] as String?)?.trim() ?? '';
          if (c.isNotEmpty) {
            raw = c;
            break;
          }
        }
      }
    }
    if (raw == null || raw.isEmpty) return null;
    if (country == 'DE' && RegExp(r'^\d+$').hasMatch(raw)) return 'FSK $raw';
    return raw;
  }

  /// YouTube-Trailer: bevorzugt App-Sprache, dann Englisch, dann irgendeiner;
  /// offizielle Trailer vor Teasern.
  static String? pickTrailer(List videos, String lang2) {
    final yt = videos
        .cast<Map<String, dynamic>>()
        .where((v) => v['site'] == 'YouTube' && v['key'] != null)
        .toList();
    if (yt.isEmpty) return null;
    final trailers =
        yt.where((v) => v['type'] == 'Trailer' || v['type'] == 'Teaser').toList();
    if (trailers.isNotEmpty) {
      yt
        ..clear()
        ..addAll(trailers);
    }
    int rank(Map<String, dynamic> v) {
      var r = 0;
      if (v['iso_639_1'] == lang2) {
        r += 100;
      } else if (v['iso_639_1'] == 'en') {
        r += 50;
      }
      if (v['type'] == 'Trailer') {
        r += 20;
      } else if (v['type'] == 'Teaser') {
        r += 10;
      }
      if (v['official'] == true) r += 5;
      return r;
    }

    yt.sort((a, b) => rank(b).compareTo(rank(a)));
    return yt.first['key'] as String;
  }
}

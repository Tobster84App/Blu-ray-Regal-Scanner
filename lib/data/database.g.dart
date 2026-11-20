// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tmdb'),
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalTitleMeta = const VerificationMeta(
    'originalTitle',
  );
  @override
  late final GeneratedColumn<String> originalTitle = GeneratedColumn<String>(
    'original_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runtimeMinutesMeta = const VerificationMeta(
    'runtimeMinutes',
  );
  @override
  late final GeneratedColumn<int> runtimeMinutes = GeneratedColumn<int>(
    'runtime_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresJsonMeta = const VerificationMeta(
    'genresJson',
  );
  @override
  late final GeneratedColumn<String> genresJson = GeneratedColumn<String>(
    'genres_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _overviewMeta = const VerificationMeta(
    'overview',
  );
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
    'overview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _certificationMeta = const VerificationMeta(
    'certification',
  );
  @override
  late final GeneratedColumn<String> certification = GeneratedColumn<String>(
    'certification',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voteAverageMeta = const VerificationMeta(
    'voteAverage',
  );
  @override
  late final GeneratedColumn<double> voteAverage = GeneratedColumn<double>(
    'vote_average',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directorsJsonMeta = const VerificationMeta(
    'directorsJson',
  );
  @override
  late final GeneratedColumn<String> directorsJson = GeneratedColumn<String>(
    'directors_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _castJsonMeta = const VerificationMeta(
    'castJson',
  );
  @override
  late final GeneratedColumn<String> castJson = GeneratedColumn<String>(
    'cast_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _posterUrlMeta = const VerificationMeta(
    'posterUrl',
  );
  @override
  late final GeneratedColumn<String> posterUrl = GeneratedColumn<String>(
    'poster_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backdropUrlMeta = const VerificationMeta(
    'backdropUrl',
  );
  @override
  late final GeneratedColumn<String> backdropUrl = GeneratedColumn<String>(
    'backdrop_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trailerKeyMeta = const VerificationMeta(
    'trailerKey',
  );
  @override
  late final GeneratedColumn<String> trailerKey = GeneratedColumn<String>(
    'trailer_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonsMeta = const VerificationMeta(
    'seasons',
  );
  @override
  late final GeneratedColumn<int> seasons = GeneratedColumn<int>(
    'seasons',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetched = GeneratedColumn<DateTime>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasDvdMeta = const VerificationMeta('hasDvd');
  @override
  late final GeneratedColumn<bool> hasDvd = GeneratedColumn<bool>(
    'has_dvd',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_dvd" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasBlurayMeta = const VerificationMeta(
    'hasBluray',
  );
  @override
  late final GeneratedColumn<bool> hasBluray = GeneratedColumn<bool>(
    'has_bluray',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_bluray" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasUhdMeta = const VerificationMeta('hasUhd');
  @override
  late final GeneratedColumn<bool> hasUhd = GeneratedColumn<bool>(
    'has_uhd',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_uhd" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSteelbookMeta = const VerificationMeta(
    'isSteelbook',
  );
  @override
  late final GeneratedColumn<bool> isSteelbook = GeneratedColumn<bool>(
    'is_steelbook',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_steelbook" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isMediabookMeta = const VerificationMeta(
    'isMediabook',
  );
  @override
  late final GeneratedColumn<bool> isMediabook = GeneratedColumn<bool>(
    'is_mediabook',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mediabook" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isBoxsetMeta = const VerificationMeta(
    'isBoxset',
  );
  @override
  late final GeneratedColumn<bool> isBoxset = GeneratedColumn<bool>(
    'is_boxset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_boxset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _watchedMeta = const VerificationMeta(
    'watched',
  );
  @override
  late final GeneratedColumn<bool> watched = GeneratedColumn<bool>(
    'watched',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("watched" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userRatingMeta = const VerificationMeta(
    'userRating',
  );
  @override
  late final GeneratedColumn<int> userRating = GeneratedColumn<int>(
    'user_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scanPhotoPathMeta = const VerificationMeta(
    'scanPhotoPath',
  );
  @override
  late final GeneratedColumn<String> scanPhotoPath = GeneratedColumn<String>(
    'scan_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    provider,
    externalId,
    mediaType,
    language,
    title,
    originalTitle,
    year,
    runtimeMinutes,
    genresJson,
    overview,
    certification,
    voteAverage,
    directorsJson,
    castJson,
    posterUrl,
    backdropUrl,
    trailerKey,
    seasons,
    lastFetched,
    hasDvd,
    hasBluray,
    hasUhd,
    isSteelbook,
    isMediabook,
    isBoxset,
    watched,
    userRating,
    location,
    notes,
    addedAt,
    scanPhotoPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('original_title')) {
      context.handle(
        _originalTitleMeta,
        originalTitle.isAcceptableOrUnknown(
          data['original_title']!,
          _originalTitleMeta,
        ),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('runtime_minutes')) {
      context.handle(
        _runtimeMinutesMeta,
        runtimeMinutes.isAcceptableOrUnknown(
          data['runtime_minutes']!,
          _runtimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('genres_json')) {
      context.handle(
        _genresJsonMeta,
        genresJson.isAcceptableOrUnknown(data['genres_json']!, _genresJsonMeta),
      );
    }
    if (data.containsKey('overview')) {
      context.handle(
        _overviewMeta,
        overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta),
      );
    }
    if (data.containsKey('certification')) {
      context.handle(
        _certificationMeta,
        certification.isAcceptableOrUnknown(
          data['certification']!,
          _certificationMeta,
        ),
      );
    }
    if (data.containsKey('vote_average')) {
      context.handle(
        _voteAverageMeta,
        voteAverage.isAcceptableOrUnknown(
          data['vote_average']!,
          _voteAverageMeta,
        ),
      );
    }
    if (data.containsKey('directors_json')) {
      context.handle(
        _directorsJsonMeta,
        directorsJson.isAcceptableOrUnknown(
          data['directors_json']!,
          _directorsJsonMeta,
        ),
      );
    }
    if (data.containsKey('cast_json')) {
      context.handle(
        _castJsonMeta,
        castJson.isAcceptableOrUnknown(data['cast_json']!, _castJsonMeta),
      );
    }
    if (data.containsKey('poster_url')) {
      context.handle(
        _posterUrlMeta,
        posterUrl.isAcceptableOrUnknown(data['poster_url']!, _posterUrlMeta),
      );
    }
    if (data.containsKey('backdrop_url')) {
      context.handle(
        _backdropUrlMeta,
        backdropUrl.isAcceptableOrUnknown(
          data['backdrop_url']!,
          _backdropUrlMeta,
        ),
      );
    }
    if (data.containsKey('trailer_key')) {
      context.handle(
        _trailerKeyMeta,
        trailerKey.isAcceptableOrUnknown(data['trailer_key']!, _trailerKeyMeta),
      );
    }
    if (data.containsKey('seasons')) {
      context.handle(
        _seasonsMeta,
        seasons.isAcceptableOrUnknown(data['seasons']!, _seasonsMeta),
      );
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastFetchedMeta);
    }
    if (data.containsKey('has_dvd')) {
      context.handle(
        _hasDvdMeta,
        hasDvd.isAcceptableOrUnknown(data['has_dvd']!, _hasDvdMeta),
      );
    }
    if (data.containsKey('has_bluray')) {
      context.handle(
        _hasBlurayMeta,
        hasBluray.isAcceptableOrUnknown(data['has_bluray']!, _hasBlurayMeta),
      );
    }
    if (data.containsKey('has_uhd')) {
      context.handle(
        _hasUhdMeta,
        hasUhd.isAcceptableOrUnknown(data['has_uhd']!, _hasUhdMeta),
      );
    }
    if (data.containsKey('is_steelbook')) {
      context.handle(
        _isSteelbookMeta,
        isSteelbook.isAcceptableOrUnknown(
          data['is_steelbook']!,
          _isSteelbookMeta,
        ),
      );
    }
    if (data.containsKey('is_mediabook')) {
      context.handle(
        _isMediabookMeta,
        isMediabook.isAcceptableOrUnknown(
          data['is_mediabook']!,
          _isMediabookMeta,
        ),
      );
    }
    if (data.containsKey('is_boxset')) {
      context.handle(
        _isBoxsetMeta,
        isBoxset.isAcceptableOrUnknown(data['is_boxset']!, _isBoxsetMeta),
      );
    }
    if (data.containsKey('watched')) {
      context.handle(
        _watchedMeta,
        watched.isAcceptableOrUnknown(data['watched']!, _watchedMeta),
      );
    }
    if (data.containsKey('user_rating')) {
      context.handle(
        _userRatingMeta,
        userRating.isAcceptableOrUnknown(data['user_rating']!, _userRatingMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('scan_photo_path')) {
      context.handle(
        _scanPhotoPathMeta,
        scanPhotoPath.isAcceptableOrUnknown(
          data['scan_photo_path']!,
          _scanPhotoPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {provider, externalId, mediaType},
  ];
  @override
  MediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      originalTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_title'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      runtimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runtime_minutes'],
      ),
      genresJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres_json'],
      )!,
      overview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overview'],
      ),
      certification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}certification'],
      ),
      voteAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vote_average'],
      ),
      directorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}directors_json'],
      )!,
      castJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cast_json'],
      )!,
      posterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_url'],
      ),
      backdropUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backdrop_url'],
      ),
      trailerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trailer_key'],
      ),
      seasons: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seasons'],
      ),
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched'],
      )!,
      hasDvd: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_dvd'],
      )!,
      hasBluray: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_bluray'],
      )!,
      hasUhd: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_uhd'],
      )!,
      isSteelbook: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_steelbook'],
      )!,
      isMediabook: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mediabook'],
      )!,
      isBoxset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_boxset'],
      )!,
      watched: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}watched'],
      )!,
      userRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_rating'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      scanPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_photo_path'],
      ),
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final int id;
  final String provider;
  final String externalId;
  final String mediaType;
  final String language;
  final String title;
  final String? originalTitle;
  final int? year;
  final int? runtimeMinutes;
  final String genresJson;
  final String? overview;
  final String? certification;
  final double? voteAverage;
  final String directorsJson;
  final String castJson;
  final String? posterUrl;
  final String? backdropUrl;
  final String? trailerKey;
  final int? seasons;
  final DateTime lastFetched;
  final bool hasDvd;
  final bool hasBluray;
  final bool hasUhd;
  final bool isSteelbook;
  final bool isMediabook;
  final bool isBoxset;
  final bool watched;
  final int? userRating;
  final String? location;
  final String? notes;
  final DateTime addedAt;
  final String? scanPhotoPath;
  const MediaItem({
    required this.id,
    required this.provider,
    required this.externalId,
    required this.mediaType,
    required this.language,
    required this.title,
    this.originalTitle,
    this.year,
    this.runtimeMinutes,
    required this.genresJson,
    this.overview,
    this.certification,
    this.voteAverage,
    required this.directorsJson,
    required this.castJson,
    this.posterUrl,
    this.backdropUrl,
    this.trailerKey,
    this.seasons,
    required this.lastFetched,
    required this.hasDvd,
    required this.hasBluray,
    required this.hasUhd,
    required this.isSteelbook,
    required this.isMediabook,
    required this.isBoxset,
    required this.watched,
    this.userRating,
    this.location,
    this.notes,
    required this.addedAt,
    this.scanPhotoPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider'] = Variable<String>(provider);
    map['external_id'] = Variable<String>(externalId);
    map['media_type'] = Variable<String>(mediaType);
    map['language'] = Variable<String>(language);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || originalTitle != null) {
      map['original_title'] = Variable<String>(originalTitle);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || runtimeMinutes != null) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes);
    }
    map['genres_json'] = Variable<String>(genresJson);
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    if (!nullToAbsent || certification != null) {
      map['certification'] = Variable<String>(certification);
    }
    if (!nullToAbsent || voteAverage != null) {
      map['vote_average'] = Variable<double>(voteAverage);
    }
    map['directors_json'] = Variable<String>(directorsJson);
    map['cast_json'] = Variable<String>(castJson);
    if (!nullToAbsent || posterUrl != null) {
      map['poster_url'] = Variable<String>(posterUrl);
    }
    if (!nullToAbsent || backdropUrl != null) {
      map['backdrop_url'] = Variable<String>(backdropUrl);
    }
    if (!nullToAbsent || trailerKey != null) {
      map['trailer_key'] = Variable<String>(trailerKey);
    }
    if (!nullToAbsent || seasons != null) {
      map['seasons'] = Variable<int>(seasons);
    }
    map['last_fetched'] = Variable<DateTime>(lastFetched);
    map['has_dvd'] = Variable<bool>(hasDvd);
    map['has_bluray'] = Variable<bool>(hasBluray);
    map['has_uhd'] = Variable<bool>(hasUhd);
    map['is_steelbook'] = Variable<bool>(isSteelbook);
    map['is_mediabook'] = Variable<bool>(isMediabook);
    map['is_boxset'] = Variable<bool>(isBoxset);
    map['watched'] = Variable<bool>(watched);
    if (!nullToAbsent || userRating != null) {
      map['user_rating'] = Variable<int>(userRating);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || scanPhotoPath != null) {
      map['scan_photo_path'] = Variable<String>(scanPhotoPath);
    }
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      id: Value(id),
      provider: Value(provider),
      externalId: Value(externalId),
      mediaType: Value(mediaType),
      language: Value(language),
      title: Value(title),
      originalTitle: originalTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(originalTitle),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      runtimeMinutes: runtimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(runtimeMinutes),
      genresJson: Value(genresJson),
      overview: overview == null && nullToAbsent
          ? const Value.absent()
          : Value(overview),
      certification: certification == null && nullToAbsent
          ? const Value.absent()
          : Value(certification),
      voteAverage: voteAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(voteAverage),
      directorsJson: Value(directorsJson),
      castJson: Value(castJson),
      posterUrl: posterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(posterUrl),
      backdropUrl: backdropUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(backdropUrl),
      trailerKey: trailerKey == null && nullToAbsent
          ? const Value.absent()
          : Value(trailerKey),
      seasons: seasons == null && nullToAbsent
          ? const Value.absent()
          : Value(seasons),
      lastFetched: Value(lastFetched),
      hasDvd: Value(hasDvd),
      hasBluray: Value(hasBluray),
      hasUhd: Value(hasUhd),
      isSteelbook: Value(isSteelbook),
      isMediabook: Value(isMediabook),
      isBoxset: Value(isBoxset),
      watched: Value(watched),
      userRating: userRating == null && nullToAbsent
          ? const Value.absent()
          : Value(userRating),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      addedAt: Value(addedAt),
      scanPhotoPath: scanPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(scanPhotoPath),
    );
  }

  factory MediaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItem(
      id: serializer.fromJson<int>(json['id']),
      provider: serializer.fromJson<String>(json['provider']),
      externalId: serializer.fromJson<String>(json['externalId']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      language: serializer.fromJson<String>(json['language']),
      title: serializer.fromJson<String>(json['title']),
      originalTitle: serializer.fromJson<String?>(json['originalTitle']),
      year: serializer.fromJson<int?>(json['year']),
      runtimeMinutes: serializer.fromJson<int?>(json['runtimeMinutes']),
      genresJson: serializer.fromJson<String>(json['genresJson']),
      overview: serializer.fromJson<String?>(json['overview']),
      certification: serializer.fromJson<String?>(json['certification']),
      voteAverage: serializer.fromJson<double?>(json['voteAverage']),
      directorsJson: serializer.fromJson<String>(json['directorsJson']),
      castJson: serializer.fromJson<String>(json['castJson']),
      posterUrl: serializer.fromJson<String?>(json['posterUrl']),
      backdropUrl: serializer.fromJson<String?>(json['backdropUrl']),
      trailerKey: serializer.fromJson<String?>(json['trailerKey']),
      seasons: serializer.fromJson<int?>(json['seasons']),
      lastFetched: serializer.fromJson<DateTime>(json['lastFetched']),
      hasDvd: serializer.fromJson<bool>(json['hasDvd']),
      hasBluray: serializer.fromJson<bool>(json['hasBluray']),
      hasUhd: serializer.fromJson<bool>(json['hasUhd']),
      isSteelbook: serializer.fromJson<bool>(json['isSteelbook']),
      isMediabook: serializer.fromJson<bool>(json['isMediabook']),
      isBoxset: serializer.fromJson<bool>(json['isBoxset']),
      watched: serializer.fromJson<bool>(json['watched']),
      userRating: serializer.fromJson<int?>(json['userRating']),
      location: serializer.fromJson<String?>(json['location']),
      notes: serializer.fromJson<String?>(json['notes']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      scanPhotoPath: serializer.fromJson<String?>(json['scanPhotoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'provider': serializer.toJson<String>(provider),
      'externalId': serializer.toJson<String>(externalId),
      'mediaType': serializer.toJson<String>(mediaType),
      'language': serializer.toJson<String>(language),
      'title': serializer.toJson<String>(title),
      'originalTitle': serializer.toJson<String?>(originalTitle),
      'year': serializer.toJson<int?>(year),
      'runtimeMinutes': serializer.toJson<int?>(runtimeMinutes),
      'genresJson': serializer.toJson<String>(genresJson),
      'overview': serializer.toJson<String?>(overview),
      'certification': serializer.toJson<String?>(certification),
      'voteAverage': serializer.toJson<double?>(voteAverage),
      'directorsJson': serializer.toJson<String>(directorsJson),
      'castJson': serializer.toJson<String>(castJson),
      'posterUrl': serializer.toJson<String?>(posterUrl),
      'backdropUrl': serializer.toJson<String?>(backdropUrl),
      'trailerKey': serializer.toJson<String?>(trailerKey),
      'seasons': serializer.toJson<int?>(seasons),
      'lastFetched': serializer.toJson<DateTime>(lastFetched),
      'hasDvd': serializer.toJson<bool>(hasDvd),
      'hasBluray': serializer.toJson<bool>(hasBluray),
      'hasUhd': serializer.toJson<bool>(hasUhd),
      'isSteelbook': serializer.toJson<bool>(isSteelbook),
      'isMediabook': serializer.toJson<bool>(isMediabook),
      'isBoxset': serializer.toJson<bool>(isBoxset),
      'watched': serializer.toJson<bool>(watched),
      'userRating': serializer.toJson<int?>(userRating),
      'location': serializer.toJson<String?>(location),
      'notes': serializer.toJson<String?>(notes),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'scanPhotoPath': serializer.toJson<String?>(scanPhotoPath),
    };
  }

  MediaItem copyWith({
    int? id,
    String? provider,
    String? externalId,
    String? mediaType,
    String? language,
    String? title,
    Value<String?> originalTitle = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<int?> runtimeMinutes = const Value.absent(),
    String? genresJson,
    Value<String?> overview = const Value.absent(),
    Value<String?> certification = const Value.absent(),
    Value<double?> voteAverage = const Value.absent(),
    String? directorsJson,
    String? castJson,
    Value<String?> posterUrl = const Value.absent(),
    Value<String?> backdropUrl = const Value.absent(),
    Value<String?> trailerKey = const Value.absent(),
    Value<int?> seasons = const Value.absent(),
    DateTime? lastFetched,
    bool? hasDvd,
    bool? hasBluray,
    bool? hasUhd,
    bool? isSteelbook,
    bool? isMediabook,
    bool? isBoxset,
    bool? watched,
    Value<int?> userRating = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? addedAt,
    Value<String?> scanPhotoPath = const Value.absent(),
  }) => MediaItem(
    id: id ?? this.id,
    provider: provider ?? this.provider,
    externalId: externalId ?? this.externalId,
    mediaType: mediaType ?? this.mediaType,
    language: language ?? this.language,
    title: title ?? this.title,
    originalTitle: originalTitle.present
        ? originalTitle.value
        : this.originalTitle,
    year: year.present ? year.value : this.year,
    runtimeMinutes: runtimeMinutes.present
        ? runtimeMinutes.value
        : this.runtimeMinutes,
    genresJson: genresJson ?? this.genresJson,
    overview: overview.present ? overview.value : this.overview,
    certification: certification.present
        ? certification.value
        : this.certification,
    voteAverage: voteAverage.present ? voteAverage.value : this.voteAverage,
    directorsJson: directorsJson ?? this.directorsJson,
    castJson: castJson ?? this.castJson,
    posterUrl: posterUrl.present ? posterUrl.value : this.posterUrl,
    backdropUrl: backdropUrl.present ? backdropUrl.value : this.backdropUrl,
    trailerKey: trailerKey.present ? trailerKey.value : this.trailerKey,
    seasons: seasons.present ? seasons.value : this.seasons,
    lastFetched: lastFetched ?? this.lastFetched,
    hasDvd: hasDvd ?? this.hasDvd,
    hasBluray: hasBluray ?? this.hasBluray,
    hasUhd: hasUhd ?? this.hasUhd,
    isSteelbook: isSteelbook ?? this.isSteelbook,
    isMediabook: isMediabook ?? this.isMediabook,
    isBoxset: isBoxset ?? this.isBoxset,
    watched: watched ?? this.watched,
    userRating: userRating.present ? userRating.value : this.userRating,
    location: location.present ? location.value : this.location,
    notes: notes.present ? notes.value : this.notes,
    addedAt: addedAt ?? this.addedAt,
    scanPhotoPath: scanPhotoPath.present
        ? scanPhotoPath.value
        : this.scanPhotoPath,
  );
  MediaItem copyWithCompanion(MediaItemsCompanion data) {
    return MediaItem(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      language: data.language.present ? data.language.value : this.language,
      title: data.title.present ? data.title.value : this.title,
      originalTitle: data.originalTitle.present
          ? data.originalTitle.value
          : this.originalTitle,
      year: data.year.present ? data.year.value : this.year,
      runtimeMinutes: data.runtimeMinutes.present
          ? data.runtimeMinutes.value
          : this.runtimeMinutes,
      genresJson: data.genresJson.present
          ? data.genresJson.value
          : this.genresJson,
      overview: data.overview.present ? data.overview.value : this.overview,
      certification: data.certification.present
          ? data.certification.value
          : this.certification,
      voteAverage: data.voteAverage.present
          ? data.voteAverage.value
          : this.voteAverage,
      directorsJson: data.directorsJson.present
          ? data.directorsJson.value
          : this.directorsJson,
      castJson: data.castJson.present ? data.castJson.value : this.castJson,
      posterUrl: data.posterUrl.present ? data.posterUrl.value : this.posterUrl,
      backdropUrl: data.backdropUrl.present
          ? data.backdropUrl.value
          : this.backdropUrl,
      trailerKey: data.trailerKey.present
          ? data.trailerKey.value
          : this.trailerKey,
      seasons: data.seasons.present ? data.seasons.value : this.seasons,
      lastFetched: data.lastFetched.present
          ? data.lastFetched.value
          : this.lastFetched,
      hasDvd: data.hasDvd.present ? data.hasDvd.value : this.hasDvd,
      hasBluray: data.hasBluray.present ? data.hasBluray.value : this.hasBluray,
      hasUhd: data.hasUhd.present ? data.hasUhd.value : this.hasUhd,
      isSteelbook: data.isSteelbook.present
          ? data.isSteelbook.value
          : this.isSteelbook,
      isMediabook: data.isMediabook.present
          ? data.isMediabook.value
          : this.isMediabook,
      isBoxset: data.isBoxset.present ? data.isBoxset.value : this.isBoxset,
      watched: data.watched.present ? data.watched.value : this.watched,
      userRating: data.userRating.present
          ? data.userRating.value
          : this.userRating,
      location: data.location.present ? data.location.value : this.location,
      notes: data.notes.present ? data.notes.value : this.notes,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      scanPhotoPath: data.scanPhotoPath.present
          ? data.scanPhotoPath.value
          : this.scanPhotoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItem(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('externalId: $externalId, ')
          ..write('mediaType: $mediaType, ')
          ..write('language: $language, ')
          ..write('title: $title, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('year: $year, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('genresJson: $genresJson, ')
          ..write('overview: $overview, ')
          ..write('certification: $certification, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('directorsJson: $directorsJson, ')
          ..write('castJson: $castJson, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('backdropUrl: $backdropUrl, ')
          ..write('trailerKey: $trailerKey, ')
          ..write('seasons: $seasons, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('hasDvd: $hasDvd, ')
          ..write('hasBluray: $hasBluray, ')
          ..write('hasUhd: $hasUhd, ')
          ..write('isSteelbook: $isSteelbook, ')
          ..write('isMediabook: $isMediabook, ')
          ..write('isBoxset: $isBoxset, ')
          ..write('watched: $watched, ')
          ..write('userRating: $userRating, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('addedAt: $addedAt, ')
          ..write('scanPhotoPath: $scanPhotoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    provider,
    externalId,
    mediaType,
    language,
    title,
    originalTitle,
    year,
    runtimeMinutes,
    genresJson,
    overview,
    certification,
    voteAverage,
    directorsJson,
    castJson,
    posterUrl,
    backdropUrl,
    trailerKey,
    seasons,
    lastFetched,
    hasDvd,
    hasBluray,
    hasUhd,
    isSteelbook,
    isMediabook,
    isBoxset,
    watched,
    userRating,
    location,
    notes,
    addedAt,
    scanPhotoPath,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItem &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.externalId == this.externalId &&
          other.mediaType == this.mediaType &&
          other.language == this.language &&
          other.title == this.title &&
          other.originalTitle == this.originalTitle &&
          other.year == this.year &&
          other.runtimeMinutes == this.runtimeMinutes &&
          other.genresJson == this.genresJson &&
          other.overview == this.overview &&
          other.certification == this.certification &&
          other.voteAverage == this.voteAverage &&
          other.directorsJson == this.directorsJson &&
          other.castJson == this.castJson &&
          other.posterUrl == this.posterUrl &&
          other.backdropUrl == this.backdropUrl &&
          other.trailerKey == this.trailerKey &&
          other.seasons == this.seasons &&
          other.lastFetched == this.lastFetched &&
          other.hasDvd == this.hasDvd &&
          other.hasBluray == this.hasBluray &&
          other.hasUhd == this.hasUhd &&
          other.isSteelbook == this.isSteelbook &&
          other.isMediabook == this.isMediabook &&
          other.isBoxset == this.isBoxset &&
          other.watched == this.watched &&
          other.userRating == this.userRating &&
          other.location == this.location &&
          other.notes == this.notes &&
          other.addedAt == this.addedAt &&
          other.scanPhotoPath == this.scanPhotoPath);
}

class MediaItemsCompanion extends UpdateCompanion<MediaItem> {
  final Value<int> id;
  final Value<String> provider;
  final Value<String> externalId;
  final Value<String> mediaType;
  final Value<String> language;
  final Value<String> title;
  final Value<String?> originalTitle;
  final Value<int?> year;
  final Value<int?> runtimeMinutes;
  final Value<String> genresJson;
  final Value<String?> overview;
  final Value<String?> certification;
  final Value<double?> voteAverage;
  final Value<String> directorsJson;
  final Value<String> castJson;
  final Value<String?> posterUrl;
  final Value<String?> backdropUrl;
  final Value<String?> trailerKey;
  final Value<int?> seasons;
  final Value<DateTime> lastFetched;
  final Value<bool> hasDvd;
  final Value<bool> hasBluray;
  final Value<bool> hasUhd;
  final Value<bool> isSteelbook;
  final Value<bool> isMediabook;
  final Value<bool> isBoxset;
  final Value<bool> watched;
  final Value<int?> userRating;
  final Value<String?> location;
  final Value<String?> notes;
  final Value<DateTime> addedAt;
  final Value<String?> scanPhotoPath;
  const MediaItemsCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.externalId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.language = const Value.absent(),
    this.title = const Value.absent(),
    this.originalTitle = const Value.absent(),
    this.year = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.overview = const Value.absent(),
    this.certification = const Value.absent(),
    this.voteAverage = const Value.absent(),
    this.directorsJson = const Value.absent(),
    this.castJson = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.backdropUrl = const Value.absent(),
    this.trailerKey = const Value.absent(),
    this.seasons = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.hasDvd = const Value.absent(),
    this.hasBluray = const Value.absent(),
    this.hasUhd = const Value.absent(),
    this.isSteelbook = const Value.absent(),
    this.isMediabook = const Value.absent(),
    this.isBoxset = const Value.absent(),
    this.watched = const Value.absent(),
    this.userRating = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.scanPhotoPath = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    required String externalId,
    required String mediaType,
    required String language,
    required String title,
    this.originalTitle = const Value.absent(),
    this.year = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.genresJson = const Value.absent(),
    this.overview = const Value.absent(),
    this.certification = const Value.absent(),
    this.voteAverage = const Value.absent(),
    this.directorsJson = const Value.absent(),
    this.castJson = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.backdropUrl = const Value.absent(),
    this.trailerKey = const Value.absent(),
    this.seasons = const Value.absent(),
    required DateTime lastFetched,
    this.hasDvd = const Value.absent(),
    this.hasBluray = const Value.absent(),
    this.hasUhd = const Value.absent(),
    this.isSteelbook = const Value.absent(),
    this.isMediabook = const Value.absent(),
    this.isBoxset = const Value.absent(),
    this.watched = const Value.absent(),
    this.userRating = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime addedAt,
    this.scanPhotoPath = const Value.absent(),
  }) : externalId = Value(externalId),
       mediaType = Value(mediaType),
       language = Value(language),
       title = Value(title),
       lastFetched = Value(lastFetched),
       addedAt = Value(addedAt);
  static Insertable<MediaItem> custom({
    Expression<int>? id,
    Expression<String>? provider,
    Expression<String>? externalId,
    Expression<String>? mediaType,
    Expression<String>? language,
    Expression<String>? title,
    Expression<String>? originalTitle,
    Expression<int>? year,
    Expression<int>? runtimeMinutes,
    Expression<String>? genresJson,
    Expression<String>? overview,
    Expression<String>? certification,
    Expression<double>? voteAverage,
    Expression<String>? directorsJson,
    Expression<String>? castJson,
    Expression<String>? posterUrl,
    Expression<String>? backdropUrl,
    Expression<String>? trailerKey,
    Expression<int>? seasons,
    Expression<DateTime>? lastFetched,
    Expression<bool>? hasDvd,
    Expression<bool>? hasBluray,
    Expression<bool>? hasUhd,
    Expression<bool>? isSteelbook,
    Expression<bool>? isMediabook,
    Expression<bool>? isBoxset,
    Expression<bool>? watched,
    Expression<int>? userRating,
    Expression<String>? location,
    Expression<String>? notes,
    Expression<DateTime>? addedAt,
    Expression<String>? scanPhotoPath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (externalId != null) 'external_id': externalId,
      if (mediaType != null) 'media_type': mediaType,
      if (language != null) 'language': language,
      if (title != null) 'title': title,
      if (originalTitle != null) 'original_title': originalTitle,
      if (year != null) 'year': year,
      if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
      if (genresJson != null) 'genres_json': genresJson,
      if (overview != null) 'overview': overview,
      if (certification != null) 'certification': certification,
      if (voteAverage != null) 'vote_average': voteAverage,
      if (directorsJson != null) 'directors_json': directorsJson,
      if (castJson != null) 'cast_json': castJson,
      if (posterUrl != null) 'poster_url': posterUrl,
      if (backdropUrl != null) 'backdrop_url': backdropUrl,
      if (trailerKey != null) 'trailer_key': trailerKey,
      if (seasons != null) 'seasons': seasons,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (hasDvd != null) 'has_dvd': hasDvd,
      if (hasBluray != null) 'has_bluray': hasBluray,
      if (hasUhd != null) 'has_uhd': hasUhd,
      if (isSteelbook != null) 'is_steelbook': isSteelbook,
      if (isMediabook != null) 'is_mediabook': isMediabook,
      if (isBoxset != null) 'is_boxset': isBoxset,
      if (watched != null) 'watched': watched,
      if (userRating != null) 'user_rating': userRating,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (addedAt != null) 'added_at': addedAt,
      if (scanPhotoPath != null) 'scan_photo_path': scanPhotoPath,
    });
  }

  MediaItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? provider,
    Value<String>? externalId,
    Value<String>? mediaType,
    Value<String>? language,
    Value<String>? title,
    Value<String?>? originalTitle,
    Value<int?>? year,
    Value<int?>? runtimeMinutes,
    Value<String>? genresJson,
    Value<String?>? overview,
    Value<String?>? certification,
    Value<double?>? voteAverage,
    Value<String>? directorsJson,
    Value<String>? castJson,
    Value<String?>? posterUrl,
    Value<String?>? backdropUrl,
    Value<String?>? trailerKey,
    Value<int?>? seasons,
    Value<DateTime>? lastFetched,
    Value<bool>? hasDvd,
    Value<bool>? hasBluray,
    Value<bool>? hasUhd,
    Value<bool>? isSteelbook,
    Value<bool>? isMediabook,
    Value<bool>? isBoxset,
    Value<bool>? watched,
    Value<int?>? userRating,
    Value<String?>? location,
    Value<String?>? notes,
    Value<DateTime>? addedAt,
    Value<String?>? scanPhotoPath,
  }) {
    return MediaItemsCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      externalId: externalId ?? this.externalId,
      mediaType: mediaType ?? this.mediaType,
      language: language ?? this.language,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      year: year ?? this.year,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      genresJson: genresJson ?? this.genresJson,
      overview: overview ?? this.overview,
      certification: certification ?? this.certification,
      voteAverage: voteAverage ?? this.voteAverage,
      directorsJson: directorsJson ?? this.directorsJson,
      castJson: castJson ?? this.castJson,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      trailerKey: trailerKey ?? this.trailerKey,
      seasons: seasons ?? this.seasons,
      lastFetched: lastFetched ?? this.lastFetched,
      hasDvd: hasDvd ?? this.hasDvd,
      hasBluray: hasBluray ?? this.hasBluray,
      hasUhd: hasUhd ?? this.hasUhd,
      isSteelbook: isSteelbook ?? this.isSteelbook,
      isMediabook: isMediabook ?? this.isMediabook,
      isBoxset: isBoxset ?? this.isBoxset,
      watched: watched ?? this.watched,
      userRating: userRating ?? this.userRating,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
      scanPhotoPath: scanPhotoPath ?? this.scanPhotoPath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (originalTitle.present) {
      map['original_title'] = Variable<String>(originalTitle.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (runtimeMinutes.present) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes.value);
    }
    if (genresJson.present) {
      map['genres_json'] = Variable<String>(genresJson.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (certification.present) {
      map['certification'] = Variable<String>(certification.value);
    }
    if (voteAverage.present) {
      map['vote_average'] = Variable<double>(voteAverage.value);
    }
    if (directorsJson.present) {
      map['directors_json'] = Variable<String>(directorsJson.value);
    }
    if (castJson.present) {
      map['cast_json'] = Variable<String>(castJson.value);
    }
    if (posterUrl.present) {
      map['poster_url'] = Variable<String>(posterUrl.value);
    }
    if (backdropUrl.present) {
      map['backdrop_url'] = Variable<String>(backdropUrl.value);
    }
    if (trailerKey.present) {
      map['trailer_key'] = Variable<String>(trailerKey.value);
    }
    if (seasons.present) {
      map['seasons'] = Variable<int>(seasons.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<DateTime>(lastFetched.value);
    }
    if (hasDvd.present) {
      map['has_dvd'] = Variable<bool>(hasDvd.value);
    }
    if (hasBluray.present) {
      map['has_bluray'] = Variable<bool>(hasBluray.value);
    }
    if (hasUhd.present) {
      map['has_uhd'] = Variable<bool>(hasUhd.value);
    }
    if (isSteelbook.present) {
      map['is_steelbook'] = Variable<bool>(isSteelbook.value);
    }
    if (isMediabook.present) {
      map['is_mediabook'] = Variable<bool>(isMediabook.value);
    }
    if (isBoxset.present) {
      map['is_boxset'] = Variable<bool>(isBoxset.value);
    }
    if (watched.present) {
      map['watched'] = Variable<bool>(watched.value);
    }
    if (userRating.present) {
      map['user_rating'] = Variable<int>(userRating.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (scanPhotoPath.present) {
      map['scan_photo_path'] = Variable<String>(scanPhotoPath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('externalId: $externalId, ')
          ..write('mediaType: $mediaType, ')
          ..write('language: $language, ')
          ..write('title: $title, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('year: $year, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('genresJson: $genresJson, ')
          ..write('overview: $overview, ')
          ..write('certification: $certification, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('directorsJson: $directorsJson, ')
          ..write('castJson: $castJson, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('backdropUrl: $backdropUrl, ')
          ..write('trailerKey: $trailerKey, ')
          ..write('seasons: $seasons, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('hasDvd: $hasDvd, ')
          ..write('hasBluray: $hasBluray, ')
          ..write('hasUhd: $hasUhd, ')
          ..write('isSteelbook: $isSteelbook, ')
          ..write('isMediabook: $isMediabook, ')
          ..write('isBoxset: $isBoxset, ')
          ..write('watched: $watched, ')
          ..write('userRating: $userRating, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('addedAt: $addedAt, ')
          ..write('scanPhotoPath: $scanPhotoPath')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [mediaItems];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$MediaItemsTableCreateCompanionBuilder = MediaItemsCompanion Function({
  Value<int> id,
  Value<String> provider,
  required String externalId,
  required String mediaType,
  required String language,
  required String title,
  Value<String?> originalTitle,
  Value<int?> year,
  Value<int?> runtimeMinutes,
  Value<String> genresJson,
  Value<String?> overview,
  Value<String?> certification,
  Value<double?> voteAverage,
  Value<String> directorsJson,
  Value<String> castJson,
  Value<String?> posterUrl,
  Value<String?> backdropUrl,
  Value<String?> trailerKey,
  Value<int?> seasons,
  required DateTime lastFetched,
  Value<bool> hasDvd,
  Value<bool> hasBluray,
  Value<bool> hasUhd,
  Value<bool> isSteelbook,
  Value<bool> isMediabook,
  Value<bool> isBoxset,
  Value<bool> watched,
  Value<int?> userRating,
  Value<String?> location,
  Value<String?> notes,
  required DateTime addedAt,
  Value<String?> scanPhotoPath,
});
typedef $$MediaItemsTableUpdateCompanionBuilder = MediaItemsCompanion Function({
  Value<int> id,
  Value<String> provider,
  Value<String> externalId,
  Value<String> mediaType,
  Value<String> language,
  Value<String> title,
  Value<String?> originalTitle,
  Value<int?> year,
  Value<int?> runtimeMinutes,
  Value<String> genresJson,
  Value<String?> overview,
  Value<String?> certification,
  Value<double?> voteAverage,
  Value<String> directorsJson,
  Value<String> castJson,
  Value<String?> posterUrl,
  Value<String?> backdropUrl,
  Value<String?> trailerKey,
  Value<int?> seasons,
  Value<DateTime> lastFetched,
  Value<bool> hasDvd,
  Value<bool> hasBluray,
  Value<bool> hasUhd,
  Value<bool> isSteelbook,
  Value<bool> isMediabook,
  Value<bool> isBoxset,
  Value<bool> watched,
  Value<int?> userRating,
  Value<String?> location,
  Value<String?> notes,
  Value<DateTime> addedAt,
  Value<String?> scanPhotoPath,
});

class $$MediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runtimeMinutes => $composableBuilder(
    column: $table.runtimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genresJson => $composableBuilder(
    column: $table.genresJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get certification => $composableBuilder(
    column: $table.certification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directorsJson => $composableBuilder(
    column: $table.directorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get castJson => $composableBuilder(
    column: $table.castJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backdropUrl => $composableBuilder(
    column: $table.backdropUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trailerKey => $composableBuilder(
    column: $table.trailerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasDvd => $composableBuilder(
    column: $table.hasDvd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasBluray => $composableBuilder(
    column: $table.hasBluray,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasUhd => $composableBuilder(
    column: $table.hasUhd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSteelbook => $composableBuilder(
    column: $table.isSteelbook,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMediabook => $composableBuilder(
    column: $table.isMediabook,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBoxset => $composableBuilder(
    column: $table.isBoxset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get watched => $composableBuilder(
    column: $table.watched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scanPhotoPath => $composableBuilder(
    column: $table.scanPhotoPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runtimeMinutes => $composableBuilder(
    column: $table.runtimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genresJson => $composableBuilder(
    column: $table.genresJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get certification => $composableBuilder(
    column: $table.certification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directorsJson => $composableBuilder(
    column: $table.directorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get castJson => $composableBuilder(
    column: $table.castJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backdropUrl => $composableBuilder(
    column: $table.backdropUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trailerKey => $composableBuilder(
    column: $table.trailerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasDvd => $composableBuilder(
    column: $table.hasDvd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasBluray => $composableBuilder(
    column: $table.hasBluray,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasUhd => $composableBuilder(
    column: $table.hasUhd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSteelbook => $composableBuilder(
    column: $table.isSteelbook,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMediabook => $composableBuilder(
    column: $table.isMediabook,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBoxset => $composableBuilder(
    column: $table.isBoxset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get watched => $composableBuilder(
    column: $table.watched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scanPhotoPath => $composableBuilder(
    column: $table.scanPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get runtimeMinutes => $composableBuilder(
    column: $table.runtimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genresJson => $composableBuilder(
    column: $table.genresJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<String> get certification => $composableBuilder(
    column: $table.certification,
    builder: (column) => column,
  );

  GeneratedColumn<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get directorsJson => $composableBuilder(
    column: $table.directorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get castJson =>
      $composableBuilder(column: $table.castJson, builder: (column) => column);

  GeneratedColumn<String> get posterUrl =>
      $composableBuilder(column: $table.posterUrl, builder: (column) => column);

  GeneratedColumn<String> get backdropUrl => $composableBuilder(
    column: $table.backdropUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trailerKey => $composableBuilder(
    column: $table.trailerKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seasons =>
      $composableBuilder(column: $table.seasons, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasDvd =>
      $composableBuilder(column: $table.hasDvd, builder: (column) => column);

  GeneratedColumn<bool> get hasBluray =>
      $composableBuilder(column: $table.hasBluray, builder: (column) => column);

  GeneratedColumn<bool> get hasUhd =>
      $composableBuilder(column: $table.hasUhd, builder: (column) => column);

  GeneratedColumn<bool> get isSteelbook => $composableBuilder(
    column: $table.isSteelbook,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isMediabook => $composableBuilder(
    column: $table.isMediabook,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBoxset =>
      $composableBuilder(column: $table.isBoxset, builder: (column) => column);

  GeneratedColumn<bool> get watched =>
      $composableBuilder(column: $table.watched, builder: (column) => column);

  GeneratedColumn<int> get userRating => $composableBuilder(
    column: $table.userRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get scanPhotoPath => $composableBuilder(
    column: $table.scanPhotoPath,
    builder: (column) => column,
  );
}

class $$MediaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaItemsTable,
          MediaItem,
          $$MediaItemsTableFilterComposer,
          $$MediaItemsTableOrderingComposer,
          $$MediaItemsTableAnnotationComposer,
          $$MediaItemsTableCreateCompanionBuilder,
          $$MediaItemsTableUpdateCompanionBuilder,
          (
            MediaItem,
            BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem>,
          ),
          MediaItem,
          PrefetchHooks Function()
        > {
  $$MediaItemsTableTableManager(_$AppDatabase db, $MediaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> originalTitle = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> runtimeMinutes = const Value.absent(),
                Value<String> genresJson = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<String?> certification = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
                Value<String> directorsJson = const Value.absent(),
                Value<String> castJson = const Value.absent(),
                Value<String?> posterUrl = const Value.absent(),
                Value<String?> backdropUrl = const Value.absent(),
                Value<String?> trailerKey = const Value.absent(),
                Value<int?> seasons = const Value.absent(),
                Value<DateTime> lastFetched = const Value.absent(),
                Value<bool> hasDvd = const Value.absent(),
                Value<bool> hasBluray = const Value.absent(),
                Value<bool> hasUhd = const Value.absent(),
                Value<bool> isSteelbook = const Value.absent(),
                Value<bool> isMediabook = const Value.absent(),
                Value<bool> isBoxset = const Value.absent(),
                Value<bool> watched = const Value.absent(),
                Value<int?> userRating = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<String?> scanPhotoPath = const Value.absent(),
              }) => MediaItemsCompanion(
                id: id,
                provider: provider,
                externalId: externalId,
                mediaType: mediaType,
                language: language,
                title: title,
                originalTitle: originalTitle,
                year: year,
                runtimeMinutes: runtimeMinutes,
                genresJson: genresJson,
                overview: overview,
                certification: certification,
                voteAverage: voteAverage,
                directorsJson: directorsJson,
                castJson: castJson,
                posterUrl: posterUrl,
                backdropUrl: backdropUrl,
                trailerKey: trailerKey,
                seasons: seasons,
                lastFetched: lastFetched,
                hasDvd: hasDvd,
                hasBluray: hasBluray,
                hasUhd: hasUhd,
                isSteelbook: isSteelbook,
                isMediabook: isMediabook,
                isBoxset: isBoxset,
                watched: watched,
                userRating: userRating,
                location: location,
                notes: notes,
                addedAt: addedAt,
                scanPhotoPath: scanPhotoPath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> provider = const Value.absent(),
                required String externalId,
                required String mediaType,
                required String language,
                required String title,
                Value<String?> originalTitle = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> runtimeMinutes = const Value.absent(),
                Value<String> genresJson = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<String?> certification = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
                Value<String> directorsJson = const Value.absent(),
                Value<String> castJson = const Value.absent(),
                Value<String?> posterUrl = const Value.absent(),
                Value<String?> backdropUrl = const Value.absent(),
                Value<String?> trailerKey = const Value.absent(),
                Value<int?> seasons = const Value.absent(),
                required DateTime lastFetched,
                Value<bool> hasDvd = const Value.absent(),
                Value<bool> hasBluray = const Value.absent(),
                Value<bool> hasUhd = const Value.absent(),
                Value<bool> isSteelbook = const Value.absent(),
                Value<bool> isMediabook = const Value.absent(),
                Value<bool> isBoxset = const Value.absent(),
                Value<bool> watched = const Value.absent(),
                Value<int?> userRating = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime addedAt,
                Value<String?> scanPhotoPath = const Value.absent(),
              }) => MediaItemsCompanion.insert(
                id: id,
                provider: provider,
                externalId: externalId,
                mediaType: mediaType,
                language: language,
                title: title,
                originalTitle: originalTitle,
                year: year,
                runtimeMinutes: runtimeMinutes,
                genresJson: genresJson,
                overview: overview,
                certification: certification,
                voteAverage: voteAverage,
                directorsJson: directorsJson,
                castJson: castJson,
                posterUrl: posterUrl,
                backdropUrl: backdropUrl,
                trailerKey: trailerKey,
                seasons: seasons,
                lastFetched: lastFetched,
                hasDvd: hasDvd,
                hasBluray: hasBluray,
                hasUhd: hasUhd,
                isSteelbook: isSteelbook,
                isMediabook: isMediabook,
                isBoxset: isBoxset,
                watched: watched,
                userRating: userRating,
                location: location,
                notes: notes,
                addedAt: addedAt,
                scanPhotoPath: scanPhotoPath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaItemsTable, MediaItem>(table),
                  BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaItemsTable,
      MediaItem,
      $$MediaItemsTableFilterComposer,
      $$MediaItemsTableOrderingComposer,
      $$MediaItemsTableAnnotationComposer,
      $$MediaItemsTableCreateCompanionBuilder,
      $$MediaItemsTableUpdateCompanionBuilder,
      (MediaItem, BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem>),
      MediaItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
}

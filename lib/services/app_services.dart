import '../data/collection_repository.dart';
import '../data/database.dart';
import '../metadata/metadata_provider.dart';
import '../metadata/tmdb_provider.dart';
import 'settings.dart';

/// Einfache Sammelstelle für die Dienste der App.
class AppServices {
  AppServices({
    required this.settings,
    required this.repository,
    required this.metadata,
  });

  static late AppServices instance;

  final Settings settings;
  final CollectionRepository repository;
  final MetadataProvider metadata;

  static Future<AppServices> create() async {
    final settings = await Settings.load();
    final db = AppDatabase();
    return AppServices(
      settings: settings,
      repository: CollectionRepository(db),
      metadata: TmdbProvider(apiKey: () => settings.tmdbApiKey),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import 'config/app_config.dart';
import 'l10n/app_localizations.dart';
import 'services/app_services.dart';
import 'ui/collection_screen.dart';

class DiscScannerApp extends StatefulWidget {
  const DiscScannerApp({super.key});

  @override
  State<DiscScannerApp> createState() => _DiscScannerAppState();
}

class _DiscScannerAppState extends State<DiscScannerApp> {
  final _services = AppServices.instance;

  @override
  void initState() {
    super.initState();
    _refreshStale();
  }

  /// TMDB erlaubt höchstens 6 Monate Zwischenspeicherung: ältere Einträge
  /// beim Start im Hintergrund erneuern.
  Future<void> _refreshStale() async {
    if (!_services.metadata.isConfigured) return;
    await _services.repository.refresh(
      _services.metadata,
      language: _services.settings.metadataLanguage,
      olderThan: metadataMaxAge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _services.settings,
      builder: (context, _) {
        ThemeData theme(Brightness b) => ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1565C0),
                brightness: b,
              ),
            );
        return MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: theme(Brightness.light),
          darkTheme: theme(Brightness.dark),
          themeMode: ThemeMode.system,
          locale: _services.settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: const CollectionScreen(),
        );
      },
    );
  }
}

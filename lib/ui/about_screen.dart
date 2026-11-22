import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import 'common.dart';
import 'imprint_screen.dart';
import 'privacy_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(appName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(l10n.aboutText),
          const Divider(height: 32),
          Text(l10n.dataSources, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          // TMDB-Pflichthinweis mit Logo.
          InkWell(
            onTap: () => launchUrl(Uri.parse('https://www.themoviedb.org/'),
                mode: LaunchMode.externalApplication),
            child: Image.asset('assets/tmdb_logo.png', height: 40,
                alignment: Alignment.centerLeft,
                errorBuilder: (_, _, _) => const Text('TMDB')),
          ),
          const SizedBox(height: 8),
          Text(l10n.tmdbAttribution),
          const SizedBox(height: 16),
          Text(l10n.textRecognitionInfo),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.gavel_outlined),
            title: Text(l10n.imprint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ImprintScreen())),
          ),
          TextButton(
            onPressed: () => showLicensePage(context: context, applicationName: appName),
            child: const Text('Open-Source-Lizenzen / Licenses'),
          ),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common.dart';

/// Datenschutz-Hinweise: was die App an wen sendet.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _links = [
    ('Google ML Kit', 'https://developers.google.com/ml-kit/terms'),
    ('Google', 'https://policies.google.com/privacy'),
    ('TMDB', 'https://www.themoviedb.org/privacy-policy'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget section(String title, String body) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(body),
          ]),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacy)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.privacyIntro),
          section(l10n.privacyMlkitTitle, l10n.privacyMlkit),
          section(l10n.privacyTmdbTitle, l10n.privacyTmdb),
          section(l10n.privacyYoutubeTitle, l10n.privacyYoutube),
          section(l10n.privacyKeyTitle, l10n.privacyKey),
          const SizedBox(height: 20),
          Text(l10n.privacyLinks, style: theme.textTheme.titleMedium),
          for (final (name, url) in _links)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.open_in_new),
              title: Text(name),
              subtitle: Text(url),
              onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

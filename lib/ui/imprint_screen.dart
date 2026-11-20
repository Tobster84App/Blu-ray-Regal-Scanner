import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/legal_info.dart';
import 'common.dart';

/// Impressum mit KernDigit-Logo (nur hier).
class ImprintScreen extends StatelessWidget {
  const ImprintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final h = theme.textTheme.titleMedium;
    Widget section(String title, String body) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: h),
            const SizedBox(height: 4),
            Text(body),
          ]),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.imprint)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              dark ? 'assets/kerndigit_logo_dark.png' : 'assets/kerndigit_logo.png',
              height: 44,
              semanticLabel: 'KernDigit',
            ),
          ),
          const SizedBox(height: 24),
          if (l10n.imprintTranslationNote.isNotEmpty) ...[
            Text(l10n.imprintTranslationNote,
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
          ],
          Text(l10n.imprintLegalBasis, style: h),
          const SizedBox(height: 4),
          Text([providerName, ...providerAddress, l10n.country].join('\n')),
          const SizedBox(height: 20),
          Text(l10n.contact, style: h),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => launchUrl(Uri(scheme: 'mailto', path: providerEmail)),
            child: Text(
              l10n.email(providerEmail),
              style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
            ),
          ),
          section(l10n.imprintResponsibleTitle, l10n.imprintResponsible(providerName)),
          section(l10n.imprintDataTitle, '${l10n.imprintData}\n${l10n.tmdbAttribution}'),
          section(l10n.imprintLinksTitle, l10n.imprintLinks),
          section(l10n.imprintDisputeTitle, l10n.imprintDispute),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

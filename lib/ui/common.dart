import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../recognition/format_detector.dart';
import '../recognition/matcher.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

String formatLabel(BuildContext context, DiscFormat f) => switch (f) {
      DiscFormat.dvd => context.l10n.formatDvd,
      DiscFormat.bluray => context.l10n.formatBluray,
      DiscFormat.uhd => context.l10n.formatUhd,
    };

Color statusColor(MatchStatus s) => switch (s) {
      MatchStatus.green => const Color(0xFF2E7D32),
      MatchStatus.yellow => const Color(0xFFF9A825),
      MatchStatus.red => const Color(0xFFC62828),
      MatchStatus.grey => const Color(0xFF9E9E9E),
    };

/// Poster mit Platzhalter (auch offline).
class Poster extends StatelessWidget {
  const Poster({super.key, required this.url, this.width, this.height});

  final String? url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.movie_outlined),
    );
    if (url == null) return placeholder;
    return Image.network(
      url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

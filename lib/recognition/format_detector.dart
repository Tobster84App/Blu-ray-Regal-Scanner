import 'text_utils.dart';

enum DiscFormat { dvd, bluray, uhd }

final _uhd = RegExp(r'(?<![a-z0-9])(4\s*k|uhd|ultra\s*hd)(?![a-z0-9])');
final _bluray = RegExp(r'(?<![a-z0-9])blu\s*ray(?![a-z0-9])');
final _dvd = RegExp(r'(?<![a-z0-9])dvd(?![a-z0-9])');

/// Erkennt das Format aus dem Rohtext einer Hülle.
/// „4K“/„Ultra HD“ hat Vorrang, weil UHD-Hüllen oft auch „Blu-ray“ tragen.
DiscFormat? detectFormat(Iterable<String> rawLines) {
  final text = rawLines.map(normalize).join(' ');
  final tokens = text.split(' ');
  bool fuzzy(bool Function(String) test) => tokens.any(test);
  if (_uhd.hasMatch(text) ||
      fuzzy((t) => t.length >= 5 && t.length <= 9 &&
          levenshtein(t.startsWith('4k') || t.startsWith('ak') ? t.substring(2) : t, 'ultrahd') <= 2)) {
    return DiscFormat.uhd;
  }
  if (_bluray.hasMatch(text) ||
      fuzzy((t) => t.startsWith('bl') && t.length >= 4 && t.length <= 7 && levenshtein(t, 'bluray') <= 2)) {
    return DiscFormat.bluray;
  }
  if (_dvd.hasMatch(text)) return DiscFormat.dvd;
  return null;
}

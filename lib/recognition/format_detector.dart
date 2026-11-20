import 'text_utils.dart';

enum DiscFormat { dvd, bluray, uhd }

final _uhd = RegExp(r'(?<![a-z0-9])(4\s*k|uhd|ultra\s*hd)(?![a-z0-9])');
final _bluray = RegExp(r'(?<![a-z0-9])blu\s*ray(?![a-z0-9])');
final _dvd = RegExp(r'(?<![a-z0-9])dvd(?![a-z0-9])');

/// Erkennt das Format aus dem Rohtext einer Hülle.
/// „4K“/„Ultra HD“ hat Vorrang, weil UHD-Hüllen oft auch „Blu-ray“ tragen.
DiscFormat? detectFormat(Iterable<String> rawLines) {
  final text = rawLines.map(normalize).join(' ');
  if (_uhd.hasMatch(text)) return DiscFormat.uhd;
  if (_bluray.hasMatch(text)) return DiscFormat.bluray;
  if (_dvd.hasMatch(text)) return DiscFormat.dvd;
  return null;
}

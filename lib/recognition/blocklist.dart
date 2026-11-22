/// Sperrliste für Störtext auf Hüllenrücken.
///
/// Erweitern: einfach Einträge in die passenden Listen schreiben
/// (Groß-/Kleinschreibung egal, Satzzeichen egal).
library;

import 'text_utils.dart';

/// Formatlogos – werden überall aus dem Text entfernt.
const formatTerms = <String>[
  '4k ultra hd blu-ray',
  '4k ultra hd',
  'ultra hd blu-ray',
  'ultra hd',
  'ultrahd',
  'uhd',
  '4k',
  'blu-ray disc',
  'blu-ray 3d',
  'blu-ray',
  'bluray',
  'blu ray',
  'dvd video',
  'dvd',
];

/// Studios und Labels – werden nur entfernt, wenn eine Zeile ausschließlich
/// aus solchen Namen (plus Füllwörtern wie „Pictures“) besteht. So bleibt
/// z. B. „Universal Soldier“ erhalten.
const studioTerms = <String>[
  'concorde', 'studiocanal', 'studio canal', 'warner bros', 'warner', 'wb',
  'universal', 'legendary', 'dc', 'dc comics', 'lionsgate', 'paramount',
  '20th century fox', '20th century studios', '20th century', 'sony',
  'sony pictures', 'columbia', 'disney', 'walt disney', 'lucasfilm', 'marvel',
  'marvel studios', 'pixar', 'mgm', 'leonine', 'constantin', 'capelight',
  'koch media', 'plaion', 'turbine', 'eurovideo', 'tobis', 'hbo', 'amazon',
  'prime video', 'netflix', 'dreamworks', 'new line cinema', 'illumination',
  'summit', 'summit entertainment', 'a24', 'square one',
];

/// Füllwörter, die nur zusammen mit Studionamen auftreten.
const studioFillers = <String>[
  'pictures', 'presents', 'entertainment', 'home', 'bros', 'films', 'film',
  'studios', 'studio', 'video', 'home entertainment', 'distribution',
  'company', 'animation', 'television', 'tv', 'comics', 'inc', 'ltd', 'gmbh',
];

/// Sonstiges – wird überall entfernt.
const miscTerms = <String>[
  '3-disc set', '2-disc set', '4-disc set', '3 disc set', '2 disc set',
  'disc set', 'steelbook', 'mediabook', 'limited edition',
  'limited collectors edition', 'collectors edition', 'special edition',
  'uncut', 'digibook', 'remastered', 'dolby vision', 'dolby atmos', 'hdr10',
  'hdr', 'fsk', 'best nr', 'best-nr', 'bestnr', 'art nr', 'art-nr',
  'artikelnummer', 'artikel nr',
];

String _pattern(String term) {
  final tokens = tokenize(term);
  return r'(?<![a-z0-9])' + tokens.map(RegExp.escape).join(r'\s*') +
      r'(?![a-z0-9])';
}

final _formatRe = RegExp(formatTerms.map(_pattern).join('|'));
final _miscRe = RegExp(miscTerms.map(_pattern).join('|'));
final _studioRe = RegExp(
  [...studioTerms, ...studioFillers].map(_pattern).join('|'),
);
final _onlyDigitsOrCodes = RegExp(r'^[\d\s]*$');
final _hasDigit = RegExp(r'\d');
final _hasLetter = RegExp(r'[a-z]');

/// Formatlogo mit OCR-Fehlern? („UTRAHD“, „JLTRAHD“, „Blusay“, „4KULTRAHD“ …)
bool isFormatToken(String token) {
  var t = token;
  if (t.length > 4 && (t.startsWith('4k') || t.startsWith('ak'))) t = t.substring(2);
  if (t == '4k' || t == 'ak' || t == 'uhd' || t == 'dvd') return true;
  if (t.length >= 5 && t.length <= 9 && levenshtein(t, 'ultrahd') <= 2) return true;
  if (t.startsWith('bl') && t.length >= 4 && t.length <= 7 && levenshtein(t, 'bluray') <= 2) {
    return true;
  }
  // „bluraydisc“ zusammengeklebt und verlesen („bluraydlsc“, „blusaydise“).
  if (t.startsWith('b') && t.length >= 8 && t.length <= 12 && levenshtein(t, 'bluraydisc') <= 3) {
    return true;
  }
  return false;
}

const _studioWords = [
  'concorde', 'studiocanal', 'warner', 'universal', 'legendary', 'lionsgate',
  'paramount', 'columbia', 'disney', 'lucasfilm', 'marvel', 'pixar', 'leonine',
  'constantin', 'capelight', 'illumination', 'dreamworks', 'eurovideo',
  'summit', 'entertainment', 'pictures', 'universum',
];

/// Studioname mit Lesefehler („lionsoate“, „iicasfll“, „wniversa“)? Exakte
/// Studionamen zählen hier nicht – die können zu einem Titel gehören.
bool isGarbledStudioToken(String t) {
  if (t.length < 6) return false;
  for (final w in _studioWords) {
    if (t == w) return false;
    final allowed = w.length >= 8 ? 2 : 1;
    if ((t.length - w.length).abs() <= allowed && levenshtein(t, w) <= allowed) return true;
  }
  return false;
}

/// „1eague“ → „league“, „sh0w“ → „show“: in Wörtern, die überwiegend aus
/// Buchstaben bestehen, sind 0/1/5 meist falsch gelesene o/l/s.
String fixDigitConfusions(String t) {
  final digits = _hasDigit.allMatches(t).length;
  if (digits == 0 || digits > 2) return t;
  final letters = _hasLetter.allMatches(t).length;
  if (letters < 3) return t;
  return t.replaceAll('0', 'o').replaceAll('1', 'l').replaceAll('5', 's');
}

/// Artikel-/Bestellnummern wie „D087402“, „OI60304“, „UFI2329“.
bool isCodeToken(String t) =>
    t.length >= 4 && _hasDigit.hasMatch(t) && _hasLetter.hasMatch(t) &&
    _hasDigit.allMatches(t).length >= t.length / 2;
final _letters = RegExp(r'[a-z]');

/// Bereinigt eine OCR-Zeile. Gibt `null` zurück, wenn nichts Sinnvolles
/// übrig bleibt (reine Zahlen, nur Logos, nur Studio …).
String? cleanLine(String raw) {
  var s = normalize(raw);
  if (s.isEmpty) return null;
  s = s.replaceAll(_formatRe, ' ').replaceAll(_miscRe, ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (s.isEmpty || _onlyDigitsOrCodes.hasMatch(s)) return null;

  // Zeile besteht nur aus Studionamen/Füllwörtern?
  final withoutStudios = s.replaceAll(_studioRe, ' ').trim();
  if (withoutStudios.isEmpty ||
      _onlyDigitsOrCodes.hasMatch(withoutStudios)) {
    return null;
  }

  // Lange Ziffernfolgen (Artikel-/Bestellnummern, EAN) entfernen.
  s = s.replaceAll(RegExp(r'(?<![a-z0-9])\d{5,}(?![a-z0-9])'), ' ');
  // Formatlogos mit Lesefehlern und Bestellnummern wortweise entfernen,
  // typische Ziffer-statt-Buchstabe-Fehler korrigieren („1EAGUE“).
  s = s
      .split(' ')
      .where((t) => t.isNotEmpty && !isFormatToken(t) && !isCodeToken(t) && !isGarbledStudioToken(t))
      .map(fixDigitConfusions)
      .join(' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  if (_letters.allMatches(s).length < 2) return null;
  return s;
}

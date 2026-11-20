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
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  if (_letters.allMatches(s).length < 2) return null;
  return s;
}

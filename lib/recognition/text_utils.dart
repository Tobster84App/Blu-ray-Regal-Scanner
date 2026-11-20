/// Hilfsfunktionen zum Vergleichen von Texten (OCR gegen Titel).
library;

import 'dart:math' as math;

const _umlauts = {
  'ä': 'a', 'ö': 'o', 'ü': 'u', 'ß': 'ss', 'é': 'e', 'è': 'e', 'ê': 'e',
  'á': 'a', 'à': 'a', 'â': 'a', 'í': 'i', 'ì': 'i', 'ó': 'o', 'ò': 'o',
  'ô': 'o', 'ú': 'u', 'ù': 'u', 'ñ': 'n', 'ç': 'c', 'ø': 'o', 'å': 'a',
};

const _roman = {'ii': '2', 'iii': '3', 'iv': '4', 'vi': '6', 'vii': '7'};

/// Kleinschreibung, Umlaute/Akzente vereinfacht, Satzzeichen entfernt.
String normalize(String input) {
  final lower = input.toLowerCase();
  final sb = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    sb.write(_umlauts[ch] ?? ch);
  }
  return sb
      .toString()
      // Apostrophe verbinden: "snyder's" -> "snyders"
      .replaceAll(RegExp(r"['’`´]"), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

/// Zerlegt in Wörter; römische Zahlen werden zu Ziffern.
List<String> tokenize(String input) {
  final n = normalize(input);
  if (n.isEmpty) return const [];
  return n.split(' ').map((t) => _roman[t] ?? t).toList();
}

/// Ohne Leerzeichen, z. B. für zusammengeklebte OCR-Wörter ("JOHNWICK").
String compact(String input) => tokenize(input).join();

int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  var curr = List<int>.filled(b.length + 1, 0);
  for (var i = 1; i <= a.length; i++) {
    curr[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      curr[j] = math.min(
        math.min(curr[j - 1] + 1, prev[j] + 1),
        prev[j - 1] + cost,
      );
    }
    final t = prev;
    prev = curr;
    curr = t;
  }
  return prev[b.length];
}

/// Ähnlichkeit 0..1 auf Basis der Levenshtein-Distanz.
double ratio(String a, String b) {
  final maxLen = math.max(a.length, b.length);
  if (maxLen == 0) return 1;
  return 1 - levenshtein(a, b) / maxLen;
}

/// Beste Ähnlichkeit von [needle] zu einem gleich langen Ausschnitt aus
/// [haystack] (für zusammengeklebte oder abgeschnittene Texte).
double partialRatio(String needle, String haystack) {
  if (needle.isEmpty) return 0;
  if (haystack.length <= needle.length) return ratio(needle, haystack);
  var best = 0.0;
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    final r = ratio(needle, haystack.substring(i, i + needle.length));
    if (r > best) best = r;
    if (best == 1) break;
  }
  return best;
}

final _digits = RegExp(r'^\d+$');

/// Sind zwei Wörter (mit OCR-Fehlern) gleich?
/// Kurze Wörter und Zahlen müssen exakt passen, längere dürfen 1–2 Fehler
/// haben.
bool tokensMatch(String a, String b) {
  if (a == b) return true;
  if (_digits.hasMatch(a) || _digits.hasMatch(b)) return false;
  final minLen = math.min(a.length, b.length);
  if (minLen <= 3) return false;
  final allowed = minLen >= 8 ? 2 : 1;
  if ((a.length - b.length).abs() > allowed) return false;
  return levenshtein(a, b) <= allowed;
}

/// Füllwörter zählen beim Vergleich weniger.
const stopwords = {
  'the', 'a', 'an', 'of', 'and', 'der', 'die', 'das', 'ein', 'eine', 'und',
  'von', 'im', 'in', 'le', 'la', 'el',
};

double tokenWeight(String t) => stopwords.contains(t) ? 0.3 : 1.0;

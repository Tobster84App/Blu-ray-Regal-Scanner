import 'dart:math' as math;

import '../config/app_config.dart';
import '../metadata/metadata_provider.dart';
import 'text_utils.dart';

enum MatchStatus { green, yellow, red, grey }

class ScoredHit {
  const ScoredHit(this.hit, this.score);
  final SearchHit hit;
  final double score;
}

/// Bewertet, wie gut ein Titel zum (bereinigten) Text einer Hülle passt.
///
/// Zwei Anteile:
/// * Titelabdeckung: Wie viele Wörter des Titels stehen auf der Hülle?
///   Fehlt „Kapitel 3“ auf der Hülle, sinkt der Wert für „John Wick:
///   Kapitel 3“ deutlich.
/// * Hüllenabdeckung: Wie viel vom Hüllentext erklärt der Titel? Steht
///   „Uprising“ auf der Hülle, gewinnt „Pacific Rim: Uprising“ gegen
///   „Pacific Rim“. Dieser Anteil wird schwächer gewichtet, weil auf Hüllen
///   oft auch Schauspielernamen stehen.
///
/// Der Wert wird immer gegen den GESAMTEN Hüllentext berechnet, nicht gegen
/// einzelne Suchvarianten.
double scoreTitle(String title, String spineText) {
  final t = tokenize(title);
  final s = tokenize(spineText);
  if (t.isEmpty || s.isEmpty) return 0;

  final tokenScore = _tokenScore(t, s);
  if (tokenScore >= 0.6) return tokenScore;
  // Rückfall für zusammengeklebte Wörter („JOHNWICK“).
  return math.max(tokenScore, _compactScore(t.join(), s.join()));
}

/// Anteil der Buchstaben auf der Hülle, die der Titel erklärt (0..1).
double spineLetterCoverage(String title, String spineText) {
  final t = tokenize(title), s = tokenize(spineText);
  if (t.isEmpty || s.isEmpty) return 0;
  return _match(t, s).letterCoverage;
}

double _tokenScore(List<String> t, List<String> s) => _match(t, s).score;

({double score, double letterCoverage}) _match(List<String> t, List<String> s) {
  final usedS = List<bool>.filled(s.length, false);
  final usedT = List<bool>.filled(t.length, false);
  for (var j = 0; j < t.length; j++) {
    for (var i = 0; i < s.length; i++) {
      if (!usedS[i] && tokensMatch(t[j], s[i])) {
        usedS[i] = true;
        usedT[j] = true;
        break;
      }
    }
  }
  // Zusammengeklebte Wörter: „zackisnyders“ = „zack“ + „snyders“,
  // „ungeonsdragons“ ≈ „dungeons“ + „dragons“.
  for (var j = 0; j < t.length; j++) {
    for (var len = 3; len >= 2; len--) {
      if (j + len > t.length) continue;
      if (usedT.sublist(j, j + len).any((u) => u)) continue;
      final glued = t.sublist(j, j + len).join();
      for (var i = 0; i < s.length; i++) {
        if (!usedS[i] && s[i].length >= 6 && tokensMatch(glued, s[i])) {
          usedS[i] = true;
          for (var k = j; k < j + len; k++) {
            usedT[k] = true;
          }
          break;
        }
      }
    }
  }
  // Umgekehrt: ein Titelwort, das auf der Hülle getrennt gelesen wurde.
  for (var j = 0; j < t.length; j++) {
    if (usedT[j] || t[j].length < 6) continue;
    for (var i = 0; i + 1 < s.length; i++) {
      if (usedS[i] || usedS[i + 1]) continue;
      if (tokensMatch(t[j], s[i] + s[i + 1])) {
        usedS[i] = usedS[i + 1] = true;
        usedT[j] = true;
        break;
      }
    }
  }
  var tWeight = 0.0, tMatched = 0.0;
  for (var j = 0; j < t.length; j++) {
    final w = tokenWeight(t[j]);
    tWeight += w;
    if (usedT[j]) tMatched += w;
  }
  var sWeight = 0.0, sMatched = 0.0;
  for (var i = 0; i < s.length; i++) {
    final w = tokenWeight(s[i]);
    sWeight += w;
    if (usedS[i]) sMatched += w;
  }
  var letters = 0, matchedLetters = 0;
  for (var i = 0; i < s.length; i++) {
    letters += s[i].length;
    if (usedS[i]) matchedLetters += s[i].length;
  }
  if (tWeight == 0 || sWeight == 0) return (score: 0.0, letterCoverage: 0.0);
  final titleCoverage = tMatched / tWeight;
  final spineCoverage = sMatched / sWeight;
  return (
    score: titleCoverage * (0.75 + 0.25 * spineCoverage),
    letterCoverage: letters == 0 ? 0.0 : matchedLetters / letters,
  );
}

double _compactScore(String t, String s) {
  if (t.length < 4) return 0;
  final sim = partialRatio(t, s);
  final cover = math.min(1.0, t.length / s.length);
  return sim * sim * (0.75 + 0.25 * cover);
}

/// Bester Wert über Titel, Originaltitel und Namen.
double scoreHit(SearchHit hit, String spineText) {
  var best = 0.0;
  for (final title in {hit.title, if (hit.originalTitle != null) hit.originalTitle!}) {
    best = math.max(best, scoreTitle(title, spineText));
  }
  return best;
}

final _seriesHint = RegExp(
    r'(?<![a-z])(staffel|staffeln|season|seasons|serie|series|komplette serie|complete series|episoden|episodes)(?![a-z])');

/// Steht auf der Hülle etwas, das auf eine Serie hindeutet?
bool hasSeriesHint(String rawText) => _seriesHint.hasMatch(normalize(rawText));

/// Sortiert die Kandidaten nach Wert (Gleichstand: Beliebtheit).
///
/// Filme gehen bei sonst gleichem Wert leicht vor Serien – außer der
/// Rohtext der Hülle enthält einen Serien-Hinweis ([rawText]).
List<ScoredHit> rankHits(Iterable<SearchHit> hits, String spineText,
    {String rawText = '', List<String> altTexts = const []}) {
  final series = hasSeriesHint(rawText);
  final seen = <String>{};
  final scored = <ScoredHit>[];
  for (final h in hits) {
    if (!seen.add(h.key)) continue;
    var score = scoreHit(h, spineText);
    for (final alt in altTexts) {
      score = math.max(score, scoreHit(h, alt));
    }
    final disfavoured = series ? h.type == MediaType.movie : h.type == MediaType.tv;
    if (disfavoured) score *= 0.97;
    scored.add(ScoredHit(h, score));
  }
  scored.sort((a, b) {
    final d = b.score.compareTo(a.score);
    if (d.abs() > 0 && (a.score - b.score).abs() > 1e-9) return d;
    return (b.hit.popularity ?? 0).compareTo(a.hit.popularity ?? 0);
  });
  return scored;
}

/// Unter dieser TMDB-Beliebtheit gilt ein Titel als „unbekannt“ – dann nie
/// automatisch grün (Zufallstreffer wie „Zumbí“ statt „Zombieland“).
const double minPopularityForGreen = 1.5;

/// So viel der Buchstaben auf der Hülle muss der Titel erklären, damit er
/// grün werden kann.
const double minLetterCoverageForGreen = 0.45;

MatchStatus classify(
  List<ScoredHit> ranked, {
  required bool cutOff,
  required RecognitionConfig cfg,
  String? spineText,
  List<String> altTexts = const [],
}) {
  if (cutOff) return MatchStatus.grey;
  if (ranked.isEmpty) return MatchStatus.red;
  final top = ranked.first;
  final best = top.score;
  var second = ranked.length > 1 ? ranked[1].score : 0.0;
  if (ranked.length > 1 && best - second < cfg.minMargin) {
    // Gleichstand (z. B. „Dune“ 1984 und 2021): nur grün, wenn der beste
    // deutlich bekannter ist als ALLE gleich guten – sonst wählt der Mensch.
    final p1 = top.hit.popularity ?? 0;
    final rivals = ranked.skip(1).where((r) => best - r.score < cfg.minMargin);
    final clear = rivals.every((r) {
      final p2 = r.hit.popularity ?? 0;
      return p2 <= 0 || p1 / p2 >= 3;
    });
    second = clear ? 0.0 : best;
  }
  if (best >= cfg.greenThreshold && best - second >= cfg.minMargin) {
    final pop = top.hit.popularity;
    final known = pop == null || pop >= minPopularityForGreen;
    var coverage = 1.0;
    if (spineText != null) {
      coverage = 0;
      for (final text in [spineText, ...altTexts]) {
        for (final title in {top.hit.title, if (top.hit.originalTitle != null) top.hit.originalTitle!}) {
          coverage = math.max(coverage, spineLetterCoverage(title, text));
        }
      }
    }
    if (known && coverage >= minLetterCoverageForGreen) return MatchStatus.green;
    return MatchStatus.yellow;
  }
  if (best >= cfg.yellowThreshold) return MatchStatus.yellow;
  return MatchStatus.red;
}

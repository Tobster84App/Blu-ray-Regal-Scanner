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

double _tokenScore(List<String> t, List<String> s) {
  final usedS = List<bool>.filled(s.length, false);
  var tWeight = 0.0, tMatched = 0.0;
  for (final tt in t) {
    final w = tokenWeight(tt);
    tWeight += w;
    for (var i = 0; i < s.length; i++) {
      if (!usedS[i] && tokensMatch(tt, s[i])) {
        usedS[i] = true;
        tMatched += w;
        break;
      }
    }
  }
  var sWeight = 0.0, sMatched = 0.0;
  for (var i = 0; i < s.length; i++) {
    final w = tokenWeight(s[i]);
    sWeight += w;
    if (usedS[i]) sMatched += w;
  }
  if (tWeight == 0 || sWeight == 0) return 0;
  final titleCoverage = tMatched / tWeight;
  final spineCoverage = sMatched / sWeight;
  return titleCoverage * (0.75 + 0.25 * spineCoverage);
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

/// Sortiert die Kandidaten nach Wert (Gleichstand: Beliebtheit).
List<ScoredHit> rankHits(Iterable<SearchHit> hits, String spineText) {
  final seen = <String>{};
  final scored = <ScoredHit>[];
  for (final h in hits) {
    if (!seen.add(h.key)) continue;
    scored.add(ScoredHit(h, scoreHit(h, spineText)));
  }
  scored.sort((a, b) {
    final d = b.score.compareTo(a.score);
    if (d.abs() > 0 && (a.score - b.score).abs() > 1e-9) return d;
    return (b.hit.popularity ?? 0).compareTo(a.hit.popularity ?? 0);
  });
  return scored;
}

MatchStatus classify(
  List<ScoredHit> ranked, {
  required bool cutOff,
  required RecognitionConfig cfg,
}) {
  if (cutOff) return MatchStatus.grey;
  if (ranked.isEmpty) return MatchStatus.red;
  final top = ranked.first;
  final best = top.score;
  var second = ranked.length > 1 ? ranked[1].score : 0.0;
  if (ranked.length > 1 && _sameTitle(top.hit, ranked[1].hit)) {
    // Gleicher Titel (z. B. „Dune“ 1984 und 2021): nur grün, wenn einer
    // deutlich bekannter ist – sonst soll der Mensch wählen.
    final p1 = top.hit.popularity ?? 0, p2 = ranked[1].hit.popularity ?? 0;
    second = (p2 > 0 && p1 / p2 >= 3) ? 0.0 : best;
  }
  if (best >= cfg.greenThreshold && best - second >= cfg.minMargin) {
    return MatchStatus.green;
  }
  if (best >= cfg.yellowThreshold) return MatchStatus.yellow;
  return MatchStatus.red;
}

bool _sameTitle(SearchHit a, SearchHit b) =>
    normalize(a.title) == normalize(b.title);

import 'dart:async';

import '../config/app_config.dart';
import '../metadata/metadata_provider.dart';
import 'format_detector.dart';
import 'matcher.dart';
import 'models.dart';
import 'blocklist.dart';
import 'query_builder.dart';

/// Ergebnis für eine Hülle auf dem Foto.
class SpineResult {
  SpineResult({
    required this.box,
    List<Pt>? polygon,
    this.fromAi = false,
    required this.rawText,
    required this.cleanedText,
    required this.format,
    required this.status,
    required this.candidates,
    this.manual = false,
    this.error,
  }) : polygon = polygon ?? box.corners;

  Box box;

  /// Schräger Rahmen für die Anzeige.
  List<Pt> polygon;

  /// Titel stammt aus der KI-Erkennung.
  final bool fromAi;
  final String rawText;
  final String cleanedText;
  DiscFormat? format;
  MatchStatus status;

  /// Die besten Vorschläge, absteigend.
  List<ScoredHit> candidates;

  /// Vom Nutzer gewählter Treffer (überschreibt [candidates].first).
  SearchHit? chosen;

  /// Bereits in die Sammlung übernommen.
  bool accepted = false;

  /// Vom Nutzer selbst gezogener Rahmen.
  final bool manual;
  final String? error;

  SearchHit? get best =>
      chosen ?? (candidates.isEmpty ? null : candidates.first.hit);
}

/// Sucht für jede Hülle passende Titel und bewertet sie.
class SpineMatcher {
  SpineMatcher(this.provider, {this.cfg = const RecognitionConfig()});

  final MetadataProvider provider;
  final RecognitionConfig cfg;

  Future<SpineResult> match(Spine spine, {required String language}) async {
    if (!spine.hasText || RegExp(r'[a-z]').allMatches(spine.cleanedText).length < 3) {
      return SpineResult(
        box: spine.box,
        polygon: spine.polygon,
        rawText: spine.rawText,
        cleanedText: '',
        format: spine.format,
        status: spine.cutOff ? MatchStatus.grey : MatchStatus.red,
        candidates: const [],
      );
    }
    final queries = buildQueries(spine.cleanedLines, max: cfg.maxQueriesPerSpine);
    // Andere Lesungen derselben Zeilen als weitere Suchen (zeilenweise,
    // weil TMDB alle Wörter verlangt).
    for (final l in spine.lines) {
      for (final alt in l.alternatives) {
        final ca = cleanLine(alt);
        if (ca == null || queries.contains(ca)) continue;
        if (queries.length >= cfg.maxQueriesPerSpine + 4) break;
        queries.add(ca);
      }
    }
    // Vorangestellten Artikel abtrennen: „theflas“ -> „the flas“.
    for (final q in [...queries]) {
      final split = splitLeadingArticles(q);
      if (split != q && !queries.contains(split)) queries.add(split);
    }
    final hits = <SearchHit>[];
    String? error;
    for (final q in queries) {
      try {
        hits.addAll(await provider.search(q, language: language));
      } on MetadataException catch (e) {
        error = e.message;
        if (e.statusCode == 401) break;
      } on Exception catch (e) {
        error = '$e';
      }
    }
    var ranked = rankHits(hits, spine.cleanedText, rawText: spine.rawText, altTexts: spine.altTexts);
    if (ranked.isEmpty || ranked.first.score < cfg.yellowThreshold) {
      // Nichts Brauchbares: Ersatz-Suchen gegen Lesefehler.
      for (final q in buildFallbackQueries([spine.cleanedText, ...spine.altTexts])) {
        if (queries.contains(q)) continue;
        try {
          hits.addAll(await provider.search(q, language: language));
        } on Exception {
          // ignorieren
        }
      }
      ranked = rankHits(hits, spine.cleanedText, rawText: spine.rawText, altTexts: spine.altTexts);
    }
    return SpineResult(
      box: spine.box,
        polygon: spine.polygon,
      rawText: spine.rawText,
      cleanedText: spine.cleanedText,
      format: spine.format,
      status: classify(ranked, cutOff: spine.cutOff, cfg: cfg,
          spineText: spine.cleanedText, altTexts: spine.altTexts),
      candidates: ranked.take(3).toList(),
      error: hits.isEmpty ? error : null,
    );
  }

  /// Alle Hüllen, mit begrenzter Parallelität.
  Future<List<SpineResult>> matchAll(
    List<Spine> spines, {
    required String language,
    int parallel = 4,
    void Function(int done, int total)? onProgress,
  }) async {
    final results = List<SpineResult?>.filled(spines.length, null);
    var next = 0, done = 0;
    Future<void> worker() async {
      while (next < spines.length) {
        final i = next++;
        results[i] = await match(spines[i], language: language);
        done++;
        onProgress?.call(done, spines.length);
      }
    }

    await Future.wait(List.generate(parallel, (_) => worker()));
    return results.cast<SpineResult>();
  }
}

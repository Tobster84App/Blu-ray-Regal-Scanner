/// Erzeugt Suchvarianten für eine Hülle: ganzer Text, längste Zeile,
/// Zeilenkombinationen und einzelne Zeilen.
List<String> buildQueries(List<String> cleanedLines, {int max = 6}) {
  final out = <String>[];
  void add(String q) {
    final t = q.trim();
    if (t.length < 2) return;
    if (t.split(' ').length > 10) return; // zu lang für eine sinnvolle Suche
    if (!out.contains(t)) out.add(t);
  }

  if (cleanedLines.isEmpty) return out;
  add(cleanedLines.join(' '));
  final byLength = [...cleanedLines]
    ..sort((a, b) => b.length.compareTo(a.length));
  add(byLength.first);
  for (var i = 0; i + 1 < cleanedLines.length; i++) {
    add('${cleanedLines[i]} ${cleanedLines[i + 1]}');
  }
  for (final l in byLength.skip(1)) {
    add(l);
  }
  return out.take(max).toList();
}

/// Ersatz-Suchen, wenn die normalen Varianten nichts finden: TMDB verlangt,
/// dass alle Wörter passen (Wortanfänge genügen). Daher einzelne Wörter
/// weglassen und lange Wörter auf ihren Anfang kürzen – so überstehen
/// Lesefehler wie „pacifc rim“ oder „deadpodl“ die Suche.
List<String> buildFallbackQueries(List<String> cleanedLines, {int max = 6}) {
  final out = <String>[];
  void add(String q) {
    final t = q.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.length < 3 || out.contains(t)) return;
    out.add(t);
  }

  final lines = [...cleanedLines]..sort((a, b) => b.length.compareTo(a.length));
  for (final line in lines) {
    final words = line.split(' ').where((w) => w.isNotEmpty).toList();
    // Lange Wörter kürzen.
    add(words.map((w) => w.length >= 7 ? w.substring(0, 5) : w).join(' '));
    // Je ein Wort weglassen (nur Wörter mit mind. 3 Buchstaben übrig).
    if (words.length >= 2) {
      for (var i = 0; i < words.length; i++) {
        final rest = [...words]..removeAt(i);
        if (rest.join().length >= 4) add(rest.join(' '));
      }
    }
  }
  return out.take(max).toList();
}

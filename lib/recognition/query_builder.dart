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

/// Zentrale Einstellungen der App.
///
/// Der App-Name steht NUR hier. Android liest ihn beim Bauen aus dieser
/// Datei (siehe android/app/build.gradle.kts), die App selbst nutzt [appName].
library;

// ignore: constant_identifier_names
const String APP_NAME = "DiscScanner";

const String appName = APP_NAME;

/// TMDB-Schlüssel aus dem Build (`--dart-define=TMDB_API_KEY=...`).
/// Kann in den Einstellungen durch einen eigenen Schlüssel ersetzt werden.
const String buildTmdbApiKey = String.fromEnvironment('TMDB_API_KEY');

/// Standardwerte der Erkennung (in den Einstellungen änderbar, sofern dort
/// angeboten).
class RecognitionConfig {
  const RecognitionConfig({
    this.greenThreshold = 0.85,
    this.yellowThreshold = 0.5,
    this.minMargin = 0.05,
    this.edgeMarginFraction = 0.015,
    this.maxQueriesPerSpine = 6,
    this.minLineConfidence = 0.4,
    this.spineGapFactor = 0.25,
  });

  /// Ab diesem Wert ist ein Treffer „sicher“ (grün).
  final double greenThreshold;

  /// Ab diesem Wert wird ein Treffer als Vorschlag gezeigt (gelb), darunter rot.
  final double yellowThreshold;

  /// Mindestabstand zwischen bestem und zweitbestem Treffer für Grün.
  final double minMargin;

  /// Anteil der Bildbreite am linken/rechten Rand, ab dem eine Hülle als
  /// angeschnitten gilt.
  final double edgeMarginFraction;

  final int maxQueriesPerSpine;

  /// Zeilen mit geringerer ML-Kit-Konfidenz werden verworfen (falls die
  /// Plattform eine Konfidenz liefert).
  final double minLineConfidence;

  /// Zwei senkrechte Textzeilen gehören zur selben Hülle, wenn der Abstand
  /// kleiner ist als dieser Faktor mal die typische Zeilendicke.
  final double spineGapFactor;

  RecognitionConfig copyWith({double? greenThreshold}) => RecognitionConfig(
        greenThreshold: greenThreshold ?? this.greenThreshold,
        yellowThreshold: yellowThreshold,
        minMargin: minMargin,
        edgeMarginFraction: edgeMarginFraction,
        maxQueriesPerSpine: maxQueriesPerSpine,
        minLineConfidence: minLineConfidence,
        spineGapFactor: spineGapFactor,
      );
}

/// TMDB verlangt, zwischengespeicherte Daten nach spätestens 6 Monaten zu
/// erneuern.
const Duration metadataMaxAge = Duration(days: 180);

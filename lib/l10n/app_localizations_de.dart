// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get collection => 'Sammlung';

  @override
  String get scanShelf => 'Regal scannen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get pickFromGallery => 'Aus Galerie wählen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get about => 'Info / Über';

  @override
  String get search => 'Suchen';

  @override
  String get searchCollection => 'In der Sammlung suchen';

  @override
  String get emptyCollection =>
      'Noch keine Filme. Fotografiere dein Regal, um loszulegen.';

  @override
  String get noResults => 'Keine Treffer für diese Filter.';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sortierung';

  @override
  String get sortTitle => 'Titel';

  @override
  String get sortYear => 'Jahr';

  @override
  String get sortAdded => 'Hinzugefügt';

  @override
  String get sortRating => 'Eigene Bewertung';

  @override
  String get descending => 'Absteigend';

  @override
  String get all => 'Alle';

  @override
  String get format => 'Format';

  @override
  String get genre => 'Genre';

  @override
  String get watched => 'Gesehen';

  @override
  String get notWatched => 'Nicht gesehen';

  @override
  String get movie => 'Film';

  @override
  String get tvShow => 'Serie';

  @override
  String get type => 'Art';

  @override
  String get resetFilters => 'Filter zurücksetzen';

  @override
  String get gridView => 'Rasteransicht';

  @override
  String get listView => 'Listenansicht';

  @override
  String countSummary(int total, int dvd, int bluray, int uhd) {
    return '$total Titel · DVD $dvd · Blu-ray $bluray · UHD $uhd';
  }

  @override
  String get formatDvd => 'DVD';

  @override
  String get formatBluray => 'Blu-ray';

  @override
  String get formatUhd => '4K UHD';

  @override
  String get recognizing => 'Erkenne Text …';

  @override
  String get preparingImage => 'Bereite Foto vor …';

  @override
  String ocrPass(int n) {
    return 'Texterkennung $n von 3 …';
  }

  @override
  String searchingTitles(int done, int total) {
    return 'Suche Titel $done von $total …';
  }

  @override
  String scanSummary(int green, int yellow, int red, int grey) {
    return '$green sicher · $yellow unsicher · $red nicht gefunden · $grey angeschnitten';
  }

  @override
  String acceptAllGreen(int n) {
    return 'Alle grünen übernehmen ($n)';
  }

  @override
  String get addMissingSpine => 'Fehlende Hülle hinzufügen';

  @override
  String get drawSpineHint => 'Ziehe einen Rahmen um die Hülle.';

  @override
  String get manualSearch => 'Manuell suchen';

  @override
  String get manualSearchHint => 'Titel eingeben';

  @override
  String get recognizedText => 'Erkannter Text';

  @override
  String get noTextRecognized => 'Kein Text erkannt';

  @override
  String get suggestions => 'Vorschläge';

  @override
  String get accept => 'Übernehmen';

  @override
  String get accepted => 'Übernommen';

  @override
  String get cutOffHint =>
      'Diese Hülle ist am Bildrand angeschnitten. Bitte neu fotografieren.';

  @override
  String get noMatchHint => 'Kein passender Titel gefunden.';

  @override
  String addedCount(int created, int merged, int unchanged) {
    return '$created neu, $merged Format ergänzt, $unchanged schon vorhanden';
  }

  @override
  String get noTmdbKey =>
      'Kein TMDB-Schlüssel hinterlegt. Ohne Schlüssel können keine Titel gesucht werden.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String error(String message) {
    return 'Fehler: $message';
  }

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get noSpinesFound =>
      'Auf dem Foto wurde keine Hülle mit Text gefunden.';

  @override
  String get overview => 'Inhalt';

  @override
  String get cast => 'Besetzung';

  @override
  String get director => 'Regie';

  @override
  String get creator => 'Idee';

  @override
  String runtimeMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String seasons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Staffeln',
      one: '1 Staffel',
    );
    return '$_temp0';
  }

  @override
  String tmdbRating(String rating) {
    return 'TMDB $rating';
  }

  @override
  String get watchTrailer => 'Trailer ansehen';

  @override
  String get myData => 'Meine Angaben';

  @override
  String get formats => 'Formate';

  @override
  String get edition => 'Ausgabe';

  @override
  String get steelbook => 'Steelbook';

  @override
  String get mediabook => 'Mediabook';

  @override
  String get boxset => 'Boxset';

  @override
  String get myRating => 'Eigene Bewertung';

  @override
  String get noRating => 'Keine';

  @override
  String get location => 'Regal / Standort';

  @override
  String get notes => 'Notizen';

  @override
  String addedOn(String date) {
    return 'Hinzugefügt am $date';
  }

  @override
  String lastUpdated(String date) {
    return 'Daten vom $date';
  }

  @override
  String get refreshData => 'Daten aktualisieren';

  @override
  String get delete => 'Löschen';

  @override
  String deleteConfirm(String title) {
    return '„$title“ aus der Sammlung löschen?';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Wie das Gerät';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'Englisch';

  @override
  String get reloadDataQuestion => 'Filmdaten in der neuen Sprache neu laden?';

  @override
  String reloading(int done, int total) {
    return 'Lade Filmdaten neu: $done von $total';
  }

  @override
  String reloadDone(int n) {
    return '$n Einträge aktualisiert';
  }

  @override
  String greenThreshold(String value) {
    return 'Schwelle für sichere Treffer: $value';
  }

  @override
  String get tmdbKey => 'Eigener TMDB-Schlüssel';

  @override
  String get tmdbKeyHelp =>
      'API-Schlüssel (v3) oder Lesezugriffstoken (v4). Wird verschlüsselt auf dem Gerät gespeichert.';

  @override
  String get tmdbKeyFromBuild =>
      'Ein Schlüssel aus dem Build ist vorhanden. Ein eigener ersetzt ihn.';

  @override
  String get tmdbAttribution =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get aboutText =>
      'Erfasse deine Film- und Seriensammlung, indem du dein Regal fotografierst. Alle Daten bleiben auf deinem Gerät. Keine Konten, keine Werbung. Welche Dienste genutzt werden, steht unter „Datenschutz“.';

  @override
  String get dataSources => 'Datenquellen';

  @override
  String get textRecognitionInfo =>
      'Texterkennung: Google ML Kit, direkt auf dem Gerät.';

  @override
  String version(String v) {
    return 'Version $v';
  }

  @override
  String get staleRefreshing => 'Aktualisiere ältere Filmdaten …';

  @override
  String get zoomHint =>
      'Zum Vergrößern mit zwei Fingern ziehen. Rahmen antippen.';

  @override
  String get chooseFormat => 'Format wählen';

  @override
  String searchFailed(String message) {
    return 'Suche fehlgeschlagen: $message';
  }

  @override
  String get unknown => 'unbekannt';

  @override
  String get imprint => 'Impressum';

  @override
  String get imprintLegalBasis => 'Angaben gemäß § 5 DDG';

  @override
  String get country => 'Deutschland';

  @override
  String get contact => 'Kontakt';

  @override
  String email(String address) {
    return 'E-Mail: $address';
  }

  @override
  String get imprintResponsibleTitle => 'Verantwortlich für den Inhalt';

  @override
  String imprintResponsible(String name) {
    return '$name, Anschrift wie oben';
  }

  @override
  String get imprintDataTitle => 'Filmdaten';

  @override
  String get imprintData =>
      'Titel, Inhaltsangaben, Bilder und weitere Filmdaten stammen von The Movie Database (TMDB). Für deren Richtigkeit übernehmen wir keine Gewähr.';

  @override
  String get imprintLinksTitle => 'Haftung für Links';

  @override
  String get imprintLinks =>
      'Die App enthält Links zu Angeboten Dritter, etwa YouTube für Trailer. Auf deren Inhalte haben wir keinen Einfluss; dafür ist der jeweilige Anbieter verantwortlich.';

  @override
  String get imprintDisputeTitle => 'Verbraucherstreitbeilegung';

  @override
  String get imprintDispute =>
      'Wir sind nicht bereit und nicht verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen.';

  @override
  String get imprintTranslationNote => '';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get privacyIntro =>
      'Deine Sammlung, Fotos und Einstellungen werden nur auf diesem Gerät gespeichert. Es gibt keine Konten, keine Werbung und keine Cloud. Folgende Dienste werden genutzt:';

  @override
  String get privacyMlkitTitle => 'Texterkennung (Google ML Kit)';

  @override
  String get privacyMlkit =>
      'Die Erkennung der Schrift auf deinen Fotos läuft vollständig auf dem Gerät; Fotos und erkannter Text werden nicht an Google gesendet. ML Kit überträgt jedoch Nutzungs- und Diagnosedaten an Google: Gerätehersteller und -modell, Android-Version, Name und Version der App, Leistungswerte (z. B. Dauer) sowie eine Kennung pro Installation, die laut Google nicht dazu gedacht ist, dich oder dein Gerät eindeutig zu identifizieren. Google nutzt diese Daten, um ML Kit zu verbessern und Missbrauch zu erkennen. Abschalten lässt sich das nicht.';

  @override
  String get privacyTmdbTitle => 'Filmdaten (TMDB)';

  @override
  String get privacyTmdb =>
      'Zur Titelsuche werden die erkannten bzw. eingegebenen Suchbegriffe an The Movie Database (TMDB) gesendet; Poster und Bilder werden von TMDB geladen. Dabei erhält TMDB technisch bedingt deine IP-Adresse. Es gilt die Datenschutzerklärung von TMDB.';

  @override
  String get privacyYoutubeTitle => 'Trailer (YouTube)';

  @override
  String get privacyYoutube =>
      '„Trailer ansehen“ öffnet YouTube in der YouTube-App oder im Browser. Erst dann gelten die Datenschutzbestimmungen von Google/YouTube.';

  @override
  String get privacyKeyTitle => 'API-Schlüssel';

  @override
  String get privacyKey =>
      'Ein selbst eingetragener TMDB-Schlüssel wird verschlüsselt auf dem Gerät gespeichert und nur an TMDB gesendet.';

  @override
  String get privacyLinks => 'Weitere Informationen';

  @override
  String get aiRecognizing => 'KI erkennt die Hüllen …';

  @override
  String get refiningFrames => 'Rahmen werden verfeinert …';

  @override
  String aiFailed(String message) {
    return 'KI-Erkennung fehlgeschlagen ($message). Es wird ML Kit verwendet.';
  }

  @override
  String get aiSection => 'KI-Erkennung';

  @override
  String get aiEnable => 'KI-Erkennung verwenden';

  @override
  String get aiExplain =>
      'Mit einem eigenen, kostenlosen Google-Gemini-Schlüssel erkennt die App Hüllen deutlich zuverlässiger und schneller. Ohne Schlüssel arbeitet die App nur auf dem Gerät (ML Kit).';

  @override
  String get aiGetKey => 'Schlüssel bei Google anlegen';

  @override
  String get aiGetKeyHelp =>
      'Mit deinem Google-Konto anmelden → „API-Schlüssel erstellen“ → Schlüssel kopieren und hier einfügen.';

  @override
  String get aiKey => 'KI-Schlüssel';

  @override
  String get aiModel => 'Modell';

  @override
  String get aiBaseUrl => 'Adresse der Schnittstelle';

  @override
  String get aiAdvanced => 'Erweitert (anderer Anbieter)';

  @override
  String get aiTest => 'Verbindung testen';

  @override
  String get aiTestOk => 'Verbindung klappt.';

  @override
  String get aiConsentTitle => 'Fotos an Google senden?';

  @override
  String get aiConsentText =>
      'Bei eingeschalteter KI-Erkennung wird jedes Regalfoto (verkleinert) an Google Gemini gesendet, um die Titel zu lesen. Laut Google werden die Fotos in der EU nicht zum Training verwendet, aber zeitweise zur Missbrauchserkennung gespeichert. Es gilt die Datenschutzerklärung von Google. Hinweis: Google sieht für Nutzer in der EU den kostenpflichtigen Tarif vor, wenn eine App die Schnittstelle bereitstellt.';

  @override
  String get aiConsentAccept => 'Einverstanden';

  @override
  String get privacyAiTitle => 'KI-Erkennung (optional)';

  @override
  String get privacyAi =>
      'Nur wenn du die KI-Erkennung mit eigenem Schlüssel einschaltest: Jedes Regalfoto wird verkleinert an Google Gemini (bzw. den eingestellten Anbieter) gesendet. Laut Google werden die Inhalte bei Nutzung aus der EU nicht zum Training verwendet, aber zeitweise zur Missbrauchserkennung gespeichert.';

  @override
  String get aiNoKey =>
      'Bitte zuerst deinen Gemini-Schlüssel ins Feld „KI-Schlüssel“ einfügen.';
}

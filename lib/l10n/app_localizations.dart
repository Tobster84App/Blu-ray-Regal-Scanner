import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @collection.
  ///
  /// In de, this message translates to:
  /// **'Sammlung'**
  String get collection;

  /// No description provided for @scanShelf.
  ///
  /// In de, this message translates to:
  /// **'Regal scannen'**
  String get scanShelf;

  /// No description provided for @takePhoto.
  ///
  /// In de, this message translates to:
  /// **'Foto aufnehmen'**
  String get takePhoto;

  /// No description provided for @pickFromGallery.
  ///
  /// In de, this message translates to:
  /// **'Aus Galerie wählen'**
  String get pickFromGallery;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In de, this message translates to:
  /// **'Info / Über'**
  String get about;

  /// No description provided for @search.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get search;

  /// No description provided for @searchCollection.
  ///
  /// In de, this message translates to:
  /// **'In der Sammlung suchen'**
  String get searchCollection;

  /// No description provided for @emptyCollection.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Filme. Fotografiere dein Regal, um loszulegen.'**
  String get emptyCollection;

  /// No description provided for @noResults.
  ///
  /// In de, this message translates to:
  /// **'Keine Treffer für diese Filter.'**
  String get noResults;

  /// No description provided for @filter.
  ///
  /// In de, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In de, this message translates to:
  /// **'Sortierung'**
  String get sort;

  /// No description provided for @sortTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get sortTitle;

  /// No description provided for @sortYear.
  ///
  /// In de, this message translates to:
  /// **'Jahr'**
  String get sortYear;

  /// No description provided for @sortAdded.
  ///
  /// In de, this message translates to:
  /// **'Hinzugefügt'**
  String get sortAdded;

  /// No description provided for @sortRating.
  ///
  /// In de, this message translates to:
  /// **'Eigene Bewertung'**
  String get sortRating;

  /// No description provided for @descending.
  ///
  /// In de, this message translates to:
  /// **'Absteigend'**
  String get descending;

  /// No description provided for @all.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get all;

  /// No description provided for @format.
  ///
  /// In de, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @genre.
  ///
  /// In de, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @watched.
  ///
  /// In de, this message translates to:
  /// **'Gesehen'**
  String get watched;

  /// No description provided for @notWatched.
  ///
  /// In de, this message translates to:
  /// **'Nicht gesehen'**
  String get notWatched;

  /// No description provided for @movie.
  ///
  /// In de, this message translates to:
  /// **'Film'**
  String get movie;

  /// No description provided for @tvShow.
  ///
  /// In de, this message translates to:
  /// **'Serie'**
  String get tvShow;

  /// No description provided for @type.
  ///
  /// In de, this message translates to:
  /// **'Art'**
  String get type;

  /// No description provided for @resetFilters.
  ///
  /// In de, this message translates to:
  /// **'Filter zurücksetzen'**
  String get resetFilters;

  /// No description provided for @gridView.
  ///
  /// In de, this message translates to:
  /// **'Rasteransicht'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In de, this message translates to:
  /// **'Listenansicht'**
  String get listView;

  /// No description provided for @countSummary.
  ///
  /// In de, this message translates to:
  /// **'{total} Titel · DVD {dvd} · Blu-ray {bluray} · UHD {uhd}'**
  String countSummary(int total, int dvd, int bluray, int uhd);

  /// No description provided for @formatDvd.
  ///
  /// In de, this message translates to:
  /// **'DVD'**
  String get formatDvd;

  /// No description provided for @formatBluray.
  ///
  /// In de, this message translates to:
  /// **'Blu-ray'**
  String get formatBluray;

  /// No description provided for @formatUhd.
  ///
  /// In de, this message translates to:
  /// **'4K UHD'**
  String get formatUhd;

  /// No description provided for @recognizing.
  ///
  /// In de, this message translates to:
  /// **'Erkenne Text …'**
  String get recognizing;

  /// No description provided for @preparingImage.
  ///
  /// In de, this message translates to:
  /// **'Bereite Foto vor …'**
  String get preparingImage;

  /// No description provided for @ocrPass.
  ///
  /// In de, this message translates to:
  /// **'Texterkennung {n} von 3 …'**
  String ocrPass(int n);

  /// No description provided for @searchingTitles.
  ///
  /// In de, this message translates to:
  /// **'Suche Titel {done} von {total} …'**
  String searchingTitles(int done, int total);

  /// No description provided for @scanSummary.
  ///
  /// In de, this message translates to:
  /// **'{green} sicher · {yellow} unsicher · {red} nicht gefunden · {grey} angeschnitten'**
  String scanSummary(int green, int yellow, int red, int grey);

  /// No description provided for @acceptAllGreen.
  ///
  /// In de, this message translates to:
  /// **'Alle grünen übernehmen ({n})'**
  String acceptAllGreen(int n);

  /// No description provided for @addMissingSpine.
  ///
  /// In de, this message translates to:
  /// **'Fehlende Hülle hinzufügen'**
  String get addMissingSpine;

  /// No description provided for @drawSpineHint.
  ///
  /// In de, this message translates to:
  /// **'Ziehe einen Rahmen um die Hülle.'**
  String get drawSpineHint;

  /// No description provided for @manualSearch.
  ///
  /// In de, this message translates to:
  /// **'Manuell suchen'**
  String get manualSearch;

  /// No description provided for @manualSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Titel eingeben'**
  String get manualSearchHint;

  /// No description provided for @recognizedText.
  ///
  /// In de, this message translates to:
  /// **'Erkannter Text'**
  String get recognizedText;

  /// No description provided for @noTextRecognized.
  ///
  /// In de, this message translates to:
  /// **'Kein Text erkannt'**
  String get noTextRecognized;

  /// No description provided for @suggestions.
  ///
  /// In de, this message translates to:
  /// **'Vorschläge'**
  String get suggestions;

  /// No description provided for @accept.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get accept;

  /// No description provided for @accepted.
  ///
  /// In de, this message translates to:
  /// **'Übernommen'**
  String get accepted;

  /// No description provided for @cutOffHint.
  ///
  /// In de, this message translates to:
  /// **'Diese Hülle ist am Bildrand angeschnitten. Bitte neu fotografieren.'**
  String get cutOffHint;

  /// No description provided for @noMatchHint.
  ///
  /// In de, this message translates to:
  /// **'Kein passender Titel gefunden.'**
  String get noMatchHint;

  /// No description provided for @addedCount.
  ///
  /// In de, this message translates to:
  /// **'{created} neu, {merged} Format ergänzt, {unchanged} schon vorhanden'**
  String addedCount(int created, int merged, int unchanged);

  /// No description provided for @noTmdbKey.
  ///
  /// In de, this message translates to:
  /// **'Kein TMDB-Schlüssel hinterlegt. Ohne Schlüssel können keine Titel gesucht werden.'**
  String get noTmdbKey;

  /// No description provided for @openSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen öffnen'**
  String get openSettings;

  /// No description provided for @error.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {message}'**
  String error(String message);

  /// No description provided for @retry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get retry;

  /// No description provided for @noSpinesFound.
  ///
  /// In de, this message translates to:
  /// **'Auf dem Foto wurde keine Hülle mit Text gefunden.'**
  String get noSpinesFound;

  /// No description provided for @overview.
  ///
  /// In de, this message translates to:
  /// **'Inhalt'**
  String get overview;

  /// No description provided for @cast.
  ///
  /// In de, this message translates to:
  /// **'Besetzung'**
  String get cast;

  /// No description provided for @director.
  ///
  /// In de, this message translates to:
  /// **'Regie'**
  String get director;

  /// No description provided for @creator.
  ///
  /// In de, this message translates to:
  /// **'Idee'**
  String get creator;

  /// No description provided for @runtimeMinutes.
  ///
  /// In de, this message translates to:
  /// **'{minutes} Min.'**
  String runtimeMinutes(int minutes);

  /// No description provided for @seasons.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Staffel} other{{count} Staffeln}}'**
  String seasons(int count);

  /// No description provided for @tmdbRating.
  ///
  /// In de, this message translates to:
  /// **'TMDB {rating}'**
  String tmdbRating(String rating);

  /// No description provided for @watchTrailer.
  ///
  /// In de, this message translates to:
  /// **'Trailer ansehen'**
  String get watchTrailer;

  /// No description provided for @myData.
  ///
  /// In de, this message translates to:
  /// **'Meine Angaben'**
  String get myData;

  /// No description provided for @formats.
  ///
  /// In de, this message translates to:
  /// **'Formate'**
  String get formats;

  /// No description provided for @edition.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe'**
  String get edition;

  /// No description provided for @steelbook.
  ///
  /// In de, this message translates to:
  /// **'Steelbook'**
  String get steelbook;

  /// No description provided for @mediabook.
  ///
  /// In de, this message translates to:
  /// **'Mediabook'**
  String get mediabook;

  /// No description provided for @boxset.
  ///
  /// In de, this message translates to:
  /// **'Boxset'**
  String get boxset;

  /// No description provided for @myRating.
  ///
  /// In de, this message translates to:
  /// **'Eigene Bewertung'**
  String get myRating;

  /// No description provided for @noRating.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get noRating;

  /// No description provided for @location.
  ///
  /// In de, this message translates to:
  /// **'Regal / Standort'**
  String get location;

  /// No description provided for @notes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get notes;

  /// No description provided for @addedOn.
  ///
  /// In de, this message translates to:
  /// **'Hinzugefügt am {date}'**
  String addedOn(String date);

  /// No description provided for @lastUpdated.
  ///
  /// In de, this message translates to:
  /// **'Daten vom {date}'**
  String lastUpdated(String date);

  /// No description provided for @refreshData.
  ///
  /// In de, this message translates to:
  /// **'Daten aktualisieren'**
  String get refreshData;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @deleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ aus der Sammlung löschen?'**
  String deleteConfirm(String title);

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @yes.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get no;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In de, this message translates to:
  /// **'Wie das Gerät'**
  String get languageSystem;

  /// No description provided for @german.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @english.
  ///
  /// In de, this message translates to:
  /// **'Englisch'**
  String get english;

  /// No description provided for @reloadDataQuestion.
  ///
  /// In de, this message translates to:
  /// **'Filmdaten in der neuen Sprache neu laden?'**
  String get reloadDataQuestion;

  /// No description provided for @reloading.
  ///
  /// In de, this message translates to:
  /// **'Lade Filmdaten neu: {done} von {total}'**
  String reloading(int done, int total);

  /// No description provided for @reloadDone.
  ///
  /// In de, this message translates to:
  /// **'{n} Einträge aktualisiert'**
  String reloadDone(int n);

  /// No description provided for @greenThreshold.
  ///
  /// In de, this message translates to:
  /// **'Schwelle für sichere Treffer: {value}'**
  String greenThreshold(String value);

  /// No description provided for @tmdbKey.
  ///
  /// In de, this message translates to:
  /// **'Eigener TMDB-Schlüssel'**
  String get tmdbKey;

  /// No description provided for @tmdbKeyHelp.
  ///
  /// In de, this message translates to:
  /// **'API-Schlüssel (v3) oder Lesezugriffstoken (v4). Wird verschlüsselt auf dem Gerät gespeichert.'**
  String get tmdbKeyHelp;

  /// No description provided for @tmdbKeyFromBuild.
  ///
  /// In de, this message translates to:
  /// **'Ein Schlüssel aus dem Build ist vorhanden. Ein eigener ersetzt ihn.'**
  String get tmdbKeyFromBuild;

  /// No description provided for @tmdbAttribution.
  ///
  /// In de, this message translates to:
  /// **'This product uses the TMDB API but is not endorsed or certified by TMDB.'**
  String get tmdbAttribution;

  /// No description provided for @aboutText.
  ///
  /// In de, this message translates to:
  /// **'Erfasse deine Film- und Seriensammlung, indem du dein Regal fotografierst. Alle Daten bleiben auf deinem Gerät. Keine Konten, keine Werbung. Welche Dienste genutzt werden, steht unter „Datenschutz“.'**
  String get aboutText;

  /// No description provided for @dataSources.
  ///
  /// In de, this message translates to:
  /// **'Datenquellen'**
  String get dataSources;

  /// No description provided for @textRecognitionInfo.
  ///
  /// In de, this message translates to:
  /// **'Texterkennung: Google ML Kit, direkt auf dem Gerät.'**
  String get textRecognitionInfo;

  /// No description provided for @version.
  ///
  /// In de, this message translates to:
  /// **'Version {v}'**
  String version(String v);

  /// No description provided for @staleRefreshing.
  ///
  /// In de, this message translates to:
  /// **'Aktualisiere ältere Filmdaten …'**
  String get staleRefreshing;

  /// No description provided for @zoomHint.
  ///
  /// In de, this message translates to:
  /// **'Zum Vergrößern mit zwei Fingern ziehen. Rahmen antippen.'**
  String get zoomHint;

  /// No description provided for @chooseFormat.
  ///
  /// In de, this message translates to:
  /// **'Format wählen'**
  String get chooseFormat;

  /// No description provided for @searchFailed.
  ///
  /// In de, this message translates to:
  /// **'Suche fehlgeschlagen: {message}'**
  String searchFailed(String message);

  /// No description provided for @unknown.
  ///
  /// In de, this message translates to:
  /// **'unbekannt'**
  String get unknown;

  /// No description provided for @imprint.
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get imprint;

  /// No description provided for @imprintLegalBasis.
  ///
  /// In de, this message translates to:
  /// **'Angaben gemäß § 5 DDG'**
  String get imprintLegalBasis;

  /// No description provided for @country.
  ///
  /// In de, this message translates to:
  /// **'Deutschland'**
  String get country;

  /// No description provided for @contact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get contact;

  /// No description provided for @email.
  ///
  /// In de, this message translates to:
  /// **'E-Mail: {address}'**
  String email(String address);

  /// No description provided for @imprintResponsibleTitle.
  ///
  /// In de, this message translates to:
  /// **'Verantwortlich für den Inhalt'**
  String get imprintResponsibleTitle;

  /// No description provided for @imprintResponsible.
  ///
  /// In de, this message translates to:
  /// **'{name}, Anschrift wie oben'**
  String imprintResponsible(String name);

  /// No description provided for @imprintDataTitle.
  ///
  /// In de, this message translates to:
  /// **'Filmdaten'**
  String get imprintDataTitle;

  /// No description provided for @imprintData.
  ///
  /// In de, this message translates to:
  /// **'Titel, Inhaltsangaben, Bilder und weitere Filmdaten stammen von The Movie Database (TMDB). Für deren Richtigkeit übernehmen wir keine Gewähr.'**
  String get imprintData;

  /// No description provided for @imprintLinksTitle.
  ///
  /// In de, this message translates to:
  /// **'Haftung für Links'**
  String get imprintLinksTitle;

  /// No description provided for @imprintLinks.
  ///
  /// In de, this message translates to:
  /// **'Die App enthält Links zu Angeboten Dritter, etwa YouTube für Trailer. Auf deren Inhalte haben wir keinen Einfluss; dafür ist der jeweilige Anbieter verantwortlich.'**
  String get imprintLinks;

  /// No description provided for @imprintDisputeTitle.
  ///
  /// In de, this message translates to:
  /// **'Verbraucherstreitbeilegung'**
  String get imprintDisputeTitle;

  /// No description provided for @imprintDispute.
  ///
  /// In de, this message translates to:
  /// **'Wir sind nicht bereit und nicht verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen.'**
  String get imprintDispute;

  /// No description provided for @imprintTranslationNote.
  ///
  /// In de, this message translates to:
  /// **''**
  String get imprintTranslationNote;

  /// No description provided for @privacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get privacy;

  /// No description provided for @privacyIntro.
  ///
  /// In de, this message translates to:
  /// **'Deine Sammlung, Fotos und Einstellungen werden nur auf diesem Gerät gespeichert. Es gibt keine Konten, keine Werbung und keine Cloud. Folgende Dienste werden genutzt:'**
  String get privacyIntro;

  /// No description provided for @privacyMlkitTitle.
  ///
  /// In de, this message translates to:
  /// **'Texterkennung (Google ML Kit)'**
  String get privacyMlkitTitle;

  /// No description provided for @privacyMlkit.
  ///
  /// In de, this message translates to:
  /// **'Die Erkennung der Schrift auf deinen Fotos läuft vollständig auf dem Gerät; Fotos und erkannter Text werden nicht an Google gesendet. ML Kit überträgt jedoch Nutzungs- und Diagnosedaten an Google: Gerätehersteller und -modell, Android-Version, Name und Version der App, Leistungswerte (z. B. Dauer) sowie eine Kennung pro Installation, die laut Google nicht dazu gedacht ist, dich oder dein Gerät eindeutig zu identifizieren. Google nutzt diese Daten, um ML Kit zu verbessern und Missbrauch zu erkennen. Abschalten lässt sich das nicht.'**
  String get privacyMlkit;

  /// No description provided for @privacyTmdbTitle.
  ///
  /// In de, this message translates to:
  /// **'Filmdaten (TMDB)'**
  String get privacyTmdbTitle;

  /// No description provided for @privacyTmdb.
  ///
  /// In de, this message translates to:
  /// **'Zur Titelsuche werden die erkannten bzw. eingegebenen Suchbegriffe an The Movie Database (TMDB) gesendet; Poster und Bilder werden von TMDB geladen. Dabei erhält TMDB technisch bedingt deine IP-Adresse. Es gilt die Datenschutzerklärung von TMDB.'**
  String get privacyTmdb;

  /// No description provided for @privacyYoutubeTitle.
  ///
  /// In de, this message translates to:
  /// **'Trailer (YouTube)'**
  String get privacyYoutubeTitle;

  /// No description provided for @privacyYoutube.
  ///
  /// In de, this message translates to:
  /// **'„Trailer ansehen“ öffnet YouTube in der YouTube-App oder im Browser. Erst dann gelten die Datenschutzbestimmungen von Google/YouTube.'**
  String get privacyYoutube;

  /// No description provided for @privacyKeyTitle.
  ///
  /// In de, this message translates to:
  /// **'API-Schlüssel'**
  String get privacyKeyTitle;

  /// No description provided for @privacyKey.
  ///
  /// In de, this message translates to:
  /// **'Ein selbst eingetragener TMDB-Schlüssel wird verschlüsselt auf dem Gerät gespeichert und nur an TMDB gesendet.'**
  String get privacyKey;

  /// No description provided for @privacyLinks.
  ///
  /// In de, this message translates to:
  /// **'Weitere Informationen'**
  String get privacyLinks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

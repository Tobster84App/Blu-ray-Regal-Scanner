// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get collection => 'Collection';

  @override
  String get scanShelf => 'Scan shelf';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get search => 'Search';

  @override
  String get searchCollection => 'Search collection';

  @override
  String get emptyCollection =>
      'No movies yet. Take a photo of your shelf to get started.';

  @override
  String get noResults => 'No matches for these filters.';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortYear => 'Year';

  @override
  String get sortAdded => 'Date added';

  @override
  String get sortRating => 'My rating';

  @override
  String get descending => 'Descending';

  @override
  String get all => 'All';

  @override
  String get format => 'Format';

  @override
  String get genre => 'Genre';

  @override
  String get watched => 'Watched';

  @override
  String get notWatched => 'Not watched';

  @override
  String get movie => 'Movie';

  @override
  String get tvShow => 'TV show';

  @override
  String get type => 'Type';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get gridView => 'Grid view';

  @override
  String get listView => 'List view';

  @override
  String countSummary(int total, int dvd, int bluray, int uhd) {
    return '$total titles · DVD $dvd · Blu-ray $bluray · UHD $uhd';
  }

  @override
  String get formatDvd => 'DVD';

  @override
  String get formatBluray => 'Blu-ray';

  @override
  String get formatUhd => '4K UHD';

  @override
  String get recognizing => 'Recognizing text …';

  @override
  String get preparingImage => 'Preparing photo …';

  @override
  String ocrPass(int n) {
    return 'Text recognition $n of 3 …';
  }

  @override
  String searchingTitles(int done, int total) {
    return 'Searching titles $done of $total …';
  }

  @override
  String scanSummary(int green, int yellow, int red, int grey) {
    return '$green sure · $yellow unsure · $red not found · $grey cut off';
  }

  @override
  String acceptAllGreen(int n) {
    return 'Add all green ($n)';
  }

  @override
  String get addMissingSpine => 'Add missing case';

  @override
  String get drawSpineHint => 'Drag a frame around the case.';

  @override
  String get manualSearch => 'Search manually';

  @override
  String get manualSearchHint => 'Enter title';

  @override
  String get recognizedText => 'Recognized text';

  @override
  String get noTextRecognized => 'No text recognized';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get accept => 'Add';

  @override
  String get accepted => 'Added';

  @override
  String get cutOffHint =>
      'This case is cut off at the edge of the photo. Please take a new photo.';

  @override
  String get noMatchHint => 'No matching title found.';

  @override
  String addedCount(int created, int merged, int unchanged) {
    return '$created new, $merged format added, $unchanged already present';
  }

  @override
  String get noTmdbKey =>
      'No TMDB key set. Titles cannot be searched without a key.';

  @override
  String get openSettings => 'Open settings';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get retry => 'Retry';

  @override
  String get noSpinesFound => 'No case with text was found in the photo.';

  @override
  String get overview => 'Overview';

  @override
  String get cast => 'Cast';

  @override
  String get director => 'Director';

  @override
  String get creator => 'Created by';

  @override
  String runtimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String seasons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seasons',
      one: '1 season',
    );
    return '$_temp0';
  }

  @override
  String tmdbRating(String rating) {
    return 'TMDB $rating';
  }

  @override
  String get watchTrailer => 'Watch trailer';

  @override
  String get myData => 'My details';

  @override
  String get formats => 'Formats';

  @override
  String get edition => 'Edition';

  @override
  String get steelbook => 'Steelbook';

  @override
  String get mediabook => 'Mediabook';

  @override
  String get boxset => 'Box set';

  @override
  String get myRating => 'My rating';

  @override
  String get noRating => 'None';

  @override
  String get location => 'Shelf / location';

  @override
  String get notes => 'Notes';

  @override
  String addedOn(String date) {
    return 'Added on $date';
  }

  @override
  String lastUpdated(String date) {
    return 'Data from $date';
  }

  @override
  String get refreshData => 'Refresh data';

  @override
  String get delete => 'Delete';

  @override
  String deleteConfirm(String title) {
    return 'Delete “$title” from the collection?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Same as device';

  @override
  String get german => 'German';

  @override
  String get english => 'English';

  @override
  String get reloadDataQuestion => 'Reload movie data in the new language?';

  @override
  String reloading(int done, int total) {
    return 'Reloading movie data: $done of $total';
  }

  @override
  String reloadDone(int n) {
    return '$n entries updated';
  }

  @override
  String greenThreshold(String value) {
    return 'Threshold for sure matches: $value';
  }

  @override
  String get tmdbKey => 'Own TMDB key';

  @override
  String get tmdbKeyHelp =>
      'API key (v3) or read access token (v4). Stored encrypted on the device.';

  @override
  String get tmdbKeyFromBuild =>
      'A key from the build is present. Your own key replaces it.';

  @override
  String get tmdbAttribution =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get aboutText =>
      'Catalog your movie and TV collection by photographing your shelf. All data stays on your device. No accounts, no ads, no tracking.';

  @override
  String get dataSources => 'Data sources';

  @override
  String get textRecognitionInfo =>
      'Text recognition: Google ML Kit, on the device.';

  @override
  String version(String v) {
    return 'Version $v';
  }

  @override
  String get staleRefreshing => 'Refreshing older movie data …';

  @override
  String get zoomHint => 'Pinch to zoom. Tap a frame.';

  @override
  String get chooseFormat => 'Choose format';

  @override
  String searchFailed(String message) {
    return 'Search failed: $message';
  }

  @override
  String get unknown => 'unknown';

  @override
  String get imprint => 'Legal notice';

  @override
  String get imprintLegalBasis =>
      'Information according to § 5 DDG (German Digital Services Act)';

  @override
  String get country => 'Germany';

  @override
  String get contact => 'Contact';

  @override
  String email(String address) {
    return 'Email: $address';
  }

  @override
  String get imprintResponsibleTitle => 'Responsible for content';

  @override
  String imprintResponsible(String name) {
    return '$name, address as above';
  }

  @override
  String get imprintDataTitle => 'Movie data';

  @override
  String get imprintData =>
      'Titles, overviews, images and other movie data come from The Movie Database (TMDB). We do not guarantee their accuracy.';

  @override
  String get imprintLinksTitle => 'Liability for links';

  @override
  String get imprintLinks =>
      'The app contains links to third-party services, such as YouTube for trailers. We have no influence on their content; the respective provider is responsible for it.';

  @override
  String get imprintDisputeTitle => 'Consumer dispute resolution';

  @override
  String get imprintDispute =>
      'We are neither willing nor obliged to participate in dispute resolution proceedings before a consumer arbitration board.';

  @override
  String get imprintTranslationNote =>
      'Translation for convenience. The German version is legally binding.';
}

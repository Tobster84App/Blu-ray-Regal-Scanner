import 'package:discscanner/metadata/metadata_provider.dart';
import 'package:discscanner/metadata/tmdb_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Film-Details mit FSK, Regie, Trailer in App-Sprache', () {
    final d = TmdbProvider.parseDetails({
      'id': 458156,
      'title': 'John Wick: Kapitel 3',
      'original_title': 'John Wick: Chapter 3 - Parabellum',
      'release_date': '2019-05-15',
      'runtime': 131,
      'genres': [{'id': 28, 'name': 'Action'}, {'id': 53, 'name': 'Thriller'}],
      'overview': ' Text ',
      'vote_average': 7.4,
      'poster_path': '/p.jpg',
      'backdrop_path': '/b.jpg',
      'credits': {
        'cast': [for (var i = 0; i < 15; i++) {'name': 'Actor $i', 'character': 'Role $i'}],
        'crew': [{'job': 'Director', 'name': 'Chad Stahelski'}, {'job': 'Writer', 'name': 'X'}],
      },
      'videos': {'results': [
        {'site': 'YouTube', 'key': 'featDE', 'type': 'Featurette', 'iso_639_1': 'de'},
        {'site': 'YouTube', 'key': 'trEN', 'type': 'Trailer', 'iso_639_1': 'en', 'official': true},
        {'site': 'YouTube', 'key': 'trDE', 'type': 'Trailer', 'iso_639_1': 'de'},
      ]},
      'release_dates': {'results': [
        {'iso_3166_1': 'US', 'release_dates': [{'certification': 'R'}]},
        {'iso_3166_1': 'DE', 'release_dates': [{'certification': ''}, {'certification': '18'}]},
      ]},
    }, type: MediaType.movie, language: 'de-DE', country: 'DE');
    expect(d.year, 2019);
    expect(d.runtimeMinutes, 131);
    expect(d.genres, ['Action', 'Thriller']);
    expect(d.overview, 'Text');
    expect(d.certification, 'FSK 18');
    expect(d.directors, ['Chad Stahelski']);
    expect(d.cast.length, 10);
    expect(d.youtubeTrailerKey, 'trDE');
    expect(d.posterUrl, endsWith('/w500/p.jpg'));
  });

  test('Trailer: ohne deutschen Trailer -> englischer, nicht Featurette', () {
    expect(
      TmdbProvider.pickTrailer([
        {'site': 'YouTube', 'key': 'featDE', 'type': 'Featurette', 'iso_639_1': 'de'},
        {'site': 'YouTube', 'key': 'trEN', 'type': 'Trailer', 'iso_639_1': 'en'},
      ], 'de'),
      'trEN',
    );
  });

  test('Serie mit Staffeln und Altersfreigabe', () {
    final d = TmdbProvider.parseDetails({
      'id': 106379,
      'name': 'Fallout',
      'original_name': 'Fallout',
      'first_air_date': '2024-04-10',
      'number_of_seasons': 2,
      'episode_run_time': [60],
      'created_by': [{'name': 'Jonathan Nolan'}],
      'content_ratings': {'results': [{'iso_3166_1': 'DE', 'rating': '16'}]},
    }, type: MediaType.tv, language: 'de-DE', country: 'DE');
    expect(d.seasons, 2);
    expect(d.certification, 'FSK 16');
    expect(d.directors, ['Jonathan Nolan']);
    expect(d.runtimeMinutes, 60);
  });
}

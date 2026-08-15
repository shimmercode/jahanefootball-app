import 'package:flutter_test/flutter_test.dart';
import 'package:jahan_football/core/config/env.dart';
import 'package:jahan_football/data/models/match.dart';
import 'package:jahan_football/data/models/news.dart';
import 'package:jahan_football/data/sources/local_catalog.dart';

void main() {
  test('AppEnv production defaults are defined', () {
    expect(AppEnv.packageName, 'ir.jahanfootball.app');
    expect(AppEnv.versionName, '1.0.0');
    expect(AppEnv.apiBaseUrl.contains('http'), isTrue);
    expect(AppEnv.appName, 'جهان فوتبال');
  });

  test('NewsArticle parses WordPress-style payload', () {
    final NewsArticle article = NewsArticle.fromJson(<String, dynamic>{
      'id': 12,
      'title': <String, String>{'rendered': '<b>دربی تهران</b>'},
      'excerpt': <String, String>{'rendered': '<p>خلاصه خبر</p>'},
      'content': <String, String>{'rendered': '<p>متن کامل</p>'},
      'date': '2026-08-15T10:00:00',
      'jetpack_featured_media_url': 'https://example.com/a.jpg',
    });
    expect(article.id, '12');
    expect(article.title, 'دربی تهران');
    expect(article.excerpt, 'خلاصه خبر');
    expect(article.imageUrl, 'https://example.com/a.jpg');
  });

  test('FootballMatch parses TheSportsDB payload', () {
    final FootballMatch match = FootballMatch.fromJson(<String, dynamic>{
      'idEvent': '100',
      'strHomeTeam': 'Persepolis',
      'strAwayTeam': 'Esteghlal',
      'strLeague': 'Persian Gulf Pro League',
      'dateEvent': '2026-08-15',
      'strTime': '16:30:00',
      'intHomeScore': '1',
      'intAwayScore': '0',
      'strStatus': 'Match Finished',
    });
    expect(match.id, '100');
    expect(match.homeTeam, 'Persepolis');
    expect(match.isFinished, isTrue);
    expect(match.scoreLabel, '1 - 0');
  });

  test('Local catalog is complete enough for offline Home', () {
    expect(LocalCatalog.articles(), isNotEmpty);
    expect(LocalCatalog.matches(), isNotEmpty);
    expect(LocalCatalog.categories().length, greaterThan(3));
    expect(LocalCatalog.byId('1'), isNotNull);
    expect(LocalCatalog.search('دربی'), isNotEmpty);
    expect(LocalCatalog.home().featured, isNotEmpty);
  });
}

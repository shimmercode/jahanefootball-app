import 'match.dart';
import 'news.dart';
import 'category.dart';

class HomeFeed {
  const HomeFeed({
    required this.featured,
    required this.latest,
    required this.matches,
    required this.categories,
  });

  final List<NewsArticle> featured;
  final List<NewsArticle> latest;
  final List<FootballMatch> matches;
  final List<NewsCategory> categories;

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(dynamic raw, T Function(Map<String, dynamic>) map) {
      if (raw is! List) {
        return <T>[];
      }
      return raw
          .whereType<Map>()
          .map((Map item) => map(Map<String, dynamic>.from(item)))
          .toList();
    }

    return HomeFeed(
      featured: parseList(json['featured'], NewsArticle.fromJson),
      latest: parseList(json['latest'] ?? json['news'], NewsArticle.fromJson),
      matches: parseList(json['matches'], FootballMatch.fromJson),
      categories: parseList(json['categories'], NewsCategory.fromJson),
    );
  }
}

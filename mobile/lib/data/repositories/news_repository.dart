import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/category.dart';
import '../models/home_feed.dart';
import '../models/news.dart';
import '../sources/local_catalog.dart';

class NewsRepository {
  NewsRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<HomeFeed> fetchHome() async {
    try {
      final dynamic json = await _client.getJson(_client.join(AppEnv.apiBaseUrl, 'home.json'));
      if (json is Map<String, dynamic>) {
        final HomeFeed feed = HomeFeed.fromJson(json);
        if (feed.latest.isNotEmpty) {
          return feed;
        }
      }
    } on ApiException {
      // fall through to local catalog
    }

    if (AppEnv.hasWordPress) {
      try {
        final List<NewsArticle> posts = await fetchWordPressPosts();
        if (posts.isNotEmpty) {
          return HomeFeed(
            featured: posts.take(3).toList(),
            latest: posts,
            matches: LocalCatalog.matches(),
            categories: LocalCatalog.categories(),
          );
        }
      } on ApiException {
        // fall through
      }
    }

    return LocalCatalog.home();
  }

  Future<List<NewsArticle>> fetchNews({String categoryId = 'all'}) async {
    try {
      final String path = categoryId == 'all' ? 'news.json' : 'news.json?category=$categoryId';
      final dynamic json = await _client.getJson(_client.join(AppEnv.apiBaseUrl, path));
      final List<NewsArticle> items = _parseNewsList(json);
      if (items.isNotEmpty) {
        if (categoryId == 'all') {
          return items;
        }
        return items.where((NewsArticle n) => n.categoryId == categoryId).toList();
      }
    } on ApiException {
      // local fallback
    }

    if (AppEnv.hasWordPress) {
      try {
        final List<NewsArticle> posts = await fetchWordPressPosts();
        if (posts.isNotEmpty) {
          return posts;
        }
      } on ApiException {
        // local fallback
      }
    }

    if (categoryId == 'all') {
      return LocalCatalog.articles();
    }
    return LocalCatalog.articles()
        .where((NewsArticle item) => item.categoryId == categoryId)
        .toList();
  }

  Future<NewsArticle> fetchNewsById(String id) async {
    try {
      final dynamic json = await _client.getJson(_client.join(AppEnv.apiBaseUrl, 'news/$id.json'));
      if (json is Map<String, dynamic>) {
        return NewsArticle.fromJson(json);
      }
    } on ApiException {
      // continue
    }

    if (AppEnv.hasWordPress) {
      try {
        final dynamic json = await _client.getJson(
          _client.join(AppEnv.wordpressBaseUrl, 'wp-json/wp/v2/posts/$id?_embed=1'),
        );
        if (json is Map<String, dynamic>) {
          return NewsArticle.fromJson(_normalizeWp(json));
        }
      } on ApiException {
        // continue
      }
    }

    final NewsArticle? local = LocalCatalog.byId(id);
    if (local != null) {
      return local;
    }
    throw const ApiException('خبر پیدا نشد');
  }

  Future<List<NewsArticle>> search(String query) async {
    try {
      final String encoded = Uri.encodeQueryComponent(query);
      final dynamic json = await _client.getJson(
        _client.join(AppEnv.apiBaseUrl, 'search.json?q=$encoded'),
      );
      final List<NewsArticle> items = _parseNewsList(json);
      if (items.isNotEmpty) {
        return items;
      }
    } on ApiException {
      // local search
    }

    if (AppEnv.hasWordPress) {
      try {
        final String encoded = Uri.encodeQueryComponent(query);
        final dynamic json = await _client.getJson(
          _client.join(AppEnv.wordpressBaseUrl, 'wp-json/wp/v2/posts?search=$encoded&_embed=1'),
        );
        final List<NewsArticle> items = _parseNewsList(json, wordpress: true);
        if (items.isNotEmpty) {
          return items;
        }
      } on ApiException {
        // local search
      }
    }

    return LocalCatalog.search(query);
  }

  Future<List<NewsCategory>> fetchCategories() async {
    try {
      final dynamic json = await _client.getJson(_client.join(AppEnv.apiBaseUrl, 'categories.json'));
      if (json is List) {
        return json
            .whereType<Map>()
            .map((Map item) => NewsCategory.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      if (json is Map && json['items'] is List) {
        return (json['items'] as List<dynamic>)
            .whereType<Map>()
            .map((Map item) => NewsCategory.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } on ApiException {
      // local
    }
    return LocalCatalog.categories();
  }

  Future<List<NewsArticle>> fetchWordPressPosts() async {
    final dynamic json = await _client.getJson(
      _client.join(AppEnv.wordpressBaseUrl, 'wp-json/wp/v2/posts?per_page=20&_embed=1'),
    );
    return _parseNewsList(json, wordpress: true);
  }

  List<NewsArticle> _parseNewsList(dynamic json, {bool wordpress = false}) {
    List<dynamic> raw;
    if (json is List) {
      raw = json;
    } else if (json is Map && json['items'] is List) {
      raw = json['items'] as List<dynamic>;
    } else if (json is Map && json['news'] is List) {
      raw = json['news'] as List<dynamic>;
    } else {
      return <NewsArticle>[];
    }

    return raw.whereType<Map>().map((Map item) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(item);
      return NewsArticle.fromJson(wordpress ? _normalizeWp(map) : map);
    }).toList();
  }

  Map<String, dynamic> _normalizeWp(Map<String, dynamic> json) {
    String image = '';
    final dynamic embedded = json['_embedded'];
    if (embedded is Map && embedded['wp:featuredmedia'] is List) {
      final List<dynamic> media = embedded['wp:featuredmedia'] as List<dynamic>;
      if (media.isNotEmpty && media.first is Map) {
        image = (media.first['source_url'] ?? '').toString();
      }
    }
    return <String, dynamic>{
      ...json,
      'image': image,
    };
  }
}

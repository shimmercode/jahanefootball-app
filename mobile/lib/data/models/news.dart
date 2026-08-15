class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
    this.category = 'اخبار',
    this.categoryId = 'all',
    this.author = 'تحریریه جهان فوتبال',
    this.source = 'جهان فوتبال',
    this.featured = false,
    this.tags = const <String>[],
  });

  final String id;
  final String title;
  final String excerpt;
  final String content;
  final String imageUrl;
  final DateTime publishedAt;
  final String category;
  final String categoryId;
  final String author;
  final String source;
  final bool featured;
  final List<String> tags;

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final DateTime parsedDate = DateTime.tryParse(
          (json['published_at'] ?? json['date'] ?? json['modified'] ?? '').toString(),
        ) ??
        DateTime.now();

    String htmlOrText(dynamic value) {
      if (value is Map && value['rendered'] != null) {
        return _stripHtml(value['rendered'].toString());
      }
      return _stripHtml((value ?? '').toString());
    }

    return NewsArticle(
      id: '${json['id'] ?? ''}',
      title: htmlOrText(json['title']),
      excerpt: htmlOrText(json['excerpt'] ?? json['summary']),
      content: (json['content'] is Map)
          ? (json['content']['rendered'] ?? '').toString()
          : (json['content'] ?? json['body'] ?? '').toString(),
      imageUrl: (json['image'] ??
              json['image_url'] ??
              json['featured_image'] ??
              json['jetpack_featured_media_url'] ??
              '')
          .toString(),
      publishedAt: parsedDate,
      category: (json['category'] ?? json['category_name'] ?? 'اخبار').toString(),
      categoryId: '${json['category_id'] ?? json['categories'] ?? 'all'}',
      author: (json['author'] ?? 'تحریریه جهان فوتبال').toString(),
      source: (json['source'] ?? 'جهان فوتبال').toString(),
      featured: json['featured'] == true,
      tags: (json['tags'] is List)
          ? (json['tags'] as List<dynamic>).map((dynamic e) => e.toString()).toList()
          : const <String>[],
    );
  }

  static String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

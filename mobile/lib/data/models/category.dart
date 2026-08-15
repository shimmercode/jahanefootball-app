class NewsCategory {
  const NewsCategory({
    required this.id,
    required this.name,
    this.slug = '',
    this.icon = 'sports_soccer',
  });

  final String id;
  final String name;
  final String slug;
  final String icon;

  factory NewsCategory.fromJson(Map<String, dynamic> json) {
    return NewsCategory(
      id: '${json['id'] ?? ''}',
      name: (json['name'] ?? json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      icon: (json['icon'] ?? 'sports_soccer').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'slug': slug,
        'icon': icon,
      };
}

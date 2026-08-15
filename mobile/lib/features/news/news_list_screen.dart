import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/category.dart';
import '../../data/models/news.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/news_card.dart';
import '../home/home_screen.dart';

final newsListProvider = FutureProvider.family<List<NewsArticle>, String>((Ref ref, String categoryId) {
  return ref.read(newsRepositoryProvider).fetchNews(categoryId: categoryId);
});

final categoriesProvider = FutureProvider<List<NewsCategory>>((Ref ref) {
  return ref.read(newsRepositoryProvider).fetchCategories();
});

class NewsListScreen extends ConsumerWidget {
  const NewsListScreen({super.key, this.categoryId = 'all'});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<NewsArticle>> news = ref.watch(newsListProvider(categoryId));
    final AsyncValue<List<NewsCategory>> categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('اخبار')),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 52,
            child: categories.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (List<NewsCategory> items) {
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final NewsCategory category = items[index];
                    final bool selected = category.id == categoryId;
                    return ChoiceChip(
                      label: Text(category.name),
                      selected: selected,
                      onSelected: (_) => context.go('/app/news?category=${category.id}'),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: news.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (Object error, _) => EmptyState(
                message: 'بارگذاری اخبار ممکن نشد.\n$error',
                onRetry: () => ref.invalidate(newsListProvider(categoryId)),
              ),
              data: (List<NewsArticle> items) {
                if (items.isEmpty) {
                  return const EmptyState(message: 'خبری در این دسته نیست.');
                }
                return RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () async => ref.invalidate(newsListProvider(categoryId)),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final NewsArticle article = items[index];
                      return NewsCard(
                        article: article,
                        onTap: () => context.push('/news/${article.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

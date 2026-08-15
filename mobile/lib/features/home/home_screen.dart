import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/home_feed.dart';
import '../../data/models/match.dart';
import '../../data/models/news.dart';
import '../../data/repositories/news_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/match_tile.dart';
import '../../shared/widgets/network_image_view.dart';
import '../../shared/widgets/news_card.dart';

final newsRepositoryProvider = Provider<NewsRepository>((Ref ref) => NewsRepository());

final homeFeedProvider = FutureProvider<HomeFeed>((Ref ref) {
  return ref.read(newsRepositoryProvider).fetchHome();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomeFeed> asyncFeed = ref.watch(homeFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جهان فوتبال'),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: asyncFeed.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (Object error, _) => EmptyState(
          message: 'بارگذاری خانه با خطا مواجه شد.\n$error',
          onRetry: () => ref.invalidate(homeFeedProvider),
        ),
        data: (HomeFeed feed) {
          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: () async => ref.invalidate(homeFeedProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: <Widget>[
                if (feed.featured.isNotEmpty) _FeaturedPager(articles: feed.featured),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'نتایج زنده',
                  action: 'مرکز فوتبال',
                  onAction: () => context.go('/app/football'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 108,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: feed.matches.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final FootballMatch match = feed.matches[index];
                      return SizedBox(
                        width: 280,
                        child: MatchTile(
                          match: match,
                          onTap: () => context.push('/match/${match.id}'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: feed.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final category = feed.categories[index];
                      return ActionChip(
                        label: Text(category.name),
                        onPressed: () => context.go('/app/news?category=${category.id}'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                const _SectionHeader(title: 'تازه‌ترین اخبار'),
                const SizedBox(height: 10),
                ...feed.latest.map(
                  (NewsArticle article) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: NewsCard(
                      article: article,
                      onTap: () => context.push('/news/${article.id}'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!, style: const TextStyle(color: AppColors.gold)),
          ),
      ],
    );
  }
}

class _FeaturedPager extends StatelessWidget {
  const _FeaturedPager({required this.articles});

  final List<NewsArticle> articles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        itemCount: articles.length,
        itemBuilder: (BuildContext context, int index) {
          final NewsArticle article = articles[index];
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => context.push('/news/${article.id}'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    NetworkImageView(url: article.imageUrl),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Colors.transparent, Color(0xDD071912)],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      left: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              article.category,
                              style: const TextStyle(
                                color: AppColors.background,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.title,
                            maxLines: 2,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

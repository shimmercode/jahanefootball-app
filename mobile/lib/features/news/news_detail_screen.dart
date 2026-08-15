import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/news.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/network_image_view.dart';
import '../home/home_screen.dart';

final newsDetailProvider = FutureProvider.family<NewsArticle, String>((Ref ref, String id) {
  return ref.read(newsRepositoryProvider).fetchNewsById(id);
});

class NewsDetailScreen extends ConsumerWidget {
  const NewsDetailScreen({super.key, required this.newsId});

  final String newsId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<NewsArticle> asyncArticle = ref.watch(newsDetailProvider(newsId));

    return Scaffold(
      body: asyncArticle.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (Object error, _) => EmptyState(
          message: 'نمایش خبر ممکن نشد.\n$error',
          onRetry: () => ref.invalidate(newsDetailProvider(newsId)),
        ),
        data: (NewsArticle article) {
          final String plain = article.content
              .replaceAll(RegExp(r'<p>'), '\n')
              .replaceAll(RegExp(r'<br\s*/?>'), '\n')
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .replaceAll('&nbsp;', ' ')
              .trim();

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      Share.share('${article.title}\n\n${article.excerpt}\n\nجهان فوتبال');
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Hero(
                        tag: 'news-${article.id}',
                        child: NetworkImageView(url: article.imageUrl),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[Colors.transparent, AppColors.background],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        article.category,
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.45),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${article.author}  •  ${article.source}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        plain,
                        style: const TextStyle(height: 1.9, fontSize: 16, color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

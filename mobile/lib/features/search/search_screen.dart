import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/news.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/news_card.dart';
import '../home/home_screen.dart';

final searchQueryProvider = StateProvider<String>((Ref ref) => '');

final searchResultsProvider = FutureProvider<List<NewsArticle>>((Ref ref) async {
  final String query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) {
    return ref.read(newsRepositoryProvider).fetchNews();
  }
  return ref.read(newsRepositoryProvider).search(query.trim());
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<NewsArticle>> results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('جستجو')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'جستجوی خبر، تیم یا لیگ…',
                prefixIcon: Icon(Icons.search, color: AppColors.gold),
              ),
            ),
          ),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (Object error, _) => EmptyState(
                message: 'جستجو انجام نشد.\n$error',
                onRetry: () => ref.invalidate(searchResultsProvider),
              ),
              data: (List<NewsArticle> items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    message: 'نتیجه‌ای پیدا نشد. عبارت دیگری را امتحان کنید.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final NewsArticle article = items[index];
                    return NewsCard(
                      article: article,
                      onTap: () => context.push('/news/${article.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

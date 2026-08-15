import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/match.dart';
import '../../data/repositories/football_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/match_tile.dart';

final footballRepositoryProvider = Provider<FootballRepository>((Ref ref) {
  return FootballRepository();
});

final matchesProvider = FutureProvider<List<FootballMatch>>((Ref ref) {
  return ref.read(footballRepositoryProvider).fetchMatches();
});

class FootballCenterScreen extends ConsumerWidget {
  const FootballCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FootballMatch>> asyncMatches = ref.watch(matchesProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مرکز فوتبال'),
          bottom: const TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.goldLight,
            unselectedLabelColor: AppColors.textMuted,
            tabs: <Widget>[
              Tab(text: 'زنده'),
              Tab(text: 'برنامه'),
              Tab(text: 'تمام‌شده'),
            ],
          ),
        ),
        body: asyncMatches.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (Object error, _) => EmptyState(
            message: 'بارگذاری مسابقات ممکن نشد.\n$error',
            onRetry: () => ref.invalidate(matchesProvider),
          ),
          data: (List<FootballMatch> matches) {
            final List<FootballMatch> live = matches.where((FootballMatch m) => m.isLive).toList();
            final List<FootballMatch> upcoming =
                matches.where((FootballMatch m) => !m.isLive && !m.isFinished).toList();
            final List<FootballMatch> done = matches.where((FootballMatch m) => m.isFinished).toList();
            return TabBarView(
              children: <Widget>[
                _MatchList(matches: live, empty: 'مسابقه زنده‌ای در جریان نیست.'),
                _MatchList(matches: upcoming, empty: 'بازی برنامه‌ریزی‌شده‌ای نیست.'),
                _MatchList(matches: done, empty: 'نتیجه‌ای ثبت نشده است.'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList({required this.matches, required this.empty});

  final List<FootballMatch> matches;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return EmptyState(message: empty);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final FootballMatch match = matches[index];
        return MatchTile(
          match: match,
          onTap: () => context.push('/match/${match.id}'),
        );
      },
    );
  }
}

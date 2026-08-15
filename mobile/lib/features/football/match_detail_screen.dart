import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/match.dart';
import '../../shared/widgets/empty_state.dart';
import 'football_center_screen.dart';

final matchDetailProvider = FutureProvider.family<FootballMatch, String>((Ref ref, String id) {
  return ref.read(footballRepositoryProvider).fetchMatch(id);
});

class MatchDetailScreen extends ConsumerWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<FootballMatch> asyncMatch = ref.watch(matchDetailProvider(matchId));

    return Scaffold(
      appBar: AppBar(title: const Text('جزئیات بازی')),
      body: asyncMatch.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (Object error, _) => EmptyState(
          message: 'نمایش بازی ممکن نشد.\n$error',
          onRetry: () => ref.invalidate(matchDetailProvider(matchId)),
        ),
        data: (FootballMatch match) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: <Widget>[
              Text(
                match.league,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(child: _TeamName(name: match.homeTeam)),
                  Column(
                    children: <Widget>[
                      Text(
                        match.scoreLabel,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.goldLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        match.isLive
                            ? 'زنده ${match.minute ?? ''}'
                            : match.isFinished
                                ? 'پایان بازی'
                                : 'هنوز شروع نشده',
                        style: TextStyle(
                          color: match.isLive ? AppColors.live : AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: _TeamName(name: match.awayTeam)),
                ],
              ),
              const SizedBox(height: 28),
              _InfoRow(label: 'ورزشگاه', value: match.venue ?? 'نامشخص'),
              _InfoRow(label: 'وضعیت', value: match.status),
              _InfoRow(label: 'زمان', value: match.kickoff.toLocal().toString().substring(0, 16)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'رویدادهای زنده، ترکیب و آمار پیشرفته وقتی Football API اختصاصی فعال باشد در همین صفحه نمایش داده می‌شود. در حال حاضر داده‌های مسابقه از کاتالوگ جهان فوتبال و TheSportsDB خوانده می‌شود.',
                  style: TextStyle(height: 1.7, color: AppColors.textMuted),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TeamName extends StatelessWidget {
  const _TeamName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.surfaceAlt,
          child: Icon(Icons.shield_outlined, color: AppColors.gold),
        ),
        const SizedBox(height: 8),
        Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.textMuted))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/match.dart';

class MatchTile extends StatelessWidget {
  const MatchTile({super.key, required this.match, this.onTap});

  final FootballMatch match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    match.league,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ),
                _StatusChip(match: match),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    match.homeTeam,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  width: 72,
                  alignment: Alignment.center,
                  child: Text(
                    match.scoreLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.goldLight,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    match.awayTeam,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.match});

  final FootballMatch match;

  @override
  Widget build(BuildContext context) {
    final bool live = match.isLive;
    final String label = live
        ? 'زنده ${match.minute ?? ''}'
        : match.isFinished
            ? 'تمام‌شده'
            : 'برنامه';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: live ? AppColors.live.withValues(alpha: 0.18) : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: live ? AppColors.live : AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

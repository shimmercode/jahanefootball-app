import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/env.dart';
import '../../core/theme/app_colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بیشتر')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF124033), Color(0xFF0B3D2E)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'جهان فوتبال',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.goldLight),
                ),
                SizedBox(height: 6),
                Text(
                  'رسانه فوتبال ایران و جهان — اخبار، نتایج زنده و مرکز مسابقات.',
                  style: TextStyle(color: AppColors.textMuted, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: AppColors.gold),
            title: const Text('اعلان‌ها'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.gold),
            title: const Text('نسخه برنامه'),
            subtitle: Text('${AppEnv.versionName}  •  ${AppEnv.name}'),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_outlined, color: AppColors.gold),
            title: const Text('آدرس API'),
            subtitle: Text(AppEnv.apiBaseUrl, maxLines: 2),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'بسته: ir.jahanfootball.app\nحداقل اندروید: ۶.۰ (API 23)',
              style: TextStyle(color: AppColors.textMuted, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

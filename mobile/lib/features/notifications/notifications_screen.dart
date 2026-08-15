import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _enabled = true;
  bool _goals = true;
  bool _news = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool('notif_enabled') ?? true;
      _goals = prefs.getBool('notif_goals') ?? true;
      _news = prefs.getBool('notif_news') ?? true;
    });
  }

  Future<void> _save(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اعلان‌ها')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: <Widget>[
          SwitchListTile(
            value: _enabled,
            activeColor: AppColors.gold,
            title: const Text('اعلان‌های برنامه'),
            subtitle: const Text('گل، شروع بازی و خبر فوری'),
            onChanged: (bool value) {
              setState(() => _enabled = value);
              _save('notif_enabled', value);
            },
          ),
          SwitchListTile(
            value: _goals,
            activeColor: AppColors.gold,
            title: const Text('گل‌های زنده'),
            onChanged: _enabled
                ? (bool value) {
                    setState(() => _goals = value);
                    _save('notif_goals', value);
                  }
                : null,
          ),
          SwitchListTile(
            value: _news,
            activeColor: AppColors.gold,
            title: const Text('اخبار فوری'),
            onChanged: _enabled
                ? (bool value) {
                    setState(() => _news = value);
                    _save('notif_news', value);
                  }
                : null,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'پوش نوتیفیکیشن Firebase در این بیلد آماده اتصال است اما بدون google-services.json و کلید FCM فعال نمی‌شود. مرکز اعلان داخل برنامه کار می‌کند.',
              style: TextStyle(height: 1.7, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 18),
          const Text('آخرین اعلان‌ها', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const _NotifTile(
            title: 'گل پرسپولیس',
            body: 'دقیقه ۵۶ — نتیجه ۱-۱ شد.',
            time: 'همین حالا',
          ),
          const _NotifTile(
            title: 'خبر فوری',
            body: 'فهرست اولیه تیم ملی اعلام شد.',
            time: '۲ ساعت پیش',
          ),
          const _NotifTile(
            title: 'یادآوری بازی',
            body: 'سپاهان و تراکتور حدود ۵ ساعت دیگر.',
            time: 'امروز',
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.title, required this.body, required this.time});

  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            backgroundColor: AppColors.surfaceAlt,
            child: Icon(Icons.notifications, color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

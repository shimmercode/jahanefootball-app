import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jahan_football/app.dart';
import 'package:jahan_football/data/sources/local_catalog.dart';
import 'package:jahan_football/features/home/home_screen.dart';
import 'package:jahan_football/features/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('splash shows Persian brand', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: JahanFootballApp()));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('جهان فوتبال'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('home screen renders news and matches from local catalog', (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/app/home',
      routes: <RouteBase>[
        GoRoute(
          path: '/app/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/news/:id',
          builder: (_, __) => const Scaffold(body: Text('خبر')),
        ),
        GoRoute(
          path: '/match/:id',
          builder: (_, __) => const Scaffold(body: Text('بازی')),
        ),
        GoRoute(
          path: '/notifications',
          builder: (_, __) => const Scaffold(body: Text('اعلان')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          homeFeedProvider.overrideWith((Ref ref) async => LocalCatalog.home()),
        ],
        child: MaterialApp.router(
          locale: const Locale('fa', 'IR'),
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('جهان فوتبال'), findsWidgets);
    expect(find.text('تازه‌ترین اخبار'), findsOneWidget);
    expect(find.textContaining('دربی'), findsWidgets);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/theme/app_theme.dart';
import 'features/football/football_center_screen.dart';
import 'features/football/match_detail_screen.dart';
import 'features/home/home_screen.dart';
import 'features/more/more_screen.dart';
import 'features/news/news_detail_screen.dart';
import 'features/news/news_list_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/search/search_screen.dart';
import 'features/shell/main_shell.dart';
import 'features/splash/splash_screen.dart';

GoRouter createRouter() {
  timeago.setLocaleMessages('fa', timeago.FaMessages());

  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell shell) {
          return MainShell(navigationShell: shell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/app/home',
                builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/app/football',
                builder: (BuildContext context, GoRouterState state) => const FootballCenterScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/app/search',
                builder: (BuildContext context, GoRouterState state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/app/news',
                builder: (BuildContext context, GoRouterState state) {
                  final String category = state.uri.queryParameters['category'] ?? 'all';
                  return NewsListScreen(categoryId: category);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/app/more',
                builder: (BuildContext context, GoRouterState state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/news/:id',
        builder: (BuildContext context, GoRouterState state) {
          return NewsDetailScreen(newsId: state.pathParameters['id'] ?? '');
        },
      ),
      GoRoute(
        path: '/match/:id',
        builder: (BuildContext context, GoRouterState state) {
          return MatchDetailScreen(matchId: state.pathParameters['id'] ?? '');
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) => const NotificationsScreen(),
      ),
    ],
  );
}

class JahanFootballApp extends StatelessWidget {
  JahanFootballApp({super.key, GoRouter? router}) : _router = router ?? createRouter();

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'جهان فوتبال',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      locale: const Locale('fa', 'IR'),
      supportedLocales: const <Locale>[
        Locale('fa', 'IR'),
        Locale('en'),
      ],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: _router,
    );
  }
}

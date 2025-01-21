import 'package:app/main_scaffold.dart';
import 'package:app/pages/friends.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/list_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/list_page',
          pageBuilder: (context, state) => const NoTransitionPage(child: ListPage()),
        ),
        GoRoute(
          path: '/friends',
          pageBuilder: (context, state) => const NoTransitionPage(child: FriendsPage()),
        ),
      ],
    ),
  ],
);

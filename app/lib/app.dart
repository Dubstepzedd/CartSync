import 'package:app/auth/login_page.dart';
import 'package:app/auth/register_page.dart';
import 'package:app/main_scaffold.dart';
import 'package:app/pages/friends.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/list_page.dart';
import 'package:app/pages/providers/cart_state.dart';
import 'package:app/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartState(),
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => const NoTransitionPage(child: RegisterPage()),
    ),
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
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
        )
      ],
    ),
  ],
);


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

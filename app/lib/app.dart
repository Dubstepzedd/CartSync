import 'package:app/auth/login_page.dart';
import 'package:app/auth/register_page.dart';
import 'package:app/main_scaffold.dart';
import 'package:app/models/cart.dart';
import 'package:app/pages/follow_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/list_page.dart';
import 'package:app/pages/providers/app_state.dart';
import 'package:app/pages/sub_pages/add_item_page.dart';
import 'package:app/pages/sub_pages/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
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
    GoRoute(
      path: '/cart',
      pageBuilder: (context, state)  {
        final cart = state.extra as Cart;
        return NoTransitionPage(
          child: CartPage(cart: cart)
        );
      }
    ),
    GoRoute(
      path: '/add_item',
      pageBuilder: (context, state)  {
        final cart = state.extra as Cart;
        return NoTransitionPage(
          child: AddItemPage(cart: cart)
        );
      }
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
          path: '/follow',
          pageBuilder: (context, state) => const NoTransitionPage(child: FollowPage()),
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

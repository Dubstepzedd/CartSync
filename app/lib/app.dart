import 'package:app/pages/auth/login_page.dart';
import 'package:app/pages/auth/register_page.dart';
import 'package:app/main_scaffold.dart';
import 'package:app/pages/friend_page.dart';
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

final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: RegisterPage()),
    ),
    GoRoute(
        path: '/cart',
        pageBuilder: (context, state) {
          final id = state.extra as int;
          return NoTransitionPage(child: CartPage(id: id));
        }),
    GoRoute(
        path: '/add_item',
        pageBuilder: (context, state) {
          final id = state.extra as int;
          return NoTransitionPage(child: AddItemPage(id: id));
        }),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/list_page',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ListPage()),
        ),
        GoRoute(
          path: '/follow',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: FollowPage()),
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
      theme: ThemeData(
        colorSchemeSeed: Colors.blueAccent,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.blueAccent),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            elevation: WidgetStatePropertyAll(0),
            minimumSize: WidgetStatePropertyAll(Size(double.infinity, 52)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            )),
            textStyle: WidgetStatePropertyAll(
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }
}

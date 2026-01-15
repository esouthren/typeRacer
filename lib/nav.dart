import 'package:typeracer/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.game,
    routes: [
      GoRoute(
        path: AppRoutes.game,
        name: 'game',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: GameScreen(),
        ),
      ),
    ],
  );
}

class AppRoutes {
  static const String game = '/';
}

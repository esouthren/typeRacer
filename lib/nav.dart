import 'package:typeracer/screens/game_screen.dart';
import 'package:typeracer/screens/landing_screen.dart';
import 'package:typeracer/screens/login_screen.dart';
import 'package:typeracer/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.landing,
    refreshListenable: AuthService(),
    redirect: (context, state) {
      final isLoggedIn = AuthService().currentUser != null;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn) {
        return isLoggingIn ? null : AppRoutes.login;
      }

      if (isLoggingIn) {
        return AppRoutes.landing;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.landing,
        name: 'landing',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LandingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
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
  static const String landing = '/';
  static const String login = '/login';
  static const String game = '/game';
}

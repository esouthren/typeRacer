import 'package:typeracer/screens/countdown_screen.dart';
import 'package:typeracer/screens/game_screen.dart';
import 'package:typeracer/screens/landing_screen.dart';
import 'package:typeracer/screens/lobby_screen.dart';
import 'package:typeracer/screens/login_screen.dart';
import 'package:typeracer/screens/testing_screen.dart';
import 'package:typeracer/services/auth_service.dart';
import 'package:typeracer/widgets/checkered_background.dart';
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
      ShellRoute(
        builder: (context, state, child) {
          return CheckeredBackground(child: child);
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
            pageBuilder: (context, state) {
              final gameId = state.extra as String?;
              if (gameId == null) {
                // Handle error or redirect
                return const NoTransitionPage(child: LandingScreen());
              }
              return NoTransitionPage(
                child: GameScreen(gameId: gameId),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.lobby,
            name: 'lobby',
            pageBuilder: (context, state) {
               final gameId = state.extra as String?;
               if (gameId == null) return const NoTransitionPage(child: LandingScreen());
               return NoTransitionPage(child: LobbyScreen(gameId: gameId));
            },
          ),
          GoRoute(
            path: AppRoutes.countdown,
            name: 'countdown',
            pageBuilder: (context, state) {
               final gameId = state.extra as String?;
               if (gameId == null) return const NoTransitionPage(child: LandingScreen());
               return NoTransitionPage(child: CountdownScreen(gameId: gameId));
            },
          ),
          GoRoute(
            path: AppRoutes.testing,
            name: 'testing',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TestingScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String game = '/game';
  static const String lobby = '/lobby';
  static const String countdown = '/countdown';
  static const String testing = '/testing';
}

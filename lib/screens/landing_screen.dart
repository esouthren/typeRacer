import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:typeracer/nav.dart';
import 'package:typeracer/services/auth_service.dart';
import 'package:typeracer/widgets/button.dart';

/// Landing page for TypeRacer game
/// Shows the game title and three action buttons: Solo Mode, Join Game, Start Game
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Logout Button
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
                tooltip: 'Logout',
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Game Title with racing theme
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
               
                        Text(
                          'TypeRacer',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: -1.0,
                                  fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Type. Race. Win!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Action Buttons
                Column(
                  children: [
                    Button(
                      label: 'Solo Mode',
                      icon: Icons.person,
                      onPressed: () => context.push('/game'),
                    ),
                    const SizedBox(height: 16),
                    Button(
                      label: 'Join Game',
                      icon: Icons.group_add,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Join Game - Coming Soon!')),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Button(
                      label: 'Start Game',
                      icon: Icons.play_arrow,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Start Multiplayer Game - Coming Soon!')),
                        );
                      },
                    ),
                  ],
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
}



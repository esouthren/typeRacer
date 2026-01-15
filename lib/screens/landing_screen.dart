import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:typeracer/nav.dart';

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
                onPressed: () => context.go(AppRoutes.login),
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
                      'Race to type faster!',
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
                    _ActionButton(
                      label: 'Solo Mode',
                      icon: Icons.person,
                      onPressed: () => context.push('/game'),
                      isPrimary: true,
                    ),
                    const SizedBox(height: 16),
                    _ActionButton(
                      label: 'Join Game',
                      icon: Icons.group_add,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Join Game - Coming Soon!')),
                        );
                      },
                      isPrimary: false,
                    ),
                    const SizedBox(height: 16),
                    _ActionButton(
                      label: 'Start Game',
                      icon: Icons.play_arrow,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Start Multiplayer Game - Coming Soon!')),
                        );
                      },
                      isPrimary: false,
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

/// Custom action button component for landing page
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: isPrimary
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
    );
  }
}

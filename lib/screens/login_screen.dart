import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:typeracer/nav.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Game Title with racing theme (Reused from LandingScreen)
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
                      'Login to start racing!',
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

                // Login Button
                _ActionButton(
                  label: 'Log in with Google',
                  icon: Icons.login, // Placeholder for Google icon
                  onPressed: () {
                    // Navigate to landing page for demo purposes since logic is not connected
                    context.go(AppRoutes.landing);
                  },
                  isPrimary: true,
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom action button component (Duplicated from LandingScreen for independence)
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

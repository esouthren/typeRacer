import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:typeracer/nav.dart';
import 'package:typeracer/services/auth_service.dart';
import 'package:typeracer/widgets/button.dart';


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

                // Login Button
                Button(
                  label: 'Log in with Google',
                  icon: Icons.login, // Placeholder for Google icon
                  onPressed: () async {
                    try {
                      final user = await AuthService().signInWithGoogle();
                      if (user != null && context.mounted) {
                        context.go(AppRoutes.landing);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: $e')),
                        );
                      }
                    }
                  },
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


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
                    Image.asset('assets/images/header-Photoroom.png',
                        height: 200),
                    const SizedBox(height: 12),
                  ],
                ),

                const Spacer(flex: 2),

                // Login Button
                Button(
                  label: 'Log in with Google',
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
                  width: 350,
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

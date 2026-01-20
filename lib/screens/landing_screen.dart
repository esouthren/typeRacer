import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:typeracer/nav.dart';
import 'package:typeracer/screens/create_game_dialog.dart';
import 'package:typeracer/services/auth_service.dart';
import 'package:typeracer/services/game_service.dart';
import 'package:typeracer/widgets/button.dart';
import 'package:typeracer/widgets/car_selection_widget.dart';

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
                        Image.asset(
                          'assets/images/header-Photoroom.png',
                          height: 200,
                        ),
                        
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Action Buttons
                    Column(
                      children: [
                        Button(
                          label: 'Solo Mode',
                          onPressed: () => context.push(AppRoutes.game, extra: 'solo'),
                        ),
                        const SizedBox(height: 16),
                        Button(
                          label: 'Join Game',
                          onPressed: () => _showJoinGameDialog(context),
                          buttonColor: ButtonColor.secondary,
                        ),
                        const SizedBox(height: 16),
                        Button(
                          label: 'Create Game',
                                                    buttonColor: ButtonColor.onSecondary,

                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => const CreateGameDialog(),
                          ),
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

  void _showJoinGameDialog(BuildContext context) {
    final TextEditingController pinController = TextEditingController();
    bool isLoading = false;
    int selectedCarIndex = 0;
    String displayName = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: 700, // Wider for car selection
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Join Game',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      onChanged: (value) => setState(() {}),
                      style: const TextStyle(fontSize: 24, letterSpacing: 4),
                      decoration: const InputDecoration(
                        labelText: 'Game PIN',
                        hintText: '12345',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    CarSelectionWidget(
                      crossAxisCount: 6,
                      onCarSelected: (index) => selectedCarIndex = index,
                      onNameChanged: (name) {
                        displayName = name;
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 24),
                    isLoading
                        ? const CircularProgressIndicator()
                        : Button(
                            disabled: (pinController.text.length < 5 || displayName.trim().isEmpty),
                            label: 'Join Game',
                            onPressed: () async {
                              setState(() => isLoading = true);
                              try {
                                final gameId = await GameService().joinGame(
                                  pinController.text,
                                  displayName,
                                  selectedCarIndex,
                                );
                                if (context.mounted) {
                                  context.pop();
                                  context.push(AppRoutes.lobby, extra: gameId);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              } finally {
                                if (context.mounted) setState(() => isLoading = false);
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

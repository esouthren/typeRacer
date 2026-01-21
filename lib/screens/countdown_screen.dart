import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:typeracer/models/game_model.dart';
import 'package:typeracer/nav.dart';
import 'package:typeracer/services/game_service.dart';
import 'package:typeracer/widgets/countdown_overlay.dart';

class CountdownScreen extends StatelessWidget {
  final String gameId;

  const CountdownScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Ensure background is black
      body: StreamBuilder<GameModel?>(
        stream: GameService().streamGame(gameId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final game = snapshot.data!;
          final currentRound = game.rounds[game.currentRoundIndex];
          final startTime = currentRound.startTime;

          // If no start time or already started, go to game
          if (startTime == null || DateTime.now().isAfter(startTime)) {
            // Use post frame callback to avoid build conflicts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go(AppRoutes.game, extra: gameId);
              }
            });
            return const SizedBox.shrink();
          }

          return CountdownOverlay(
            startTime: startTime,
            onFinished: () {
               context.go(AppRoutes.game, extra: gameId);
            },
          );
        },
      ),
    );
  }
}

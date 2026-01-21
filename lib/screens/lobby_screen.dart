import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:typeracer/models/game_model.dart';
import 'package:typeracer/nav.dart';
import 'package:typeracer/services/auth_service.dart';
import 'package:typeracer/services/game_service.dart';
import 'package:typeracer/widgets/button.dart';

class LobbyScreen extends StatelessWidget {
  final String gameId;

  const LobbyScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final isHost = currentUser != null; // We'll verify against hostId in stream

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.landing),
        ),
      ),
      body: StreamBuilder<GameModel?>(
        stream: GameService().streamGame(gameId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final game = snapshot.data!;
          final isHostUser = game.hostId == currentUser?.uid;

          // Auto-navigate if game starts
          if (game.status == GameStatus.in_progress ||
              game.status == GameStatus.counting_down) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              
              final currentRound = game.rounds.isNotEmpty ? game.rounds[game.currentRoundIndex] : null;
              final startTime = currentRound?.startTime;
              
              // If round hasn't started yet, go to countdown
              if (startTime != null && DateTime.now().isBefore(startTime)) {
                 context.go(AppRoutes.countdown, extra: gameId);
              } else {
                 context.go(AppRoutes.game, extra: gameId);
              }
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PIN Code Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Game PIN',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: game.pin));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PIN copied!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            game.pin,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  letterSpacing: 8.0,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to copy',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Players List
                Text(
                  'Players (${game.players.length})',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: game.players.length,
                    itemBuilder: (context, index) {
                      final player = game.players[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: player.photoUrl != null
                                ? NetworkImage(player.photoUrl!)
                                : null,
                            child: player.photoUrl == null
                                ? Text(player.displayName[0].toUpperCase())
                                : null,
                          ),
                          title: Text(player.displayName),
                          trailing: player.id == game.hostId
                              ? Chip(
                                  label: Text('Host',
                                      style: TextStyle(fontSize: 10, color: Colors.white)),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Start Button (Host only)
                if (isHostUser)
                  Button(
                    
                    label: 'Start Game',
                    onPressed: () async {
                      try {
                        await GameService().startGame(game.id);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                  )
                else
                  const Center(
                    child: Text(
                      'Waiting for host to start...',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

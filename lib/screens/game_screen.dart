import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:typeracer/constants/car_assets.dart';
import 'package:typeracer/models/game_model.dart';
import 'package:typeracer/nav.dart';
import 'package:typeracer/services/auth_service.dart';
import 'package:typeracer/services/game_service.dart';
import 'package:typeracer/widgets/button.dart';
import 'package:typeracer/widgets/visual_keyboard.dart';
import 'package:typeracer/widgets/countdown_overlay.dart';

class GameScreen extends StatefulWidget {
  final String? gameId;

  const GameScreen({super.key, this.gameId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Solo mode state
  bool get _isSolo => widget.gameId == 'solo' || widget.gameId == null;

  @override
  Widget build(BuildContext context) {
    if (_isSolo) {
      return const SoloGameView();
    }

    return StreamBuilder<GameModel?>(
      stream: GameService().streamGame(widget.gameId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final game = snapshot.data!;

        if (game.status == GameStatus.finished) {
          return GameSummaryView(game: game);
        }

        if (game.status == GameStatus.lobby) {
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return MultiplayerGameView(game: game);
      },
    );
  }
}

class SoloGameView extends StatefulWidget {
  const SoloGameView({super.key});

  @override
  State<SoloGameView> createState() => _SoloGameViewState();
}

class _SoloGameViewState extends State<SoloGameView> {
  final FocusNode _focusNode = FocusNode();
  final String _targetText = 'The quick brown fox jumps over the lazy dog. '
      'Pack my box with five dozen liquor jugs.';
  int _currentIndex = 0;
  String? _currentPressedKey;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (_currentIndex >= _targetText.length) return;

    // Start timer on first key press
    if (_startTime == null && _currentIndex == 0) {
      _startTime = DateTime.now();
    }

    final char = event.character;
    if (char == null) return;

    setState(() => _currentPressedKey = char);

    if (char == _targetText[_currentIndex]) {
      setState(() => _currentIndex++);
      if (_currentIndex >= _targetText.length) {
        _finishGame();
      }
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _currentPressedKey = null);
    });
  }

  void _finishGame() {
    final endTime = DateTime.now();
    final durationInMinutes =
        endTime.difference(_startTime ?? endTime).inMilliseconds / 60000.0;
    
    // Avoid division by zero if duration is too small (e.g. testing)
    final safeDuration = durationInMinutes > 0 ? durationInMinutes : 0.01;
    
    final wpm = ((_targetText.length / 5) / safeDuration).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Race Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$wpm WPM',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text('Great typing!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              // Reset game
              setState(() {
                _currentIndex = 0;
                _startTime = null;
              });
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.go(AppRoutes.landing);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RaceInterface(
      targetText: _targetText,
      currentIndex: _currentIndex,
      currentPressedKey: _currentPressedKey,
      focusNode: _focusNode,
      onKeyEvent: _handleKeyPress,
      title: 'Solo Run',
    );
  }
}

class MultiplayerGameView extends StatefulWidget {
  final GameModel game;

  const MultiplayerGameView({super.key, required this.game});

  @override
  State<MultiplayerGameView> createState() => _MultiplayerGameViewState();
}

class _MultiplayerGameViewState extends State<MultiplayerGameView> {
  final FocusNode _focusNode = FocusNode();
  String? _currentPressedKey;
  int _localCurrentIndex = 0;
  bool _isRoundFinished = false;
  
  // Track previous round index to detect changes
  int _lastKnownRoundIndex = -1;

  GameRound get _currentRound => widget.game.rounds[widget.game.currentRoundIndex];
  bool get _isWaitingForStart {
    final startTime = _currentRound.startTime;
    return startTime != null && DateTime.now().isBefore(startTime);
  }

  @override
  void initState() {
    super.initState();
    _lastKnownRoundIndex = widget.game.currentRoundIndex;
    _checkRoundReset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(MultiplayerGameView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.game.currentRoundIndex != _lastKnownRoundIndex) {
      _lastKnownRoundIndex = widget.game.currentRoundIndex;
      _resetForNewRound();
    }
  }
  
  void _checkRoundReset() {
      // Check if current user is already marked finished in this round (e.g. rejoining)
    final userId = AuthService().currentUser?.uid;
    if (userId != null && _currentRound.finishedPlayerIds.contains(userId)) {
      _isRoundFinished = true;
      _localCurrentIndex = _currentRound.text.length;
    }
  }

  void _resetForNewRound() {
    setState(() {
      _localCurrentIndex = 0;
      _isRoundFinished = false;
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleKeyPress(KeyEvent event) async {
    if (event is! KeyDownEvent) return;
    if (_isRoundFinished || _isWaitingForStart) return;
    
    final text = _currentRound.text;
    if (_localCurrentIndex >= text.length) return;

    final char = event.character;
    if (char == null) return;

    setState(() => _currentPressedKey = char);

    if (char == text[_localCurrentIndex]) {
      setState(() => _localCurrentIndex++);
      
      if (_localCurrentIndex >= text.length) {
        setState(() => _isRoundFinished = true);
        
        // Calculate WPM
        final startTime = _currentRound.startTime ?? DateTime.now();
        final endTime = DateTime.now();
        final durationInMinutes = endTime.difference(startTime).inMilliseconds / 60000.0;
        final safeDuration = durationInMinutes > 0 ? durationInMinutes : 0.01;
        final wpm = ((text.length / 5) / safeDuration).round();
        
        await GameService().submitRoundResult(
          widget.game.id, 
          widget.game.currentRoundIndex,
          wpm,
        );
      }
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _currentPressedKey = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isWaitingForStart) {
      return CountdownOverlay(
        startTime: _currentRound.startTime!,
        onFinished: () {
          setState(() {});
        },
      );
    }

    return Stack(
      children: [
        RaceInterface(
          targetText: _currentRound.text,
          currentIndex: _localCurrentIndex,
          currentPressedKey: _currentPressedKey,
          focusNode: _focusNode,
          onKeyEvent: _handleKeyPress,
          title: 'Round ${widget.game.currentRoundIndex + 1}/${widget.game.rounds.length}: ${_currentRound.category}',
          players: widget.game.players, // Pass players for visualization
          scores: widget.game.scores,
        ),
          
        // Waiting for others Overlay
        if (_isRoundFinished && widget.game.status != GameStatus.finished)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Round Complete!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Waiting for other players...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class GameSummaryView extends StatelessWidget {
  final GameModel game;

  const GameSummaryView({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Sort players by score
    final sortedIds = game.scores.keys.toList()
      ..sort((a, b) => (game.scores[b] ?? 0).compareTo(game.scores[a] ?? 0));

    return Scaffold(
      appBar: AppBar(title: const Text('Game Over')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Final Standings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: sortedIds.length,
                itemBuilder: (context, index) {
                  final userId = sortedIds[index];
                  final player = game.players.firstWhere(
                    (p) => p.id == userId, 
                    orElse: () => GamePlayer(id: userId, displayName: 'Unknown')
                  );
                  final score = game.scores[userId] ?? 0;
                  
                  return Card(
                    color: index == 0 ? Colors.amber[100] : null, // Gold for winner
                    child: ListTile(
                      leading: Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      title: Text(player.displayName),
                      trailing: Text('$score pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  );
                },
              ),
            ),
            Button(
              label: 'Back to Lobby',
              onPressed: () => context.go(AppRoutes.landing),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Interface
class RaceInterface extends StatelessWidget {
  final String targetText;
  final int currentIndex;
  final String? currentPressedKey;
  final FocusNode focusNode;
  final Function(KeyEvent) onKeyEvent;
  final String title;
  final List<GamePlayer>? players;
  final Map<String, int>? scores;

  const RaceInterface({
    super.key,
    required this.targetText,
    required this.currentIndex,
    required this.currentPressedKey,
    required this.focusNode,
    required this.onKeyEvent,
    required this.title,
    this.players,
    this.scores,
  });

  @override
  Widget build(BuildContext context) {
    final baseFontSize = 24.0;
    
    // Default solo player if none provided
    final activePlayers = players ?? [
      GamePlayer(id: 'me', displayName: 'You', isReady: true, selectedCarIndex: 0)
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: KeyboardListener(
        focusNode: focusNode,
        onKeyEvent: onKeyEvent,
        child: GestureDetector(
          onTap: () => focusNode.requestFocus(),
          child: Column(
            children: [
              // Top quarter: Multi-Track Race View
              Container(
                height: MediaQuery.of(context).size.height / 3, // Fixed height: 1/3 screen
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                // Dark grey background for the container to match road
                // The road itself is drawn inside MultiTrackView
                color: Colors.transparent, // Let MultiTrackView handle background
                child: MultiTrackView(
                  players: activePlayers,
                  targetTextLength: targetText.length,
                  localCurrentIndex: currentIndex,
                ),
              ),

              const Divider(height: 1),

              // Second quarter: Text to type
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 24, color: Colors.black, height: 1.8),
                      children: [
                        // Typed text (green)
                        TextSpan(
                          text: targetText.substring(0, currentIndex),
                          style: TextStyle(
                              color: Colors.green, // Changed to green for visibility
                              fontWeight: FontWeight.w500,
                              fontSize: baseFontSize,
                              height: 1.8),
                        ),
                        // Current character (highlighted)
                        if (currentIndex < targetText.length)
                          TextSpan(
                            text: targetText[currentIndex],
                            style: TextStyle(
                              color: Colors.blue,
                              backgroundColor: Colors.blue.withValues(alpha: 0.1),
                              fontWeight: FontWeight.bold,
                              decoration: targetText[currentIndex] == ' ' ? TextDecoration.underline : null,
                              decorationThickness: 2.0,
                              fontSize: baseFontSize + 2,
                              height: 1.8,
                            ),
                          ),
                        // Remaining text (gray)
                        if (currentIndex < targetText.length - 1)
                          TextSpan(
                            text: targetText.substring(currentIndex + 1),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: baseFontSize,
                                height: 1.8),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // Bottom half: Visual keyboard
              Expanded(
                child: VisualKeyboard(pressedKey: currentPressedKey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MultiTrackView extends StatelessWidget {
  final List<GamePlayer> players;
  final int targetTextLength;
  final int localCurrentIndex;

  const MultiTrackView({
    super.key,
    required this.players,
    required this.targetTextLength,
    required this.localCurrentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        final totalWidth = constraints.maxWidth;
        final finishLineWidth = 20.0;
        final startLineWidth = 20.0;
        final carWidth = 60.0;
        
        // Calculate max tracks we can fit comfortably
        final minTrackHeight = 60.0;
        final maxPossibleTracks = (totalHeight / minTrackHeight).floor();
        
        // Determine how many visual tracks we'll have
        final numVisualTracks = players.length <= maxPossibleTracks 
            ? players.length 
            : maxPossibleTracks;
            
        // Ensure at least 1 track
        final actualNumTracks = numVisualTracks > 0 ? numVisualTracks : 1;
        
        // Actual height per track
        final trackHeight = totalHeight / actualNumTracks;
        
        // Use a single skew transform for the whole road
        // -0.4 radians gives a nice / slant
        final skewAngle = -0.4; 
        
        // We need to inset the road content horizontally so the skew doesn't clip
        // When skewed by a, the top moves by H * tan(a/2)? No.
        // x' = x + y*tan(a)
        // At y=H (bottom), the x shift is H * tan(a)
        // With a = -0.4, shift is negative (to left)
        // So bottom is left of top.
        // We need to ensure we have padding on left and right.
        
        final double horizontalPadding = 40.0;
        final double roadWidth = totalWidth - (horizontalPadding * 2);

        return Center(
          child: Container(
            width: roadWidth,
            height: totalHeight,
            // Wrap the whole road in a skew transform
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewX(skewAngle),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  border: Border.symmetric(
                    vertical: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    )
                  ]
                ),
                child: Stack(
                  children: [
                    // Start Line (Checkered)
                     Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: startLineWidth,
                      child: CustomPaint(painter: CheckeredFinishLinePainter()),
                    ),
                    
                    // Finish Line (Checkered)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: finishLineWidth,
                      child: CustomPaint(painter: CheckeredFinishLinePainter()),
                    ),

                    // Draw dividers
                    for (int i = 1; i < actualNumTracks; i++)
                      Positioned(
                        top: i * trackHeight,
                        left: 0,
                        right: 0,
                        height: 2,
                        child: Container(color: Colors.white.withValues(alpha: 0.3)),
                      ),

                    // Draw cars
                    ...players.asMap().entries.map((entry) {
                      final index = entry.key;
                      final player = entry.value;
                      
                      final trackIndex = index % actualNumTracks;
                      
                      // Calculate progress
                      double progress = player.currentProgress;
                      final isLocal = player.id == AuthService().currentUser?.uid || player.id == 'me';
                      if (isLocal && targetTextLength > 0) {
                        progress = localCurrentIndex / targetTextLength;
                      }
                      
                      // Car positioning inside the skewed container
                      // X is 0 to roadWidth
                      // But we have start and finish lines
                      final trackRun = roadWidth - startLineWidth - finishLineWidth - carWidth;
                      final carX = startLineWidth + (progress * trackRun);
                      
                      // Vertical offset if sharing track
                      double verticalOffset = 0;
                      if (players.length > actualNumTracks) {
                         final shareIndex = index ~/ actualNumTracks;
                         verticalOffset = shareIndex * 10.0; 
                      }

                      final topY = (trackIndex * trackHeight) + (trackHeight / 2) - 15 + verticalOffset;

                      return Positioned(
                        left: carX,
                        top: topY,
                        child: Transform(
                          // Counter-skew the car so it looks upright!
                          transform: Matrix4.skewX(-skewAngle),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                player.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                                ),
                              ),
                              Image.asset(
                                CarAssets.cars[player.selectedCarIndex % CarAssets.cars.length],
                                width: carWidth,
                                height: 30,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for vertical checkered finish line
class CheckeredFinishLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = 7.0;
    final paint = Paint();

    // Calculate how many rows we need to fill the height
    final rows = (size.height / squareSize).ceil();
    final cols = 3; // 3 checkers per row = 21 pixels wide

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        // Alternate colors in checkerboard pattern
        final isBlack = (row + col) % 2 == 0;
        paint.color = isBlack ? Colors.black : Colors.white;

        canvas.drawRect(
          Rect.fromLTWH(
            col * squareSize,
            row * squareSize,
            squareSize,
            squareSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

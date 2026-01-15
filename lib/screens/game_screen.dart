import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:typeracer/widgets/visual_keyboard.dart';

/// Main game screen for TypeRacer
///
/// Split into quarters:
/// - Top quarter: Racecar progress indicator
/// - Second quarter: Text to type with color-coded progress
/// - Bottom half: Visual keyboard showing key presses
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();

  // Text to type (lorem ipsum placeholder)
  final String _targetText = 'The quick brown fox jumps over the lazy dog. '
      'Pack my box with five dozen liquor jugs.';

  // Current position in text
  int _currentIndex = 0;

  // Currently pressed key for visual feedback
  String? _currentPressedKey;

  @override
  void initState() {
    super.initState();
    // Request focus when screen loads
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

    final char = event.character;
    if (char == null) return;

    setState(() {
      _currentPressedKey = char;
    });

    // Check if typed character matches expected character
    final expectedChar = _targetText[_currentIndex];
    if (char == expectedChar) {
      setState(() {
        _currentIndex++;
      });

      // Check if completed
      if (_currentIndex >= _targetText.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Complete!'), duration: Duration(seconds: 2)),
        );
      }
    }
    // If incorrect, do nothing (halts progression)

    // Clear pressed key after short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _currentPressedKey = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseFontSize = 24.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TypeRacer'),
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyPress,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Column(
            children: [
              // Top quarter: Racecar progress indicator
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  color: Theme.of(context).colorScheme.onSurface,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate progress (0.0 to 1.0)
                      final progress = _targetText.isEmpty
                          ? 0.0
                          : _currentIndex / _targetText.length;
                      // Calculate car position so right edge touches finish line at 100%
                      final carWidth = 80.0;
                      final startPosition = 120.0;
                      final finishLineWidth = 21.0;
                      final endPosition = constraints.maxWidth - finishLineWidth - carWidth;
                      final carPosition = startPosition + (progress * (endPosition - startPosition));

                      return Stack(
                        children: [
                          // Checkered finish line (right side)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: CustomPaint(
                              size: Size(finishLineWidth, constraints.maxHeight),
                              painter: CheckeredFinishLinePainter(),
                            ),
                          ),

                          // Player name (left side, directly above track)
                          Positioned(
                            left: 0,
                            bottom: constraints.maxHeight / 2,
                            child: Text(
                              'Player 1',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                          // Track line
                          Positioned(
                            left: 0,
                            right: finishLineWidth,
                            top: constraints.maxHeight / 2,
                            child: Container(
                              height: 4,
                              color: Colors.grey[400],
                            ),
                          ),

                          // Racecar
                          Positioned(
                            left: carPosition,
                            top: constraints.maxHeight / 2 - 30,
                            child: Transform.scale(
                              scaleX: -1.0,
                              child: Image.asset(
                                'assets/images/race_car_side_view_null_1768514951899.png',
                                width: carWidth,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const Divider(height: 1),

              // Second quarter: Text to type
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 24, color: Colors.black, height: 1.8),
                        children: [
                          // Typed text (green)
                          TextSpan(
                            text: _targetText.substring(0, _currentIndex),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: baseFontSize,
                                height: 1.8),
                          ),
                          // Current character (highlighted)
                          if (_currentIndex < _targetText.length)
                            TextSpan(
                              text: _targetText[_currentIndex],
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: _targetText[_currentIndex] == ' ' ? TextDecoration.underline : null,
                                decorationThickness: 2.0,
                                fontSize: baseFontSize + 2,
                                height: 1.8,
                              ),
                            ),
                          // Remaining text (gray)
                          if (_currentIndex < _targetText.length - 1)
                            TextSpan(
                              text: _targetText.substring(_currentIndex + 1),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: baseFontSize,
                                  height: 1.8),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // Bottom half: Visual keyboard
              Expanded(
                flex: 2,
                child: VisualKeyboard(pressedKey: _currentPressedKey),
              ),
            ],
          ),
        ),
      ),
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


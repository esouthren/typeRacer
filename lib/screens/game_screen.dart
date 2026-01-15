import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:typeracer/widgets/visual_keyboard.dart';

/// Main game screen for TypeRacer
/// 
/// Split into two halves:
/// - Top: Text to type with color-coded progress
/// - Bottom: Visual keyboard showing key presses
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();
  
  // Text to type (lorem ipsum placeholder)
  final String _targetText = 'The quick brown fox jumps over the lazy dog. '
      'Pack my box with five dozen liquor jugs. '
      'How vexingly quick daft zebras jump!';
  
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
          const SnackBar(content: Text('Complete!'), duration: Duration(seconds: 2)),
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
              // Top half: Text to type
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 24, color: Colors.black),
                        children: [
                          // Typed text (green)
                          TextSpan(
                            text: _targetText.substring(0, _currentIndex),
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          // Current character (highlighted)
                          if (_currentIndex < _targetText.length)
                            TextSpan(
                              text: _targetText[_currentIndex],
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          // Remaining text (gray)
                          if (_currentIndex < _targetText.length - 1)
                            TextSpan(
                              text: _targetText.substring(_currentIndex + 1),
                              style: const TextStyle(color: Colors.grey),
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
                child: VisualKeyboard(pressedKey: _currentPressedKey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

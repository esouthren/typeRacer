import 'package:flutter/material.dart';

/// Visual keyboard component that displays a keyboard layout
/// and highlights keys when pressed
class VisualKeyboard extends StatelessWidget {
  final String? pressedKey;

  const VisualKeyboard({super.key, this.pressedKey});

  // Keyboard layout (QWERTY with punctuation)
  static const List<List<String>> _keyboardLayout = [
    ['`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '='],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', '\''],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Keyboard rows
          ..._keyboardLayout.map((row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) => _buildKey(key)).toList(),
            ),
          )),
          
          // Space bar row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _buildKey(' ', width: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key, {double? width}) {
    final isPressed = pressedKey != null && 
        (pressedKey!.toUpperCase() == key.toUpperCase() || 
         pressedKey == key ||
         (key == ' ' && pressedKey == ' '));
    
    final displayText = key == ' ' ? 'SPACE' : key;

    return Container(
      width: width ?? 50,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: isPressed ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPressed ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

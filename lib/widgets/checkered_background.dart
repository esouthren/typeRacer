import 'package:flutter/material.dart';

class CheckeredBackground extends StatelessWidget {
  final Widget child;
  final double squareSize;

  const CheckeredBackground({
    super.key,
    required this.child,
    this.squareSize = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: CheckeredPainter(
              color1: theme.tertiary,
              color2: theme.onTertiary,
              squareSize: squareSize,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class CheckeredPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double squareSize;

  CheckeredPainter({
    required this.color1,
    required this.color2,
    required this.squareSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background with color1
    final paint = Paint()..color = color1;
    canvas.drawRect(Offset.zero & size, paint);

    // Draw squares with color2
    paint.color = color2;

    // Calculate number of rows and columns needed
    final rows = (size.height / squareSize).ceil();
    final cols = (size.width / squareSize).ceil();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        // Draw only on alternating squares
        if ((row + col) % 2 == 1) {
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
  }

  @override
  bool shouldRepaint(covariant CheckeredPainter oldDelegate) {
    return oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2 ||
        oldDelegate.squareSize != squareSize;
  }
}

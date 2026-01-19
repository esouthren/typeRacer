import 'package:flutter/material.dart';

/// Custom action button component (Duplicated from LandingScreen for independence)
enum ButtonType {
  filled,
  outlined
}
class Button extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final ButtonType? type;
  final double width;

  const Button({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.type = ButtonType.filled,
    this.width = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 60,
      child: type == ButtonType.filled
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
    );
  }
}

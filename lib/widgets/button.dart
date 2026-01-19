import 'package:flutter/material.dart';

/// Custom action button component (Duplicated from LandingScreen for independence)
enum ButtonType { filled, outlined }

class Button extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final ButtonType? type;
  final double width;
  final bool disabled;

  const Button({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.type = ButtonType.filled,
    this.width = 300.0,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Helper to get text widget
    Widget buildText() => Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return SizedBox(
      width: width,
      height: 60,
      child: type == ButtonType.filled
          ? FilledButton.icon(
              onPressed: disabled ? null : onPressed,
              icon: icon != null ? Icon(icon) : null,
              label: buildText(),
              style: FilledButton.styleFrom(
                shape: shape,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                disabledBackgroundColor:
                    colorScheme.primary.withValues(alpha: 0.5),
                disabledForegroundColor:
                    colorScheme.onPrimary.withValues(alpha: 0.6),
              ),
            )
          : OutlinedButton.icon(
              onPressed: disabled ? null : onPressed,
              icon: icon != null ? Icon(icon) : null,
              label: buildText(),
              style: OutlinedButton.styleFrom(
                shape: shape,
                foregroundColor: colorScheme.primary,
                disabledForegroundColor:
                    colorScheme.primary.withValues(alpha: 0.5),
                side: BorderSide(
                  color: disabled
                      ? colorScheme.outline.withValues(alpha: 0.3)
                      : colorScheme.outline,
                  width: 1.5,
                ),
              ),
            ),
    );
  }
}

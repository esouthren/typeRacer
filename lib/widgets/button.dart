import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom action button component (Duplicated from LandingScreen for independence)
enum ButtonType { filled, outlined }
enum ButtonColor {primary, onPrimary, secondary, onSecondary}

class Button extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final ButtonType? type;
  final double width;
  final bool disabled;
  final ButtonColor buttonColor;

  const Button({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.type = ButtonType.filled,
    this.width = 300.0,
    this.disabled = false,
    this.buttonColor = ButtonColor.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Helper to get text widget
    Widget buildText() => Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 16, // Adjusted size for better fit with pixel font
            fontWeight: FontWeight.w600,
          ),
        );

    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    );
    
    const borderSide = BorderSide(
      color: Colors.black,
      width: 4.0,
    );

    final backgroundColor = switch (buttonColor) {
      ButtonColor.primary => colorScheme.primary,
      ButtonColor.onPrimary => colorScheme.onPrimary,
      ButtonColor.secondary => colorScheme.secondary,
      ButtonColor.onSecondary => colorScheme.onSecondary,
    };

    final foregroundColor = switch (buttonColor) {
      ButtonColor.primary => Colors.white,
      ButtonColor.onPrimary => colorScheme.onPrimaryContainer,
      ButtonColor.secondary => colorScheme.onSecondary,
      ButtonColor.onSecondary => colorScheme.secondary,
    };

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
                side: borderSide,
                elevation: 0,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
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
                side: borderSide,
                elevation: 0,
                foregroundColor: backgroundColor,
                disabledForegroundColor:
                    colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
    );
  }
}

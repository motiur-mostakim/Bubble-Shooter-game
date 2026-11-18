import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle title({Color color = Colors.white, double fontSize = 28}) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
      shadows: [
        Shadow(
          blurRadius: 4.0,
          color: Colors.black.withValues(alpha: 0.6),
          offset: const Offset(2.0, 2.0),
        ),
      ],
    );
  }

  static TextStyle subtitle({Color color = Colors.white, double fontSize = 18}) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black.withValues(alpha: 0.4),
          offset: const Offset(1.0, 1.0),
        ),
      ],
    );
  }

  static TextStyle body({Color color = Colors.white70, double fontSize = 14}) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
  }
}

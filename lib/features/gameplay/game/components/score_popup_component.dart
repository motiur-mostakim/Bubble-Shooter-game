import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScorePopupComponent extends PositionComponent {
  final String text;
  final Color textColor;
  double opacity = 1.0;

  ScorePopupComponent({
    required this.text,
    required Vector2 position,
    this.textColor = Colors.amberAccent,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= dt * 40;
    opacity -= dt * 1.5;
    if (opacity <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor.withValues(alpha: max(0.0, opacity)),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.black.withValues(alpha: opacity),
              offset: const Offset(1, 1),
            )
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }
}

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/bubble_type.dart';

class BubbleComponent extends PositionComponent {
  final BubbleColor color;
  final double radius;
  final String bubbleSkinType;
  final Sprite? sprite;
  bool isPopping;
  bool isFalling;
  double popProgress = 0.0;
  Vector2 fallVelocity = Vector2(0, 200);

  BubbleComponent({
    required this.color,
    required this.radius,
    required Vector2 position,
    this.bubbleSkinType = 'forest',
    this.sprite,
    this.isPopping = false,
    this.isFalling = false,
  }) : super(
          position: position,
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);

    if (isPopping) {
      popProgress += dt * 5.0; // pop fast in ~0.2 sec
      if (popProgress >= 1.0) {
        removeFromParent();
      }
    } else if (isFalling) {
      fallVelocity.y += 600 * dt; // gravity speedup
      position += fallVelocity * dt;
      if (position.y > 1000) {
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final currentRadius = isPopping
        ? radius * (1.0 + popProgress * 0.4)
        : radius;

    final alpha = isPopping ? max(0.0, 1.0 - popProgress) : 1.0;

    final drawDiameter = currentRadius * 2;
    final drawPos = Vector2(
      size.x / 2 - currentRadius,
      size.y / 2 - currentRadius,
    );

    if (sprite != null) {
      final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
      sprite!.render(
        canvas,
        position: drawPos,
        size: Vector2(drawDiameter, drawDiameter),
        overridePaint: paint,
      );
    } else {
      _drawCustomCanvasBubble(canvas, currentRadius, alpha);
    }
  }

  void _drawCustomCanvasBubble(Canvas canvas, double currentRadius, double alpha) {
    final center = Offset(size.x / 2, size.y / 2);

    // Draw gloss 3D bubble
    final baseColor = color.color.withValues(alpha: alpha);
    final shadowColor = color.secondaryColor.withValues(alpha: alpha);

    // 1. Base Gradient Fill
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [baseColor, shadowColor],
        center: const Alignment(-0.35, -0.35),
        radius: 0.85,
      ).createShader(Rect.fromCircle(center: center, radius: currentRadius));

    canvas.drawCircle(center, currentRadius, paint);

    // 2. Theme-Specific Bubble Skin Overlays
    _drawThemeBubbleSkin(canvas, center, currentRadius, alpha);

    // 3. Special Symbols for Powerups or Obstacles
    if (color == BubbleColor.bomb) {
      _drawBombIcon(canvas, center, currentRadius, alpha);
    } else if (color == BubbleColor.rainbow) {
      _drawRainbowRing(canvas, center, currentRadius, alpha);
    } else if (color == BubbleColor.lightning) {
      _drawLightningIcon(canvas, center, currentRadius, alpha);
    } else if (color == BubbleColor.stone) {
      _drawStoneTexture(canvas, center, currentRadius, alpha);
    } else if (color == BubbleColor.ice) {
      _drawIceTexture(canvas, center, currentRadius, alpha);
    }

    // 4. Glossy Specular Top-Left Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65 * alpha);

    final highlightOffset = Offset(
      center.dx - currentRadius * 0.35,
      center.dy - currentRadius * 0.35,
    );
    canvas.drawCircle(highlightOffset, currentRadius * 0.28, highlightPaint);
  }

  void _drawThemeBubbleSkin(
      Canvas canvas, Offset center, double r, double alpha) {
    switch (bubbleSkinType) {
      case 'ocean':
        final rimPaint = Paint()
          ..color = Colors.cyanAccent.withValues(alpha: 0.4 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(center, r * 0.88, rimPaint);
        break;
      case 'candy':
        final candyPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.35 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(center, r * 0.6, candyPaint);
        break;
      case 'galaxy':
        final starPaint = Paint()
          ..color = Colors.purpleAccent.withValues(alpha: 0.5 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(center, r * 0.75, starPaint);
        break;
      case 'fairy':
        final fairyPaint = Paint()
          ..color = Colors.amberAccent.withValues(alpha: 0.45 * alpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, r * 0.2, fairyPaint);
        break;
      case 'winter':
        final iceRim = Paint()
          ..color = Colors.white.withValues(alpha: 0.6 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(center, r * 0.92, iceRim);
        break;
      case 'forest':
      default:
        final leafRim = Paint()
          ..color = Colors.lightGreenAccent.withValues(alpha: 0.35 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(center, r * 0.8, leafRim);
        break;
    }
  }

  void _drawBombIcon(Canvas canvas, Offset center, double r, double alpha) {
    final p = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r * 0.4, p);
  }

  void _drawRainbowRing(Canvas canvas, Offset center, double r, double alpha) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple
    ];
    final strokeP = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < colors.length; i++) {
      strokeP.color = colors[i].withValues(alpha: alpha);
      canvas.drawCircle(center, r * (0.3 + i * 0.08), strokeP);
    }
  }

  void _drawLightningIcon(Canvas canvas, Offset center, double r, double alpha) {
    final path = Path()
      ..moveTo(center.dx - r * 0.2, center.dy - r * 0.4)
      ..lineTo(center.dx + r * 0.1, center.dy - r * 0.1)
      ..lineTo(center.dx - r * 0.1, center.dy + r * 0.05)
      ..lineTo(center.dx + r * 0.2, center.dy + r * 0.4)
      ..lineTo(center.dx - r * 0.1, center.dy + r * 0.1)
      ..lineTo(center.dx + r * 0.1, center.dy - r * 0.05)
      ..close();

    final p = Paint()
      ..color = Colors.amber.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, p);
  }

  void _drawStoneTexture(Canvas canvas, Offset center, double r, double alpha) {
    final p = Paint()
      ..color = Colors.grey.shade900.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(center.dx - r * 0.3, center.dy - r * 0.2),
      Offset(center.dx + r * 0.3, center.dy + r * 0.2),
      p,
    );
  }

  void _drawIceTexture(Canvas canvas, Offset center, double r, double alpha) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, r * 0.5, p);
  }
}

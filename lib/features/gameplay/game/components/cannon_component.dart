import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/bubble_type.dart';
import '../../../../data/models/theme_model.dart';
import '../../../../data/static_data/themes_data.dart';

class CannonComponent extends PositionComponent {
  double aimAngle = -pi / 2; // -90 deg
  BubbleColor readyColor;
  BubbleColor nextColor;
  final ThemeModel activeTheme;
  final Sprite? baseSprite;
  final Sprite? cloverSprite;
  final Map<BubbleColor, Sprite>? bubbleSprites;

  double recoilProgress = 0.0;

  CannonComponent({
    required Vector2 position,
    required this.readyColor,
    required this.nextColor,
    ThemeModel? activeTheme,
    this.baseSprite,
    this.cloverSprite,
    this.bubbleSprites,
  })  : activeTheme = activeTheme ?? ThemesData.themes.first,
        super(
          position: position,
          size: Vector2(110, 110),
          anchor: Anchor.center,
        );

  void triggerRecoil() {
    recoilProgress = 1.0;
  }

  void updateColors(BubbleColor ready, BubbleColor next) {
    readyColor = ready;
    nextColor = next;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (recoilProgress > 0) {
      recoilProgress = max(0.0, recoilProgress - dt * 6.0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);
    final cannonThemeColor = activeTheme.cannonColor;
    final accentColor = activeTheme.accentColor;

    // 1. Draw Launcher Base Platform Sprite
    if (baseSprite != null) {
      baseSprite!.render(
        canvas,
        position: Vector2.zero(),
        size: size,
      );
    } else {
      // Fallback base
      final basePaint = Paint()
        ..shader = RadialGradient(
          colors: [cannonThemeColor, activeTheme.backgroundColor],
          center: Alignment.center,
        ).createShader(Rect.fromCircle(center: center, radius: 45));

      canvas.drawCircle(center, 44, basePaint);
      canvas.drawCircle(
        center,
        44,
        Paint()
          ..color = accentColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // 2. Draw Rotating Cannon Barrel & Ready Bubble
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(aimAngle + pi / 2);

    final recoilOffset = recoilProgress * 12.0;
    final barrelWidth = 36.0;
    final barrelHeight = 65.0;

    final barrelRect = Rect.fromLTWH(
      -barrelWidth / 2,
      -barrelHeight + recoilOffset,
      barrelWidth,
      barrelHeight,
    );

    final barrelPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          cannonThemeColor,
          Colors.white,
          cannonThemeColor,
          Colors.black45
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(barrelRect);

    final barrelRRect = RRect.fromRectAndRadius(
      barrelRect,
      const Radius.circular(8.0),
    );
    canvas.drawRRect(barrelRRect, barrelPaint);

    // Rim ring at top of barrel
    final rimRect = Rect.fromLTWH(
      -barrelWidth / 2 - 3,
      -barrelHeight + recoilOffset - 4,
      barrelWidth + 6,
      10,
    );
    final rimPaint = Paint()..color = accentColor;
    canvas.drawRRect(RRect.fromRectAndRadius(rimRect, const Radius.circular(4)), rimPaint);

    // Render Ready Bubble inside barrel launcher
    _drawBubbleAt(
      canvas,
      Offset(0, -barrelHeight / 2 + recoilOffset),
      readyColor,
      17,
    );

    canvas.restore();

    // 3. Next Bubble Preview Box (Bottom-left of cannon base)
    final nextCenter = Offset(center.dx - 48, center.dy + 12);
    final boxPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(nextCenter, 20, boxPaint);
    canvas.drawCircle(
      nextCenter,
      20,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    _drawBubbleAt(canvas, nextCenter, nextColor, 14);
  }

  void _drawBubbleAt(Canvas canvas, Offset pos, BubbleColor color, double r) {
    final sprite = (color == BubbleColor.green && cloverSprite != null)
        ? cloverSprite
        : (bubbleSprites != null ? bubbleSprites![color] : null);

    if (sprite != null) {
      sprite.render(
        canvas,
        position: Vector2(pos.dx - r, pos.dy - r),
        size: Vector2(r * 2, r * 2),
      );
    } else {
      final p = Paint()
        ..shader = RadialGradient(
          colors: [color.color, color.secondaryColor],
          center: const Alignment(-0.3, -0.3),
        ).createShader(Rect.fromCircle(center: pos, radius: r));
      canvas.drawCircle(pos, r, p);

      final hP = Paint()..color = Colors.white.withValues(alpha: 0.7);
      canvas.drawCircle(Offset(pos.dx - r * 0.3, pos.dy - r * 0.3), r * 0.25, hP);
    }
  }
}

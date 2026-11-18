import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TrajectoryComponent extends Component {
  Vector2 origin = Vector2.zero();
  double angle = -pi / 2; // -90 deg (pointing straight up)
  bool isAiming = false;
  double minX = 0;
  double maxX = 400;
  double topY = 0;
  double animationTimer = 0.0;
  Color accentColor;
  final Sprite? aimDotSprite;

  TrajectoryComponent({
    this.accentColor = const Color(0xFF76FF03), // Bright neon green
    this.aimDotSprite,
  });

  void updateAim({
    required Vector2 origin,
    required double angle,
    required bool isAiming,
    required double minX,
    required double maxX,
    required double topY,
  }) {
    this.origin = origin;
    this.angle = angle;
    this.isAiming = isAiming;
    this.minX = minX;
    this.maxX = maxX;
    this.topY = topY;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isAiming) {
      animationTimer += dt * 50;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!isAiming) return;

    final dir = Vector2(cos(angle), sin(angle)).normalized();
    final points = _calculateTrajectoryPoints(origin, dir);

    final neonGreenPaint = Paint()
      ..color = const Color(0xFF76FF03)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xFFB2FF59).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Draw animated trajectory dots along line segments
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final segVector = p2 - p1;
      final distance = segVector.length;
      final segDir = segVector.normalized();

      double step = 16.0;
      double offset = (animationTimer % step);

      for (double d = offset; d < distance; d += step) {
        final dotPos = p1 + segDir * d;

        if (aimDotSprite != null) {
          aimDotSprite!.render(
            canvas,
            position: Vector2(dotPos.x - 6, dotPos.y - 6),
            size: Vector2(12, 12),
          );
        } else {
          // Neon glowing green circular dot fallback
          canvas.drawCircle(Offset(dotPos.x, dotPos.y), 6.0, glowPaint);
          canvas.drawCircle(Offset(dotPos.x, dotPos.y), 3.5, neonGreenPaint);
        }
      }
    }

    // Draw impact target circle at end point
    if (points.isNotEmpty) {
      final end = points.last;
      final impactPaint = Paint()
        ..color = const Color(0xFF76FF03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(Offset(end.x, end.y), 14, impactPaint);
      canvas.drawCircle(Offset(end.x, end.y), 4, neonGreenPaint);
    }
  }

  List<Vector2> _calculateTrajectoryPoints(
      Vector2 startPos, Vector2 direction) {
    final points = <Vector2>[startPos.clone()];
    Vector2 currentPos = startPos.clone();
    Vector2 currentDir = direction.clone();

    int maxBounces = 2;
    double maxDistance = 900.0;
    double distanceTraveled = 0.0;

    for (int bounce = 0; bounce <= maxBounces; bounce++) {
      // Find distance to left/right wall or top ceiling
      double tWall = double.infinity;
      double tTop = double.infinity;

      if (currentDir.x < 0) {
        tWall = (minX - currentPos.x) / currentDir.x;
      } else if (currentDir.x > 0) {
        tWall = (maxX - currentPos.x) / currentDir.x;
      }

      if (currentDir.y < 0) {
        tTop = (topY - currentPos.y) / currentDir.y;
      }

      double t = min(tWall, tTop);
      if (t <= 0 || t.isInfinite || t.isNaN) break;

      if (distanceTraveled + t > maxDistance) {
        t = maxDistance - distanceTraveled;
        currentPos += currentDir * t;
        points.add(currentPos.clone());
        break;
      }

      currentPos += currentDir * t;
      distanceTraveled += t;
      points.add(currentPos.clone());

      if (t == tTop) {
        break;
      } else {
        currentDir.x = -currentDir.x;
      }
    }

    return points;
  }
}

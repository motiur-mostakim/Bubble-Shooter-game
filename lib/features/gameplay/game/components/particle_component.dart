import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class SparkParticle {
  Vector2 pos;
  Vector2 vel;
  Color color;
  double radius;
  double life = 1.0;
  final Sprite? sprite;

  SparkParticle({
    required this.pos,
    required this.vel,
    required this.color,
    required this.radius,
    this.sprite,
  });
}

class ParticleComponent extends Component {
  final List<SparkParticle> particles = [];
  final Random _rng = Random();

  final Sprite? popSprite;
  final Sprite? sparkleSprite;
  final Sprite? explosionSprite;

  ParticleComponent({
    this.popSprite,
    this.sparkleSprite,
    this.explosionSprite,
  });

  void explodeAt(Vector2 origin, Color baseColor,
      {int count = 14, List<Color>? themeColors}) {
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 90.0 + _rng.nextDouble() * 180.0;
      final vel = Vector2(cos(angle) * speed, sin(angle) * speed);

      final color = (themeColors != null && themeColors.isNotEmpty && _rng.nextBool())
          ? themeColors[_rng.nextInt(themeColors.length)]
          : baseColor;

      final pSprite = (_rng.nextBool()) ? sparkleSprite : popSprite;

      particles.add(
        SparkParticle(
          pos: origin.clone(),
          vel: vel,
          color: color,
          radius: 5.0 + _rng.nextDouble() * 6.0,
          sprite: pSprite,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.life -= dt * 2.5;
      p.pos += p.vel * dt;
      p.vel.y += 140 * dt; // gravity drag
      if (p.life <= 0) {
        particles.removeAt(i);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (final p in particles) {
      final alpha = max(0.0, p.life);
      if (p.sprite != null) {
        final drawSize = p.radius * 2 * p.life;
        final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
        p.sprite!.render(
          canvas,
          position: Vector2(p.pos.x - drawSize / 2, p.pos.y - drawSize / 2),
          size: Vector2(drawSize, drawSize),
          overridePaint: paint,
        );
      } else {
        final paint = Paint()
          ..color = p.color.withValues(alpha: alpha)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(p.pos.x, p.pos.y), p.radius * p.life, paint);
      }
    }
  }
}

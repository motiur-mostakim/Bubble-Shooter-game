import 'dart:math';
import 'package:flutter/material.dart';

class EnvironmentalParticle {
  double x;
  double y;
  double size;
  double speedY;
  double speedX;
  double rotation;
  double rotationSpeed;
  double opacity;
  Color color;

  EnvironmentalParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required this.color,
  });
}

class EnvironmentParticlesWidget extends StatefulWidget {
  final String particleType;
  final List<Color> colors;
  final int particleCount;

  const EnvironmentParticlesWidget({
    super.key,
    required this.particleType,
    required this.colors,
    this.particleCount = 20,
  });

  @override
  State<EnvironmentParticlesWidget> createState() =>
      _EnvironmentParticlesWidgetState();
}

class _EnvironmentParticlesWidgetState extends State<EnvironmentParticlesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<EnvironmentalParticle> _particles;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initParticles();
  }

  @override
  void didUpdateWidget(EnvironmentParticlesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.particleType != widget.particleType) {
      _initParticles();
    }
  }

  void _initParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      return _generateParticle();
    });
  }

  EnvironmentalParticle _generateParticle() {
    final color = widget.colors.isNotEmpty
        ? widget.colors[_rng.nextInt(widget.colors.length)]
        : Colors.white;

    double speedY = 0;
    double speedX = 0;

    switch (widget.particleType) {
      case 'leaf':
        speedY = 15.0 + _rng.nextDouble() * 25.0; // falling leaves
        speedX = ( -1.0 + _rng.nextDouble() * 2.0) * 15.0;
        break;
      case 'bubble':
        speedY = -(20.0 + _rng.nextDouble() * 30.0); // rising bubbles
        speedX = ( -0.5 + _rng.nextDouble() * 1.0) * 10.0;
        break;
      case 'snowflake':
        speedY = 20.0 + _rng.nextDouble() * 35.0; // falling snow
        speedX = ( -0.8 + _rng.nextDouble() * 1.6) * 12.0;
        break;
      case 'firefly':
        speedY = ( -1.0 + _rng.nextDouble() * 2.0) * 12.0; // floating fireflies
        speedX = ( -1.0 + _rng.nextDouble() * 2.0) * 12.0;
        break;
      case 'sparkle':
      case 'star':
      default:
        speedY = ( -0.5 + _rng.nextDouble() * 1.0) * 15.0;
        speedX = ( -0.5 + _rng.nextDouble() * 1.0) * 15.0;
        break;
    }

    return EnvironmentalParticle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: 4.0 + _rng.nextDouble() * 8.0,
      speedY: speedY,
      speedX: speedX,
      rotation: _rng.nextDouble() * pi * 2,
      rotationSpeed: (-1.0 + _rng.nextDouble() * 2.0) * 2.0,
      opacity: 0.4 + _rng.nextDouble() * 0.5,
      color: color,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: EnvironmentParticlesPainter(
            particles: _particles,
            particleType: widget.particleType,
            dt: 0.016, // approx 60fps frame delta
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class EnvironmentParticlesPainter extends CustomPainter {
  final List<EnvironmentalParticle> particles;
  final String particleType;
  final double dt;

  EnvironmentParticlesPainter({
    required this.particles,
    required this.particleType,
    required this.dt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Update position
      p.x += (p.speedX / size.width) * dt * 60;
      p.y += (p.speedY / size.height) * dt * 60;
      p.rotation += p.rotationSpeed * dt;

      // Wrap around bounds
      if (p.x < -0.1) p.x = 1.1;
      if (p.x > 1.1) p.x = -0.1;
      if (p.y < -0.1) p.y = 1.1;
      if (p.y > 1.1) p.y = -0.1;

      final px = p.x * size.width;
      final py = p.y * size.height;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      switch (particleType) {
        case 'leaf':
          _drawLeaf(canvas, p.size, paint);
          break;
        case 'bubble':
          _drawBubble(canvas, p.size, paint);
          break;
        case 'snowflake':
          _drawSnowflake(canvas, p.size, paint);
          break;
        case 'firefly':
          _drawFirefly(canvas, p.size, p.color, p.opacity);
          break;
        case 'star':
          _drawStar(canvas, p.size, paint);
          break;
        case 'sparkle':
        default:
          _drawSparkle(canvas, p.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawLeaf(Canvas canvas, double size, Paint paint) {
    final path = Path()
      ..moveTo(0, -size)
      ..quadraticBezierTo(size, 0, 0, size)
      ..quadraticBezierTo(-size, 0, 0, -size);
    canvas.drawPath(path, paint);
  }

  void _drawBubble(Canvas canvas, double size, Paint paint) {
    canvas.drawCircle(Offset.zero, size, paint..style = PaintingStyle.stroke..strokeWidth = 1.5);
    final highlight = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(-size * 0.3, -size * 0.3), size * 0.3, highlight);
  }

  void _drawSnowflake(Canvas canvas, double size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(Offset(0, -size), Offset(0, size), paint);
      canvas.rotate(pi / 3);
    }
  }

  void _drawFirefly(Canvas canvas, double size, Color color, double opacity) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size);
    canvas.drawCircle(Offset.zero, size * 2, glowPaint);

    final corePaint = Paint()..color = Colors.white.withValues(alpha: opacity);
    canvas.drawCircle(Offset.zero, size * 0.5, corePaint);
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2);
      final outerX = cos(angle) * size;
      final outerY = sin(angle) * size;
      final innerAngle = angle + pi / 4;
      final innerX = cos(innerAngle) * (size * 0.3);
      final innerY = sin(innerAngle) * (size * 0.3);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, double size, Paint paint) {
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size, height: size * 0.3), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size * 0.3, height: size), paint);
  }

  @override
  bool shouldRepaint(covariant EnvironmentParticlesPainter oldDelegate) => true;
}

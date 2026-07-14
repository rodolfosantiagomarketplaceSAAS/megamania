import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/megamania_game.dart';

/// Renders the high-res nebula space background generated from the reference image.
class SpaceBackground extends SpriteComponent with HasGameRef<MegamaniaGame> {
  SpaceBackground({required Sprite sprite}) : super(sprite: sprite, priority: -2);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}

/// Star model for the parallax starfield.
class Star {
  double x = 0;
  double y = 0;
  double speed = 0;
  double size = 0;
  Color color = Colors.white;
}

/// Renders a moving parallax starfield with synthwave colors (neon cyan and pink).
class Starfield extends PositionComponent with HasGameRef<MegamaniaGame> {
  final List<Star> _stars = [];
  final Random _random = Random();

  Starfield() : super(priority: -1); // Above background, below gameplay entities

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _initStars(size);
  }

  void _initStars(Vector2 size) {
    _stars.clear();
    for (int i = 0; i < 45; i++) {
      final star = Star()
        ..x = _random.nextDouble() * size.x
        ..y = _random.nextDouble() * size.y
        ..speed = 30.0 + _random.nextDouble() * 110.0 // Parallax speed layers
        ..size = 0.6 + _random.nextDouble() * 1.8
        ..color = _random.nextBool()
            ? const Color(0xFF00FFCC).withOpacity(0.3 + _random.nextDouble() * 0.7) // Cyan neon glow
            : const Color(0xFFFF007F).withOpacity(0.3 + _random.nextDouble() * 0.7); // Pink neon glow
      _stars.add(star);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final sizeY = gameRef.canvasSize.y;
    final sizeX = gameRef.canvasSize.x;
    for (final star in _stars) {
      star.y += star.speed * dt;
      if (star.y > sizeY) {
        star.y = 0;
        star.x = _random.nextDouble() * sizeX;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..style = PaintingStyle.fill;
    for (final star in _stars) {
      paint.color = star.color;
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }
}

/// Individual particle model for the glowing explosion effect.
class ExplosionParticle {
  Vector2 position;
  Vector2 velocity;
  double size;
  Color color;
  double alpha = 1.0;

  ExplosionParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
  });
}

/// Renders a premium glowing particle explosion when an enemy is destroyed.
class ExplosionEffect extends PositionComponent {
  final List<ExplosionParticle> _particles = [];
  final double _lifetime = 0.45; // duration in seconds
  double _elapsed = 0.0;

  ExplosionEffect({required Vector2 position, required Color color}) 
      : super(position: position, priority: 15) {
    final random = Random();
    // Generate 18 particles shooting outwards in radial directions
    for (int i = 0; i < 18; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 70.0 + random.nextDouble() * 130.0;
      _particles.add(ExplosionParticle(
        position: Vector2.zero(),
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        size: 1.5 + random.nextDouble() * 3.5,
        color: color,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _lifetime) {
      removeFromParent();
      return;
    }

    final ratio = (1.0 - _elapsed / _lifetime).clamp(0.0, 1.0);
    for (final p in _particles) {
      p.position += p.velocity * dt;
      p.alpha = ratio;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in _particles) {
      // Glow shadow layer
      final Paint glowPaint = Paint()
        ..color = p.color.withOpacity(p.alpha * 0.35);
      try {
        glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      } catch (_) {}
      
      canvas.drawCircle(Offset(p.position.x, p.position.y), p.size + 2.0, glowPaint);
      
      // Core particle solid layer
      paint.color = p.color.withOpacity(p.alpha);
      canvas.drawCircle(Offset(p.position.x, p.position.y), p.size, paint);
    }
  }
}

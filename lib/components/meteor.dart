import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/megamania_game.dart';
import 'player_ship.dart';
import 'laser.dart';

class TrailParticle extends PositionComponent with HasGameRef<MegamaniaGame> {
  final Color color;
  final double maxLifetime;
  double _lifetime = 0.0;
  final Vector2 velocity;

  TrailParticle({
    required Vector2 position,
    required this.color,
    required this.velocity,
    this.maxLifetime = 0.4,
  }) : super(position: position, size: Vector2(4.0, 4.0), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    position += velocity * dt;
    if (_lifetime >= maxLifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final double opacity = (1.0 - (_lifetime / maxLifetime)).clamp(0.0, 1.0);
    final Paint paint = Paint()..color = color.withOpacity(opacity);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }
}

class MeteorAlert extends PositionComponent with HasGameRef<MegamaniaGame> {
  final double targetX;
  double _timer = 0.0;
  static const double duration = 1.0;

  MeteorAlert({required this.targetX})
      : super(position: Vector2(targetX, 24.0), size: Vector2(28.0, 24.0), anchor: Anchor.topCenter);

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= duration) {
      // Spawn actual Meteor with fast diagonal speeds
      final double speedX = (Random().nextDouble() - 0.5) * 180.0;
      final double speedY = 400.0 + Random().nextDouble() * 100.0;
      gameRef.add(Meteor(
        position: Vector2(targetX, -40.0),
        speedX: speedX,
        speedY: speedY,
      ));
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Flash at 8Hz (every 120ms)
    final int ms = DateTime.now().millisecondsSinceEpoch;
    final bool show = (ms ~/ 120) % 2 == 0;
    if (!show) return;

    final double w = size.x;
    final double h = size.y;

    // Draw warning triangle
    final Paint paint = Paint()
      ..color = const Color(0xFFFF2A2A)
      ..style = PaintingStyle.fill;
    
    final Path path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(0, h)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, paint);

    // Draw exclamation mark inside
    final Paint textPaint = Paint()..color = Colors.white;
    // Dot
    canvas.drawCircle(Offset(w * 0.5, h * 0.8), 1.8, textPaint);
    // Line
    canvas.drawRect(Rect.fromLTRB(w * 0.46, h * 0.3, w * 0.54, h * 0.65), textPaint);
  }
}

class Meteor extends PositionComponent with HasGameRef<MegamaniaGame>, CollisionCallbacks {
  final double speedX;
  final double speedY;
  double _particleTimer = 0.0;
  double _accumulatedTime = 0.0;

  Meteor({
    required Vector2 position,
    required this.speedX,
    required this.speedY,
  }) : super(position: position, size: Vector2(40.0, 40.0), anchor: Anchor.center);

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _sprite = await gameRef.loadSprite('meteor.png');
    // Hitbox for collision detection
    add(CircleHitbox(radius: size.x * 0.4, position: size * 0.1));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _accumulatedTime += dt;

    // Fast diagonal translation
    position.x += speedX * dt;
    position.y += speedY * dt;

    // Spawn trail particles behind the meteor
    _particleTimer += dt;
    if (_particleTimer >= 0.02) { // spawn every 20ms
      _particleTimer = 0.0;
      final Color color = Random().nextBool() ? const Color(0xFFFF3D00) : const Color(0xFFFFC107);
      
      // Spawn particles slightly behind the meteor
      final Vector2 particleVel = Vector2(
        -speedX * 0.25 + (Random().nextDouble() - 0.5) * 50.0,
        -speedY * 0.25 + (Random().nextDouble() - 0.5) * 50.0,
      );
      gameRef.add(TrailParticle(
        position: position.clone() - Vector2(speedX * 0.03, speedY * 0.03),
        color: color,
        velocity: particleVel,
        maxLifetime: 0.35,
      ));
    }

    // Screen Shake and remove when exiting bounds
    if (position.y > gameRef.canvasSize.y + size.y ||
        position.x < -size.x ||
        position.x > gameRef.canvasSize.x + size.x) {
      gameRef.shakeCamera(duration: 0.20, intensity: 4.5);
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // Player lasers vanish on hit
    if (other is Laser && other.isPlayerLaser) {
      other.removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      canvas.save();
      // Aura glow effect
      final Paint glowPaint = Paint()
        ..color = const Color(0xFFFF5722).withOpacity(0.3);
      try {
        glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      } catch (_) {}
      canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.5), size.x * 0.55, glowPaint);

      // Rotate the meteor as it falls
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(_accumulatedTime * 2.2);
      canvas.translate(-size.x / 2, -size.y / 2);

      _sprite!.render(canvas, position: Vector2.zero(), size: size);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }
}

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/megamania_game.dart';
import 'enemy_component.dart';
import 'player_ship.dart';

class Laser extends PositionComponent 
    with HasGameRef<MegamaniaGame>, CollisionCallbacks {
  
  final bool isPlayerLaser;
  final double horizontalSpeed;
  final double offsetX;
  final double _speed;
 
  Laser({
    required Vector2 position,
    required this.isPlayerLaser,
    this.horizontalSpeed = 0.0,
    this.offsetX = 0.0,
  }) : _speed = isPlayerLaser ? -600.0 : 400.0,
       super(position: position, anchor: Anchor.center);
 
  @override
  Future<void> onLoad() async {
    size = Vector2(4.0, 16.0);
    add(RectangleHitbox());
  }
 
  @override
  void update(double dt) {
    super.update(dt);
    
    // Lineal movement along Y axis
    position.y += _speed * dt;
 
    // Apply horizontal momentum and follow ship movement if player laser
    if (isPlayerLaser) {
      position.x = gameRef.playerShip.position.x + offsetX;
    }

    // Self-destruct when exiting screens (checking both vertical and horizontal bounds)
    if (position.y < -size.y || 
        position.y > gameRef.canvasSize.y + size.y ||
        position.x < -size.x || 
        position.x > gameRef.canvasSize.x + size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (isPlayerLaser) {
      if (other is EnemyComponent) {
        other.takeDamage();
        removeFromParent();
      }
    } else {
      if (other is PlayerShip) {
        // PlayerShip registers damage inside its callback, but we clean up the projectile
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final Paint laserPaint = Paint()
      ..shader = LinearGradient(
        colors: isPlayerLaser 
            ? [const Color(0xFF00FFFF), const Color(0xFF0088FF)] 
            : [const Color(0xFFFF2A2A), const Color(0xFFFF8800)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    // Draw thin neon laser line
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(2.0),
      ),
      laserPaint,
    );

    // Glowing particle trace
    final Paint glowPaint = Paint()
      ..color = (isPlayerLaser ? const Color(0x6600FFFF) : const Color(0x66FF2A2A));
    try {
      glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    } catch (_) {}
    canvas.drawRect(Rect.fromLTWH(-1, -1, size.x + 2, size.y + 2), glowPaint);
  }
}

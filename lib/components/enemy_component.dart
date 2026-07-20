import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/megamania_game.dart';
import 'laser.dart';
import 'visual_effects.dart';

abstract class EnemyComponent extends PositionComponent 
    with HasGameRef<MegamaniaGame>, CollisionCallbacks {
  
  final int pointsReward;
  final double energyReward;
  
  double accumulatedTime = 0.0;
  double _shootTimer = 0.0;

  // Configuration for subclass shooting capabilities
  double get shotChance => 0.0;
  double get shotInterval => 1.0;

  // Custom explosion particle color for subclasses to override
  Color get explosionColor => const Color(0xFFFF007F); // Default to neon pink

  EnemyComponent({
    required Vector2 position,
    required Vector2 size,
    required this.pointsReward,
    required this.energyReward,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Standard collider initialization (subclasses can override for finer hitboxes)
    add(RectangleHitbox());
  }

  /// Triggers enemy destruction sequence, awards points, and updates energy meter.
  void takeDamage() {
    try {
      gameRef.playExplosion();
    } catch (e) {
      // Fail gracefully
    }
    
    // Spawn explosion particle effect
    gameRef.add(ExplosionEffect(position: position.clone(), color: explosionColor));

    // Calculate final points: 90 points for all enemies in Cycle 2+ (wave > 8)
    final int cycle = (gameRef.wave - 1) ~/ 8;
    final int finalPoints = (cycle > 0) ? 90 : pointsReward;

    gameRef.awardKill(finalPoints, energyReward);
    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Track lifetime for mathematical equations
    accumulatedTime += dt;

    if (gameRef.state == GameState.playing) {
      tryShoot(dt);
    }
  }

  void tryShoot(double dt) {
    if (shotChance <= 0.0) return;
    _shootTimer += dt;
    if (_shootTimer >= shotInterval) {
      _shootTimer = 0.0;
      if (Random().nextDouble() < shotChance) {
        _fireLaser();
      }
    }
  }

  void _fireLaser() {
    gameRef.add(Laser(
      position: position + Vector2(0.0, size.y * 0.5),
      isPlayerLaser: false,
    ));
  }
}

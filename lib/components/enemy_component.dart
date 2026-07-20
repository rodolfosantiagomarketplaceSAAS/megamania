import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import '../game/megamania_game.dart';
import 'laser.dart';
import 'visual_effects.dart';

abstract class EnemyComponent extends PositionComponent 
    with HasGameRef<MegamaniaGame>, CollisionCallbacks {
  
  final int pointsReward;
  final double energyReward;
  
  double accumulatedTime = 0.0;
  double _shootTimer = 0.0;

  // Unified Sprite loading
  Sprite? sprite;
  String get spriteAssetPath;

  // Custom 3D perspective matrix for subclasses to override
  vm64.Matrix4 get3DMatrix(double accumulatedTime) {
    return vm64.Matrix4.identity()
      ..setEntry(3, 2, 0.0018); // Default perspective factor
  }

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
    add(RectangleHitbox());
    if (spriteAssetPath.isNotEmpty) {
      try {
        sprite = await gameRef.loadSprite(spriteAssetPath);
      } catch (_) {}
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      canvas.save();
      // Translate to center to rotate/scale relative to center
      canvas.translate(size.x / 2, size.y / 2);

      final vm64.Matrix4 matrix = get3DMatrix(accumulatedTime);
      canvas.transform(matrix.storage);

      // Translate back and render the sprite
      canvas.translate(-size.x / 2, -size.y / 2);
      sprite!.render(canvas, position: Vector2.zero(), size: size);

      canvas.restore();
    } else {
      super.render(canvas);
    }
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

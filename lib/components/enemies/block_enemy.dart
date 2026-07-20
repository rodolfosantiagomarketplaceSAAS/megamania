import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import '../enemy_component.dart';

class BlockEnemy extends EnemyComponent {
  final double speedY;
  final double speedX;
  final double baseShotChance;

  double directionX; // 1.0 for Right, -1.0 for Left

  BlockEnemy({
    required Vector2 position,
    this.speedY = 85.0,
    this.speedX = 180.0,
    this.directionX = 1.0,
    this.baseShotChance = 0.22,
  }) : super(
          position: position,
          size: Vector2(36.0, 36.0),
          pointsReward: 90,
          energyReward: 22.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFFFF007F); // Pink block explosion

  @override
  void update(double dt) {
    super.update(dt);

    final double halfWidth = size.x / 2;

    // Diagonal translation
    position.y += speedY * dt;
    position.x += speedX * directionX * dt;

    // Bounce on side borders
    if (directionX < 0.0 && position.x <= halfWidth) {
      position.x = halfWidth;
      directionX = 1.0;
    } else if (directionX > 0.0 && position.x >= gameRef.canvasSize.x - halfWidth) {
      position.x = gameRef.canvasSize.x - halfWidth;
      directionX = -1.0;
    }
  }

  @override
  String get spriteAssetPath => 'block.png';

  @override
  vm64.Matrix4 get3DMatrix(double accumulatedTime) {
    final double yaw = sin(accumulatedTime * 3.0) * 0.3;
    final double pitch = cos(accumulatedTime * 3.0) * 0.3;
    return vm64.Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateY(yaw)
      ..rotateX(pitch);
  }
}

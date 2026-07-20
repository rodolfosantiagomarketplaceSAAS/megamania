import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import '../enemy_component.dart';

class DieEnemy extends EnemyComponent {
  final double speedY;
  final double speedX;
  final double baseShotChance;

  double directionX; // 1.0 for Right, -1.0 for Left

  DieEnemy({
    required Vector2 position,
    this.speedY = 80.0,
    this.speedX = 160.0,
    this.directionX = 1.0,
    this.baseShotChance = 0.12,
  }) : super(
          position: position,
          size: Vector2(38.0, 38.0),
          pointsReward: 60,
          energyReward: 16.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFFE040FB);

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
  String get spriteAssetPath => 'die.png';

  @override
  vm64.Matrix4 get3DMatrix(double accumulatedTime) {
    // Full 3D tumbling rotation around all axes
    final double yaw = accumulatedTime * 1.5;
    final double pitch = accumulatedTime * 1.2;
    final double roll = accumulatedTime * 0.8;
    return vm64.Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateY(yaw)
      ..rotateX(pitch)
      ..rotateZ(roll);
  }
}

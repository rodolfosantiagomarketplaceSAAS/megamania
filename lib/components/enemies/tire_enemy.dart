import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import '../enemy_component.dart';

class TireEnemy extends EnemyComponent {
  final double speedX;
  final double incrementY;
  final double baseShotChance;

  double direction; // 1.0 for Right, -1.0 for Left

  TireEnemy({
    required Vector2 position,
    this.speedX = 130.0,
    this.incrementY = 36.0,
    this.direction = 1.0,
    this.baseShotChance = 0.10,
  }) : super(
          position: position,
          size: Vector2(40.0, 40.0),
          pointsReward: 50,
          energyReward: 15.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFF00E5FF);

  @override
  void update(double dt) {
    super.update(dt);
    // Move horizontally (direction and descend managed collectively by WaveManager)
    position.x += speedX * direction * dt;

    // Screen wrapping horizontally
    final double halfWidth = size.x / 2;
    if (direction > 0.0 && position.x - halfWidth > gameRef.canvasSize.x) {
      position.x = -halfWidth;
    } else if (direction < 0.0 && position.x + halfWidth < 0.0) {
      position.x = gameRef.canvasSize.x + halfWidth;
    }
  }

  @override
  String get spriteAssetPath => 'tire.png';

  @override
  vm64.Matrix4 get3DMatrix(double accumulatedTime) {
    final double roll = accumulatedTime * 6.0 * direction;
    final double yaw = 0.2;
    return vm64.Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateY(yaw)
      ..rotateZ(roll);
  }
}

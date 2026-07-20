import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import '../enemy_component.dart';

class BugEnemy extends EnemyComponent {
  final double speedY;
  final double speedX;
  final double baseShotChance;

  double directionX; // 1.0 for Right, -1.0 for Left

  BugEnemy({
    required Vector2 position,
    this.speedY = 80.0,
    this.speedX = 150.0,
    this.directionX = 1.0,
    this.baseShotChance = 0.09,
  }) : super(
          position: position,
          size: Vector2(36.0, 36.0),
          pointsReward: 40,
          energyReward: 14.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFF4CAF50); // Bug green

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
  String get spriteAssetPath => 'bug.png';

  @override
  vm64.Matrix4 get3DMatrix(double accumulatedTime) {
    // Mario Wonder style squish/stretch and flap
    final double stretchX = 1.0 + sin(accumulatedTime * 8.0) * 0.12;
    final double stretchY = 1.0 - sin(accumulatedTime * 8.0) * 0.08;
    final double roll = sin(accumulatedTime * 10.0) * 0.1;
    return vm64.Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateZ(roll)
      ..scale(stretchX, stretchY);
  }
}

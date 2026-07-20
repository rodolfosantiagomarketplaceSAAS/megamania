import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import '../enemy_component.dart';

class HamburgerEnemy extends EnemyComponent {
  final double speedX;
  final double incrementY;
  final double baseShotChance;

  double direction; // 1.0 for Right, -1.0 for Left

  HamburgerEnemy({
    required Vector2 position,
    this.speedX = 120.0,
    this.incrementY = 36.0,
    this.direction = 1.0,
    this.baseShotChance = 0.05,
  }) : super(
          position: position,
          size: Vector2(66.0, 30.0), // Respected the 2.2 aspect ratio of the 3D sprite
          pointsReward: 20,
          energyReward: 10.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFFFFD54F);

  @override
  void update(double dt) {
    super.update(dt);
    // Move horizontally (direction and descend managed collectively by WaveManager)
    position.x += speedX * direction * dt;

    // Aerodynamic Roll (smooth Z-axis tilt when moving)
    final double targetAngle = direction * 0.08; // tilt slightly based on movement direction
    angle = angle + (targetAngle - angle) * 6.0 * dt;
  }

  @override
  String get spriteAssetPath => 'hamburger.png';

  @override
  vm64.Matrix4 get3DMatrix(double accumulatedTime) {
    final double targetYaw = -direction * 0.25;
    final double yaw = targetYaw + math.sin(accumulatedTime * 4.0) * 0.12;
    final double pitch = math.cos(accumulatedTime * 5.0) * 0.1;
    final double pulse = 1.0 + math.sin(accumulatedTime * 6.0) * 0.04;
    return vm64.Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateY(yaw)
      ..rotateX(pitch)
      ..scale(pulse, pulse);
  }
}

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import '../enemy_component.dart';

class CookieEnemy extends EnemyComponent {
  final double speedY;
  final double frequency;
  final double amplitude;
  final double baseShotChance;

  final double _xOriginal;

  CookieEnemy({
    required Vector2 position,
    this.speedY = 140.0,
    this.frequency = 4.0,
    this.amplitude = 50.0,
    this.baseShotChance = 0.07,
  }) : _xOriginal = position.x,
       super(
          position: position,
          size: Vector2(38.0, 38.0),
          pointsReward: 30,
          energyReward: 12.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFF8D6E63); // Cookie brown

  @override
  void update(double dt) {
    super.update(dt);

    // Continuous downward translation
    position.y += speedY * dt;

    // Sinusoidal horizontal oscillation
    position.x = _xOriginal + sin(accumulatedTime * frequency) * amplitude;
  }

  @override
  String get spriteAssetPath => 'cookie.png';

  @override
  vm64.Matrix4 get3DMatrix(double accumulatedTime) {
    // Cookie: gliding sinusoidal roll and swing
    final double roll = sin(accumulatedTime * 2.0) * 0.15;
    final double yaw = cos(accumulatedTime * frequency) * 0.3;
    final double pulse = 1.0 + cos(accumulatedTime * 4.0) * 0.03;
    return vm64.Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateZ(roll)
      ..rotateY(yaw)
      ..scale(pulse, pulse);
  }
}

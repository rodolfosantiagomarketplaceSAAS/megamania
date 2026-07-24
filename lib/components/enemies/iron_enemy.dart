import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import '../enemy_component.dart';

class IronEnemy extends EnemyComponent {
  final double speedX;
  final double incrementY;
  final double baseShotChance;

  double direction; // 1.0 for Right, -1.0 for Left

  IronEnemy({
    required Vector2 position,
    this.speedX = 140.0,
    this.incrementY = 36.0,
    this.direction = 1.0,
    this.baseShotChance = 0.15,
  }) : super(
          position: position,
          size: Vector2(42.0, 34.0),
          pointsReward: 70,
          energyReward: 18.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFF90A4AE); // Silver/grey

  @override
  void update(double dt) {
    super.update(dt);
    // Move horizontally (direction and descend managed collectively by WaveManager)
    position.x += speedX * direction * dt;

  }

  @override
  String get spriteAssetPath => 'iron.png';

  @override
  vm64.Matrix4 get3DMatrix(double accumulatedTime) {
    final double stomp = sin(accumulatedTime * 5.0);
    final double scaleY = stomp > 0 ? 1.0 - stomp * 0.15 : 1.0;
    final double baseScaleX = stomp > 0 ? 1.0 + stomp * 0.08 : 1.0;
    
    // Leans forward into its movement direction
    final double pitch = direction * 0.15;
    
    // Mirror the sprite based on movement direction using negative X scale
    final double finalScaleX = direction < 0.0 ? -baseScaleX : baseScaleX;
    
    return vm64.Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateY(pitch)
      ..scale(finalScaleX, scaleY);
  }
}

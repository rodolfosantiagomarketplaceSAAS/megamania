import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import '../enemy_component.dart';

class BowtieEnemy extends EnemyComponent {
  final double speedY;
  final double frequency;
  final double amplitude;
  final double baseShotChance;

  final double _xOriginal;

  BowtieEnemy({
    required Vector2 position,
    this.speedY = 170.0,
    this.frequency = 4.5,
    this.amplitude = 60.0,
    this.baseShotChance = 0.18,
  }) : _xOriginal = position.x,
       super(
          position: position,
          size: Vector2(44.0, 26.0),
          pointsReward: 80,
          energyReward: 20.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFFFF5722); // Bowtie Orange/Red

  @override
  void update(double dt) {
    super.update(dt);

    // Continuous downward translation
    position.y += speedY * dt;

    // Sinusoidal horizontal oscillation
    position.x = _xOriginal + sin(accumulatedTime * frequency) * amplitude;
  }

  @override
  String get spriteAssetPath => 'bowtie.png';

  @override
  vm64.Matrix4 get3DMatrix(double accumulatedTime) {
    // Party Bowtie: twisting 3D propeller rotation
    final double twist = sin(accumulatedTime * 6.0) * 0.5;
    final double pitch = cos(accumulatedTime * 3.0) * 0.15;
    return vm64.Matrix4.identity()
      ..setEntry(3, 2, 0.0018)
      ..rotateY(twist)
      ..rotateX(pitch);
  }
}

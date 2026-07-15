import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprite = await gameRef.loadSprite('bowtie.png');
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      _sprite!.render(canvas, position: Vector2.zero(), size: size);
    } else {
      super.render(canvas);
    }
  }
}

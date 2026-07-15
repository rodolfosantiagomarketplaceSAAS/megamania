import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprite = await gameRef.loadSprite('cookie.png');
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(accumulatedTime * 1.8);
      canvas.translate(-size.x / 2, -size.y / 2);
      _sprite!.render(canvas, position: Vector2.zero(), size: size);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }
}

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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
          size: Vector2(44.0, 36.0),
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

    final double halfWidth = size.x / 2;

    // Move horizontally
    position.x += speedX * direction * dt;

    // Check borders and bounce/descend
    if (direction < 0.0 && position.x <= halfWidth) {
      position.x = halfWidth;
      direction = 1.0;
      position.y += incrementY;
    } else if (direction > 0.0 && position.x >= gameRef.canvasSize.x - halfWidth) {
      position.x = gameRef.canvasSize.x - halfWidth;
      direction = -1.0;
      position.y += incrementY;
    }
  }

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprite = await gameRef.loadSprite('hamburger.png');
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

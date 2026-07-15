import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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

    final double halfWidth = size.x / 2;

    // Linear horizontal translation
    position.x += speedX * direction * dt;

    // Boundary check and bounce behavior
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
    _sprite = await gameRef.loadSprite('iron.png');
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      canvas.save();
      // Mirror the sprite based on movement direction
      if (direction < 0) {
        canvas.translate(size.x, 0);
        canvas.scale(-1, 1);
      }
      _sprite!.render(canvas, position: Vector2.zero(), size: size);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }
}

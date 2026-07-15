import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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
    try {
      _sprite = await gameRef.loadSprite('tire.png');
    } catch (_) {}
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(accumulatedTime * 6.0 * direction);
      canvas.translate(-size.x / 2, -size.y / 2);
      _sprite!.render(canvas, position: Vector2.zero(), size: size);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }
}

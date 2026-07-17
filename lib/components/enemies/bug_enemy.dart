import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      _sprite = await gameRef.loadSprite('bug.png');
    } catch (_) {}
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

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

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      _sprite = await gameRef.loadSprite('hamburger.png');
    } catch (_) {}
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) {
      canvas.save();

      // Translate canvas to the center of the component to rotate and scale relative to center
      canvas.translate(size.x / 2, size.y / 2);

      // Smooth 3D animation matrices:
      // Y-axis rotation (Yaw): tilts slightly into the movement direction + subtle wobble
      final double targetYaw = -direction * 0.25;
      final double yaw = targetYaw + math.sin(accumulatedTime * 4.0) * 0.12;

      // X-axis rotation (Pitch): breathing/wobbling effect
      final double pitch = math.cos(accumulatedTime * 5.0) * 0.1;

      // Breathing scale pulse
      final double pulse = 1.0 + math.sin(accumulatedTime * 6.0) * 0.04;

      final vm64.Matrix4 matrix = vm64.Matrix4.identity()
        ..setEntry(3, 2, 0.0018) // Apply perspective depth factor
        ..rotateY(yaw)
        ..rotateX(pitch)
        ..scale(pulse, pulse);

      canvas.transform(matrix.storage);

      // Translate back and render the sprite
      canvas.translate(-size.x / 2, -size.y / 2);
      _sprite!.render(canvas, position: Vector2.zero(), size: size);

      canvas.restore();
    } else {
      super.render(canvas);
    }
  }
}

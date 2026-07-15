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

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();

    final double w = size.x;
    final double h = size.y;
    final double radius = w / 2;

    canvas.translate(radius, radius);

    // Cookie rotation animation
    final double rotationAngle = accumulatedTime * 1.8;
    canvas.rotate(rotationAngle);

    // 1. Draw Cookie Base (Golden-brown circle)
    final Paint cookiePaint = Paint()..color = const Color(0xFFD7CCC8);
    canvas.drawCircle(Offset.zero, radius, cookiePaint);

    // 2. Draw Cookie Border (Slightly darker bite marks/texture)
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, radius - 1.0, borderPaint);

    // 3. Draw Chocolate Chips (Dark brown circles)
    final Paint chipPaint = Paint()..color = const Color(0xFF3E2723);
    
    // Position of chocolate chips relative to center
    final List<Offset> chips = [
      const Offset(-8.0, -8.0),
      const Offset(6.0, -10.0),
      const Offset(-2.0, 0.0),
      const Offset(8.0, 6.0),
      const Offset(-8.0, 8.0),
      const Offset(0.0, -9.0),
      const Offset(-9.0, 0.0),
    ];

    for (final chip in chips) {
      canvas.drawCircle(chip, 2.5, chipPaint);
    }

    canvas.restore();
  }
}

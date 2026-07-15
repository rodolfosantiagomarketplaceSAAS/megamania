import 'dart:math';
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();

    final double w = size.x;
    final double h = size.y;

    // 1. Antennae (Sinusoidal wiggle animation)
    final Paint linePaint = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double wiggle = sin(accumulatedTime * 15.0) * 4.0;
    canvas.drawLine(Offset(w * 0.35, h * 0.2), Offset(w * 0.2 + wiggle, 0), linePaint);
    canvas.drawLine(Offset(w * 0.65, h * 0.2), Offset(w * 0.8 - wiggle, 0), linePaint);

    // 2. Insect legs (Static angled lines extending outwards)
    canvas.drawLine(Offset(w * 0.1, h * 0.4), Offset(-2.0, h * 0.3), linePaint);
    canvas.drawLine(Offset(w * 0.1, h * 0.6), Offset(-4.0, h * 0.6), linePaint);
    canvas.drawLine(Offset(w * 0.1, h * 0.8), Offset(-2.0, h * 0.9), linePaint);

    canvas.drawLine(Offset(w * 0.9, h * 0.4), Offset(w + 2.0, h * 0.3), linePaint);
    canvas.drawLine(Offset(w * 0.9, h * 0.6), Offset(w + 4.0, h * 0.6), linePaint);
    canvas.drawLine(Offset(w * 0.9, h * 0.8), Offset(w + 2.0, h * 0.9), linePaint);

    // 3. Main Outer Body shell (Glowing Green/Teal)
    final Paint bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF66BB6A), Color(0xFF00796B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.7, h * 0.75), bodyPaint);

    // 4. Glowing Red Eyes
    final Paint eyePaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawCircle(Offset(w * 0.38, h * 0.4), 2.5, eyePaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.4), 2.5, eyePaint);

    // 5. Wing Covers (Elytra lines)
    final Paint elytraPaint = Paint()
      ..color = const Color(0xFF004D40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(w * 0.5, h * 0.25), Offset(w * 0.5, h * 0.9), elytraPaint);

    canvas.restore();
  }
}

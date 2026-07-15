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

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();

    // 1. Draw Flapping Wings
    final Paint wingPaint = Paint()
      ..color = const Color(0xFF80DEEA)
      ..style = PaintingStyle.fill;

    // Wing flap angle calculated via sinusoidal wave
    final double flapOffset = sin(accumulatedTime * 12.0) * 8.0;

    // Left Wing
    final Path leftWing = Path()
      ..moveTo(0, size.y * 0.5)
      ..quadraticBezierTo(-size.x * 0.4, size.y * 0.1 + flapOffset, -size.x * 0.5, size.y * 0.3)
      ..quadraticBezierTo(-size.x * 0.3, size.y * 0.6, 0, size.y * 0.5)
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    // Right Wing
    final Path rightWing = Path()
      ..moveTo(size.x, size.y * 0.5)
      ..quadraticBezierTo(size.x * 1.4, size.y * 0.1 + flapOffset, size.x * 1.5, size.y * 0.3)
      ..quadraticBezierTo(size.x * 1.3, size.y * 0.6, size.x, size.y * 0.5)
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    // 2. Draw Hamburger Body
    final double w = size.x;
    final double h = size.y;

    // Top Bun (Curved orange-brown arc)
    final Paint topBunPaint = Paint()..color = const Color(0xFFD87040);
    canvas.drawArc(
      Rect.fromLTWH(0, h * 0.15, w, h * 0.4),
      pi,
      pi,
      true,
      topBunPaint,
    );

    // Sesame seeds on Top Bun
    final Paint seedPaint = Paint()..color = const Color(0xFFFFECB3);
    canvas.drawCircle(Offset(w * 0.3, h * 0.25), 1.2, seedPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.20), 1.2, seedPaint);
    canvas.drawCircle(Offset(w * 0.7, h * 0.25), 1.2, seedPaint);

    // Melted Cheese (Yellow triangle ribbon)
    final Paint cheesePaint = Paint()..color = const Color(0xFFFFD54F);
    final Path cheesePath = Path()
      ..moveTo(w * 0.1, h * 0.42)
      ..lineTo(w * 0.9, h * 0.42)
      ..lineTo(w * 0.75, h * 0.58)
      ..lineTo(w * 0.5, h * 0.45)
      ..lineTo(w * 0.25, h * 0.58)
      ..close();
    canvas.drawPath(cheesePath, cheesePaint);

    // Meat Patty (Dark brown rounded rectangle)
    final Paint pattyPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.45, w * 0.9, h * 0.25),
        const Radius.circular(3.0),
      ),
      pattyPaint,
    );

    // Bottom Bun (Flat orange-brown rounded base)
    final Paint bottomBunPaint = Paint()..color = const Color(0xFFD87040);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.7, w * 0.84, h * 0.15),
        const Radius.circular(2.0),
      ),
      bottomBunPaint,
    );

    canvas.restore();
  }
}

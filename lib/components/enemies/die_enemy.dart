import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../enemy_component.dart';

class DieEnemy extends EnemyComponent {
  final double speedY;
  final double speedX;
  final double baseShotChance;

  double directionX; // 1.0 for Right, -1.0 for Left

  DieEnemy({
    required Vector2 position,
    this.speedY = 80.0,
    this.speedX = 160.0,
    this.directionX = 1.0,
    this.baseShotChance = 0.12,
  }) : super(
          position: position,
          size: Vector2(38.0, 38.0),
          pointsReward: 60,
          energyReward: 16.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFFE040FB);

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

    // Visual micro-animation: slow rotation of the die
    final double rotationAngle = accumulatedTime * 1.5 * directionX;
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(rotationAngle);
    canvas.translate(-size.x / 2, -size.y / 2);

    final double w = size.x;
    final double h = size.y;
    final Rect dieRect = Rect.fromLTWH(0, 0, w, h);

    // Die Body (Futuristic neon violet/magenta linear gradient)
    final Paint bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFBA68C8), Color(0xFF4A148C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(dieRect);

    // Outer border stroke
    final Paint borderPaint = Paint()
      ..color = const Color(0xFFE040FB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(dieRect, const Radius.circular(6.0)),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(dieRect, const Radius.circular(6.0)),
      borderPaint,
    );

    // Draw Glowing Die Dots (representing the "5" face)
    final Paint dotPaint = Paint()..color = const Color(0xFF00FFFF);
    final Paint dotGlow = Paint()
      ..color = const Color(0x9900FFFF);
    try {
      dotGlow.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    } catch (_) {}

    final List<Offset> dotOffsets = [
      Offset(w * 0.25, h * 0.25), // Top Left
      Offset(w * 0.75, h * 0.25), // Top Right
      Offset(w * 0.50, h * 0.50), // Center
      Offset(w * 0.25, h * 0.75), // Bottom Left
      Offset(w * 0.75, h * 0.75), // Bottom Right
    ];

    for (final offset in dotOffsets) {
      canvas.drawCircle(offset, 3.5, dotGlow);
      canvas.drawCircle(offset, 2.2, dotPaint);
    }

    canvas.restore();
  }
}

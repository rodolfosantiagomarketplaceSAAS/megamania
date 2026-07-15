import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../enemy_component.dart';

class BlockEnemy extends EnemyComponent {
  final double speedY;
  final double speedX;
  final double baseShotChance;

  double directionX; // 1.0 for Right, -1.0 for Left

  BlockEnemy({
    required Vector2 position,
    this.speedY = 85.0,
    this.speedX = 180.0,
    this.directionX = 1.0,
    this.baseShotChance = 0.22,
  }) : super(
          position: position,
          size: Vector2(36.0, 36.0),
          pointsReward: 90,
          energyReward: 22.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFFFF007F); // Pink block explosion

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
    final Rect blockRect = Rect.fromLTWH(0, 0, w, h);

    // 1. Draw 3D Isometric Neon Cube
    // Background plate (Back/Bottom shadow face)
    final Paint shadowPaint = Paint()..color = const Color(0xFF001122);
    canvas.drawRect(blockRect, shadowPaint);

    // Main Face (Neon blue/pink gradient)
    final Paint facePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFFFF007F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(blockRect);
    
    canvas.drawRect(Rect.fromLTWH(2, 2, w - 4, h - 4), facePaint);

    // Inner 3D lines (Isometric illusion)
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Outer wireframe border
    canvas.drawRect(Rect.fromLTWH(2, 2, w - 4, h - 4), linePaint);

    // Isometric lines
    canvas.drawLine(Offset(2, 2), Offset(w * 0.35, h * 0.35), linePaint);
    canvas.drawLine(Offset(w - 2, 2), Offset(w * 0.65, h * 0.35), linePaint);
    canvas.drawLine(Offset(2, h - 2), Offset(w * 0.35, h * 0.65), linePaint);
    canvas.drawLine(Offset(w - 2, h - 2), Offset(w * 0.65, h * 0.65), linePaint);
    
    // Inner square
    canvas.drawRect(Rect.fromLTRB(w * 0.35, h * 0.35, w * 0.65, h * 0.65), linePaint);

    // Center glowing core
    final Paint corePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 3.0, corePaint);

    canvas.restore();
  }
}

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

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();

    // Mirror the sprite based on movement direction
    if (direction < 0) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }

    final double w = size.x;
    final double h = size.y;

    // 1. Draw Metallic Iron Soleplate (Bottom triangular flat part)
    final Paint soleplatePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFCFD8DC), Color(0xFF78909C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.7, w, h * 0.25));

    final Path soleplate = Path()
      ..moveTo(0, h * 0.95)
      ..lineTo(w * 0.8, h * 0.95)
      ..quadraticBezierTo(w, h * 0.95, w, h * 0.8)
      ..lineTo(w * 0.85, h * 0.7)
      ..lineTo(0, h * 0.7)
      ..close();
    canvas.drawPath(soleplate, soleplatePaint);

    // 2. Iron Body (Red/White plastic housing)
    final Paint bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE57373), Color(0xFFC62828)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.3, w * 0.8, h * 0.45));

    final Path body = Path()
      ..moveTo(0, h * 0.7)
      ..lineTo(w * 0.8, h * 0.7)
      ..quadraticBezierTo(w * 0.9, h * 0.7, w * 0.75, h * 0.45)
      ..lineTo(w * 0.2, h * 0.45)
      ..lineTo(0, h * 0.7)
      ..close();
    canvas.drawPath(body, bodyPaint);

    // 3. Handle (Arc over the top)
    final Paint handlePaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final Path handle = Path()
      ..moveTo(w * 0.15, h * 0.45)
      ..quadraticBezierTo(w * 0.4, h * 0.1, w * 0.65, h * 0.45);
    canvas.drawPath(handle, handlePaint);

    // 4. Glowing indicator light (heat sensor)
    final Paint lightPaint = Paint()..color = const Color(0xFFFFD54F);
    final Paint glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.5);
    try {
      glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    } catch (_) {}
    
    canvas.drawCircle(Offset(w * 0.45, h * 0.55), 2.5, glowPaint);
    canvas.drawCircle(Offset(w * 0.45, h * 0.55), 1.5, lightPaint);

    canvas.restore();
  }
}

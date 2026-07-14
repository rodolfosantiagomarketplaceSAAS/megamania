import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../enemy_component.dart';

class SiderealWheel extends EnemyComponent {
  final double speedY;
  final double speedX;
  
  double directionX; // 1.0 for Right, -1.0 for Left

  SiderealWheel({
    required Vector2 position,
    this.speedY = 85.0,
    this.speedX = 130.0,
    this.directionX = 1.0,
  }) : super(
          position: position,
          size: Vector2(40.0, 40.0),
          pointsReward: 200,
          energyReward: 20.0,
        );

  @override
  void update(double dt) {
    super.update(dt);

    final double halfWidth = size.x / 2;

    // Linear diagonal translation
    position.y += speedY * dt;
    position.x += speedX * directionX * dt;

    // Elastic reflection (bounce) on screen side borders
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

    final double radius = size.x / 2;
    canvas.translate(radius, radius);
    
    // Continuous rotation to simulate rolling
    final double rotationAngle = accumulatedTime * 6.0 * directionX;
    canvas.rotate(rotationAngle);

    // 1. Draw Outer Tire Rim (Dark slate/neon blue theme)
    final Paint tirePaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF37474F), Colors.black],
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawCircle(Offset.zero, radius, tirePaint);

    // 2. Draw Wheel Treads (spoke dashes on outer rim)
    final Paint treadPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final double angle = i * pi / 4;
      final double startX = (radius - 4) * cos(angle);
      final double startY = (radius - 4) * sin(angle);
      final double endX = radius * cos(angle);
      final double endY = radius * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), treadPaint);
    }

    // 3. Draw Inner Glowing Alloy Ring
    final Paint alloyPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, radius - 6.0, alloyPaint);

    // 4. Draw Center Cap / Spokes
    final Paint spokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;
    
    for (int i = 0; i < 4; i++) {
      final double angle = i * pi / 2;
      canvas.drawLine(
        Offset.zero,
        Offset((radius - 8.0) * cos(angle), (radius - 8.0) * sin(angle)),
        spokePaint,
      );
    }

    // Hub cap
    final Paint hubPaint = Paint()..color = const Color(0xFFFF007F);
    canvas.drawCircle(Offset.zero, 3.5, hubPaint);

    canvas.restore();
  }
}

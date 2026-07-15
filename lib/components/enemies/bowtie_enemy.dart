import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../enemy_component.dart';

class BowtieEnemy extends EnemyComponent {
  final double speedY;
  final double frequency;
  final double amplitude;
  final double baseShotChance;

  final double _xOriginal;

  BowtieEnemy({
    required Vector2 position,
    this.speedY = 170.0,
    this.frequency = 4.5,
    this.amplitude = 60.0,
    this.baseShotChance = 0.18,
  }) : _xOriginal = position.x,
       super(
          position: position,
          size: Vector2(44.0, 26.0),
          pointsReward: 80,
          energyReward: 20.0,
        );

  @override
  double get shotChance => baseShotChance;

  @override
  double get shotInterval => 1.0;

  @override
  Color get explosionColor => const Color(0xFFFF5722); // Bowtie Orange/Red

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

    // 1. Draw Left Wing (Triangle)
    final Paint wingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7043), Color(0xFFD84315)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, w * 0.45, h));

    final Path leftWing = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.45, h * 0.5)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    // 2. Draw Right Wing (Triangle)
    final Paint rightWingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD84315), Color(0xFFFF7043)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(w * 0.55, 0, w * 0.45, h));

    final Path rightWing = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.55, h * 0.5)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(rightWing, rightWingPaint);

    // 3. Draw Center Knot (Rounded Square)
    final Paint knotPaint = Paint()..color = const Color(0xFFFFCC80);
    final Paint knotBorder = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Rect knotRect = Rect.fromLTWH(w * 0.41, h * 0.25, w * 0.18, h * 0.5);
    canvas.drawRRect(RRect.fromRectAndRadius(knotRect, const Radius.circular(3.0)), knotPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(knotRect, const Radius.circular(3.0)), knotBorder);

    // 4. Knot Center Jewel / Glow dot
    final Paint jewelPaint = Paint()..color = const Color(0xFFFF2A2A);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 2.0, jewelPaint);

    canvas.restore();
  }
}

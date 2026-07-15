import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../game/megamania_game.dart';
import 'enemy_component.dart';
import 'laser.dart';

enum ShipState {
  idle,
  bankingLeft,
  bankingRight,
}

class PlayerShip extends PositionComponent 
    with HasGameRef<MegamaniaGame>, CollisionCallbacks {
  
  ShipState shipState = ShipState.idle;
  bool active = false;
  
  double _currentMoveInput = 0.0;
  
  // Shooting timer variables
  double _fireCooldown = 0.0;
  static const double fireInterval = 0.12; // Auto-fires every 120 milliseconds

  PlayerShip() : super(priority: 10);

  @override
  Future<void> onLoad() async {
    size = Vector2(52.0, 42.0);
    anchor = Anchor.center;
    
    // Add collision detection hitbox
    add(RectangleHitbox(
      size: Vector2(size.x * 0.9, size.y * 0.8),
      position: Vector2(size.x * 0.05, size.y * 0.1),
    ));
  }

  /// Resets position to bottom-center of the screen
  void resetPosition() {
    position = Vector2(gameRef.canvasSize.x / 2, gameRef.canvasSize.y - 70.0);
    shipState = ShipState.idle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!active || gameRef.state != GameState.playing) return;

    // Query active horizontal input (keyboard prioritised, fallback to drag)
    _currentMoveInput = gameRef.keyboardInputController.movementInput;
    if (_currentMoveInput == 0.0) {
      _currentMoveInput = gameRef.dragInputController.movementInput;
    }

    // Determine visual banking states based on movement direction
    if (_currentMoveInput < -0.1) {
      shipState = ShipState.bankingLeft;
    } else if (_currentMoveInput > 0.1) {
      shipState = ShipState.bankingRight;
    } else {
      shipState = ShipState.idle;
    }

    // Apply linear horizontal translation
    const double speed = 450.0; // pixels per second
    position.x += _currentMoveInput * speed * dt;

    // Hard X-axis boundaries clamping (clamping ship size to screen margins)
    final double halfWidth = size.x / 2;
    if (position.x < halfWidth) {
      position.x = halfWidth;
    } else if (position.x > gameRef.canvasSize.x - halfWidth) {
      position.x = gameRef.canvasSize.x - halfWidth;
    }

    // Query active firing input (keyboard spacebar or drag controller UI button)
    final bool isFiring = gameRef.keyboardInputController.isFiring ||
        gameRef.dragInputController.isFiring;

    // Handle weapon systems fire cooldowns
    final bool hasActiveLaser = gameRef.children.whereType<Laser>().any((l) => l.isPlayerLaser);
    _fireCooldown += dt;
    if (isFiring) {
      if (_fireCooldown >= fireInterval && !hasActiveLaser) {
        _fireCooldown = 0.0;
        _fireLasers();
      }
    } else {
      // Keeps the weapon ready to fire immediately when pressed
      if (_fireCooldown > fireInterval) {
        _fireCooldown = fireInterval;
      }
    }
  }

  void _fireLasers() {
    // Fires a single central laser that follows the ship's movement
    gameRef.add(Laser(
      position: position + Vector2(0.0, -size.y * 0.5),
      isPlayerLaser: true,
      offsetX: 0.0,
    ));

    try {
      gameRef.playLaser();
    } catch (e) {
      // Fail gracefully
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (!active) return;

    // Handle collision with enemies or enemy lasers
    if (other is EnemyComponent || (other is Laser && !other.isPlayerLaser)) {
      gameRef.loseLife();
      if (other is Laser) {
        other.removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    try {
      // Premium 3D banking/leaning effect: rotate and scale width around the ship center
      canvas.translate(size.x / 2, size.y / 2);
      if (shipState == ShipState.bankingLeft) {
        canvas.rotate(-0.08);     // Lean left
        canvas.scale(0.85, 1.0);  // 3D perspective roll compression
      } else if (shipState == ShipState.bankingRight) {
        canvas.rotate(0.08);      // Lean right
        canvas.scale(0.85, 1.0);  // 3D perspective roll compression
      }
      canvas.translate(-size.x / 2, -size.y / 2);

      final double w = size.x;
      final double h = size.y;
      final Rect bounds = Rect.fromLTWH(0, 0, w, h);

      if (gameRef.selectedShipType.value == ShipType.dreamCruiser) {
        // ==========================================
        // DREAM CRUISER (GC-001) - Yellow/Blue/Teal
        // ==========================================
        
        // 1. Draw dual engine thrust flames (under the ship)
        if (active) {
          final Paint flamePaint = Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFF00FFFF), Color(0xFF0088FF), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(Rect.fromLTWH(0, h * 0.8, w, h * 0.5));
            
          // Left Flame
          final Path leftFlame = Path()
            ..moveTo(w * 0.12, h * 0.9)
            ..lineTo(w * 0.21, h * 1.4)
            ..lineTo(w * 0.30, h * 0.9)
            ..close();
          canvas.drawPath(leftFlame, flamePaint);

          // Right Flame
          final Path rightFlame = Path()
            ..moveTo(w * 0.70, h * 0.9)
            ..lineTo(w * 0.79, h * 1.4)
            ..lineTo(w * 0.88, h * 0.9)
            ..close();
          canvas.drawPath(rightFlame, flamePaint);
          
          // Nozzle glows
          final Paint glowPaint = Paint()
            ..color = const Color(0xFF00E5FF).withOpacity(0.6);
          try {
            glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
          } catch (_) {}
          canvas.drawCircle(Offset(w * 0.21, h * 0.9), 6.0, glowPaint);
          canvas.drawCircle(Offset(w * 0.79, h * 0.9), 6.0, glowPaint);
        }

        // 2. Draw Blue Wings
        final Paint wingPaint = Paint()..color = const Color(0xFF1565C0);
        final Path wingPath = Path()
          ..moveTo(w * 0.1, h * 0.6)
          ..lineTo(w * 0.9, h * 0.6)
          ..lineTo(w * 0.95, h * 0.8)
          ..lineTo(w * 0.05, h * 0.8)
          ..close();
        canvas.drawPath(wingPath, wingPaint);

        // 3. Draw Engine Cylinders
        final Paint enginePaint = Paint()..color = const Color(0xFF78909C);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.62, w * 0.18, h * 0.3), const Radius.circular(3.0)),
          enginePaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.70, h * 0.62, w * 0.18, h * 0.3), const Radius.circular(3.0)),
          enginePaint,
        );

        // 4. Draw Main Fuselage (Yellow gradient)
        final Paint bodyPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFEE58), Color(0xFFF57F17)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds);

        final Path bodyPath = Path()
          ..moveTo(w * 0.5, 0)
          ..quadraticBezierTo(w * 0.72, h * 0.3, w * 0.72, h * 0.75)
          ..lineTo(w * 0.28, h * 0.75)
          ..quadraticBezierTo(w * 0.28, h * 0.3, w * 0.5, 0)
          ..close();
        canvas.drawPath(bodyPath, bodyPaint);

        // Yellow wing panels
        final Paint wingPanelPaint = Paint()..color = const Color(0xFFFFD54F);
        canvas.drawRect(Rect.fromLTWH(w * 0.06, h * 0.68, w * 0.12, h * 0.06), wingPanelPaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.82, h * 0.68, w * 0.12, h * 0.06), wingPanelPaint);

        // 5. Draw Glass Cockpit Dome (Teal neon gradient)
        final Paint cockpitPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Colors.white, Color(0xFF00E5FF), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(w * 0.35, h * 0.24, w * 0.3, h * 0.35));

        canvas.drawOval(
          Rect.fromLTWH(w * 0.35, h * 0.24, w * 0.3, h * 0.35),
          cockpitPaint,
        );

        // Cockpit glare line
        final Paint glarePaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawArc(
          Rect.fromLTWH(w * 0.37, h * 0.26, w * 0.26, h * 0.31),
          -pi * 0.8,
          pi * 0.5,
          false,
          glarePaint,
        );
      } else {
        // ==========================================
        // STARHAWK (GC-7) - Grey/Orange/Military
        // ==========================================
        
        // 1. Draw central engine thrust flames (orange/yellow/white)
        if (active) {
          final Paint flamePaint = Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFFFF3D00), Color(0xFFFFEA00), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(Rect.fromLTWH(0, h * 0.8, w, h * 0.5));

          // Left Center Flame
          final Path leftFlame = Path()
            ..moveTo(w * 0.38, h * 0.95)
            ..lineTo(w * 0.44, h * 1.45)
            ..lineTo(w * 0.50, h * 0.95)
            ..close();
          canvas.drawPath(leftFlame, flamePaint);

          // Right Center Flame
          final Path rightFlame = Path()
            ..moveTo(w * 0.50, h * 0.95)
            ..lineTo(w * 0.56, h * 1.45)
            ..lineTo(w * 0.62, h * 0.95)
            ..close();
          canvas.drawPath(rightFlame, flamePaint);

          // Thermal core glows
          final Paint glowPaint = Paint()
            ..color = const Color(0xFFFF9100).withOpacity(0.6);
          try {
            glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
          } catch (_) {}
          canvas.drawCircle(Offset(w * 0.44, h * 0.95), 5.0, glowPaint);
          canvas.drawCircle(Offset(w * 0.56, h * 0.95), 5.0, glowPaint);
        }

        // 2. Draw 4 Laser Barrels extending from wings (Grey rectangles)
        final Paint gunPaint = Paint()..color = const Color(0xFF546E7A);
        // Left guns
        canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.28, w * 0.03, h * 0.32), gunPaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.14, h * 0.32, w * 0.03, h * 0.28), gunPaint);
        // Right guns
        canvas.drawRect(Rect.fromLTWH(w * 0.83, h * 0.32, w * 0.03, h * 0.28), gunPaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.89, h * 0.28, w * 0.03, h * 0.32), gunPaint);

        // 3. Draw Angular Wings
        final Paint wingPaint = Paint()..color = const Color(0xFF263238);
        final Path wingPath = Path()
          ..moveTo(w * 0.2, h * 0.55)
          ..lineTo(w * 0.04, h * 0.65)
          ..lineTo(w * 0.06, h * 0.85)
          ..lineTo(w * 0.94, h * 0.85)
          ..lineTo(w * 0.96, h * 0.65)
          ..lineTo(w * 0.8, h * 0.55)
          ..close();
        canvas.drawPath(wingPath, wingPaint);

        // Orange Wing Trims
        final Paint trimPaint = Paint()..color = const Color(0xFFFF5722);
        final Path leftTrim = Path()
          ..moveTo(w * 0.12, h * 0.6)
          ..lineTo(w * 0.04, h * 0.65)
          ..lineTo(w * 0.06, h * 0.78)
          ..lineTo(w * 0.12, h * 0.74)
          ..close();
        canvas.drawPath(leftTrim, trimPaint);

        final Path rightTrim = Path()
          ..moveTo(w * 0.88, h * 0.6)
          ..lineTo(w * 0.96, h * 0.65)
          ..lineTo(w * 0.94, h * 0.78)
          ..lineTo(w * 0.88, h * 0.74)
          ..close();
        canvas.drawPath(rightTrim, trimPaint);

        // Emblem on left wing panel
        canvas.drawCircle(Offset(w * 0.22, h * 0.70), 4.5, trimPaint);

        // 4. Draw Main Fuselage (Dark charcoal grey gradient)
        final Paint bodyPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF37474F), Color(0xFF1c2833)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds);

        final Path bodyPath = Path()
          ..moveTo(w * 0.4, h * 0.2)
          ..lineTo(w * 0.6, h * 0.2)
          ..lineTo(w * 0.66, h * 0.88)
          ..lineTo(w * 0.34, h * 0.88)
          ..close();
        canvas.drawPath(bodyPath, bodyPaint);

        // 5. Draw Angular segmented cockpit (amber/orange glass)
        final Paint cockpitPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Colors.white, Color(0xFFFB8C00), Color(0xFFBF360C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(w * 0.40, h * 0.34, w * 0.2, h * 0.3));

        final Path cockpitPath = Path()
          ..moveTo(w * 0.5, h * 0.3)
          ..lineTo(w * 0.58, h * 0.46)
          ..lineTo(w * 0.56, h * 0.68)
          ..lineTo(w * 0.44, h * 0.68)
          ..lineTo(w * 0.42, h * 0.46)
          ..close();
        canvas.drawPath(cockpitPath, cockpitPaint);

        // Window divider lines for military industrial look
        final Paint framePaint = Paint()
          ..color = const Color(0xFF263238)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawLine(Offset(w * 0.5, h * 0.3), Offset(w * 0.5, h * 0.68), framePaint);
        canvas.drawLine(Offset(w * 0.42, h * 0.46), Offset(w * 0.58, h * 0.46), framePaint);
      }
    } finally {
      canvas.restore();
    }
  }
}

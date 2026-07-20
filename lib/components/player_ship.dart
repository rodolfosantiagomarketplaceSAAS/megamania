import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import '../game/megamania_game.dart';
import 'enemy_component.dart';
import 'laser.dart';
import 'meteor.dart';

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
  double accumulatedTime = 0.0;
  
  // Shooting timer variables
  double _fireCooldown = 0.0;
  static const double fireInterval = 0.5; // Shoot once every 0.5 seconds (half of 1.0s)

  Sprite? _shipSprite;

  PlayerShip() : super(priority: 10);

  @override
  Future<void> onLoad() async {
    size = Vector2(60.0, 90.0); // Respected the 2:3 aspect ratio of the 3D ship (increased size)
    anchor = Anchor.center;
    try {
      _shipSprite = await gameRef.loadSprite('player_ship.png');
    } catch (_) {}
    
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
    accumulatedTime = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!active || gameRef.state != GameState.playing) return;

    accumulatedTime += dt;

    // Query active horizontal input (keyboard prioritised, fallback to mobile touch/drag)
    _currentMoveInput = gameRef.keyboardInputController.movementInput;
    if (_currentMoveInput == 0.0) {
      _currentMoveInput = gameRef.mobileInputController.movementInput;
    }

    // Determine visual banking states based on movement direction
    if (_currentMoveInput < -0.1) {
      shipState = ShipState.bankingLeft;
    } else if (_currentMoveInput > 0.1) {
      shipState = ShipState.bankingRight;
    } else {
      shipState = ShipState.idle;
    }

    // Apply linear horizontal translation (skipped if direct positioning like mouse or direct touch drag is active)
    final bool isDirectPositioning = gameRef.keyboardInputController.useMouseInput ||
        (gameRef.showTouchControls.value && gameRef.mobileControlStyle.value == MobileControlStyle.drag);
    if (!isDirectPositioning) {
      const double speed = 450.0; // pixels per second
      position.x += _currentMoveInput * speed * dt;
    }

    // Hard X-axis boundaries clamping (clamping ship size to screen margins)
    final double halfWidth = size.x / 2;
    if (position.x < halfWidth) {
      position.x = halfWidth;
    } else if (position.x > gameRef.canvasSize.x - halfWidth) {
      position.x = gameRef.canvasSize.x - halfWidth;
    }

    // Query active firing input (keyboard spacebar or mobile controller UI button)
    final bool isFiring = gameRef.keyboardInputController.isFiring ||
        gameRef.mobileInputController.isFiring;

    // Handle weapon systems fire cooldowns
    _fireCooldown += dt;

    if (isFiring) {
      if (_fireCooldown >= fireInterval) {
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

    // Handle collision with enemies, enemy lasers, or meteors
    if (other is EnemyComponent || (other is Laser && !other.isPlayerLaser) || other is Meteor) {
      gameRef.loseLife();
      if (other is Laser) {
        other.removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_shipSprite != null) {
      canvas.save();
      try {
        // Translate canvas to the center of the component to rotate and scale relative to center
        canvas.translate(size.x / 2, size.y / 2);

        // Smooth 3D animation:
        // Z-axis Roll: roll based on horizontal move input
        final double roll = _currentMoveInput * 0.12; // tilt slightly when moving

        // Y-axis Yaw: tilt slightly into the movement direction + subtle idle wobble
        final double targetYaw = -_currentMoveInput * 0.28;
        final double yaw = targetYaw + math.sin(accumulatedTime * 3.5) * 0.05;

        // X-axis Pitch: idle forward/backward wobble + acceleration pitch
        final double pitch = math.cos(accumulatedTime * 4.5) * 0.04;

        // Subtle idle breathing scale
        final double pulse = 1.0 + math.sin(accumulatedTime * 5.0) * 0.02;

        final vm64.Matrix4 matrix = vm64.Matrix4.identity()
          ..setEntry(3, 2, 0.0015) // Apply perspective depth factor
          ..rotateZ(roll)
          ..rotateY(yaw)
          ..rotateX(pitch)
          ..scale(pulse, pulse);

        canvas.transform(matrix.storage);

        // Translate back and render the sprite
        canvas.translate(-size.x / 2, -size.y / 2);
        _shipSprite!.render(canvas, position: Vector2.zero(), size: size);
      } finally {
        canvas.restore();
      }
    } else {
      super.render(canvas);
    }
  }
}

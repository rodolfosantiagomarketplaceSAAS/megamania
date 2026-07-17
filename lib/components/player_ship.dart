import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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
  
  // Shooting timer variables
  double _fireCooldown = 0.0;
  static const double fireInterval = 0.12; // Auto-fires every 120 milliseconds

  // Burst firing logic (allows 3 shots in sequence, then 1s cooldown)
  int _burstShotsCount = 0;
  double _burstCooldownTimer = 0.0;
  double _timeSinceLastFire = 0.0;
  static const double burstCooldownDuration = 1.0;
  static const int maxBurstShots = 3;

  Sprite? _shipSprite;

  PlayerShip() : super(priority: 10);

  @override
  Future<void> onLoad() async {
    size = Vector2(56.0, 56.0);
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
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!active || gameRef.state != GameState.playing) return;

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

    // Query active firing input (keyboard spacebar or mobile controller UI button)
    final bool isFiring = gameRef.keyboardInputController.isFiring ||
        gameRef.mobileInputController.isFiring;

    // Handle weapon systems fire cooldowns
    _fireCooldown += dt;
    _timeSinceLastFire += dt;

    if (_burstCooldownTimer > 0.0) {
      _burstCooldownTimer -= dt;
      if (_burstCooldownTimer <= 0.0) {
        _burstShotsCount = 0;
      }
    }

    // Quality of life: Reset burst count if the player hasn't shot in 0.4 seconds
    if (_timeSinceLastFire >= 0.4 && _burstCooldownTimer <= 0.0) {
      _burstShotsCount = 0;
    }

    if (isFiring) {
      if (_burstCooldownTimer <= 0.0 && _burstShotsCount < maxBurstShots) {
        if (_fireCooldown >= fireInterval) {
          _fireCooldown = 0.0;
          _timeSinceLastFire = 0.0;
          _fireLasers();
          _burstShotsCount++;

          if (_burstShotsCount >= maxBurstShots) {
            _burstCooldownTimer = burstCooldownDuration;
          }
        }
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
    super.render(canvas);

    if (_shipSprite != null) {
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

        _shipSprite!.render(canvas, position: Vector2.zero(), size: size);
      } finally {
        canvas.restore();
      }
    }
  }
}

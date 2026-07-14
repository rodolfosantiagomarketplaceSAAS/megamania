import 'package:flutter/services.dart';

abstract class InputController {
  /// Returns a normalized value between -1.0 (full left) and 1.0 (full right)
  /// representing the horizontal movement direction.
  double get movementInput;

  /// Indicates if the ship is active and auto-firing.
  bool get isFiring;

  /// Updates the input state if necessary on every tick.
  void update(double dt);
}

/// Keyboard, Mouse, and Gamepad implementation for Web/Desktop.
class KeyboardInputController extends InputController {
  final Set<LogicalKeyboardKey> _keysPressed = {};

  // Gamepad analog stick and trigger states
  double axisInputX = 0.0;
  bool gamepadFiring = false;
  bool wasStartPressed = false;

  // Mouse movement and click states
  double mouseInputX = 0.0;
  bool mouseFiring = false;
  bool useMouseInput = false;

  @override
  double get movementInput {
    // Mouse positioning overrides other inputs if active
    if (useMouseInput) {
      return mouseInputX;
    }

    // Joystick analog input takes priority over keyboard if moved
    if (axisInputX.abs() > 0.0) {
      return axisInputX;
    }

    double move = 0.0;
    if (_keysPressed.contains(LogicalKeyboardKey.keyA) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      move -= 1.0;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyD) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      move += 1.0;
    }
    return move;
  }

  @override
  bool get isFiring =>
      _keysPressed.contains(LogicalKeyboardKey.space) || gamepadFiring || mouseFiring;

  /// Call this when a key event occurs.
  void onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Disengage mouse control only when movement keys are pressed
      if (event.logicalKey == LogicalKeyboardKey.keyA ||
          event.logicalKey == LogicalKeyboardKey.keyD ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        useMouseInput = false;
      }
      _keysPressed.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
    }
  }

  @override
  void update(double dt) {}
}

/// Mobile implementation utilizing relative drag calculations (no fixed joystick).
class DragInputController extends InputController {
  double _movementInput = 0.0;
  
  // Drag decay rate to slowly stop the ship if drag events cease
  static const double _decayRate = 8.0;

  @override
  double get movementInput => _movementInput;

  @override
  bool isFiring = false; // Set from the UI fire button

  /// Process drag delta. We divide the delta X by screen width and scale it
  /// to compute the Relative Drag Coefficient.
  void handleDragUpdate(double deltaX, double screenWidth) {
    if (screenWidth <= 0) return;
    
    // Scale factor to make drag responsive
    const double sensitivity = 8.0;
    
    _movementInput = (deltaX / screenWidth) * sensitivity;
    
    // Clamp output within [-1.0, 1.0] bounds
    if (_movementInput > 1.0) _movementInput = 1.0;
    if (_movementInput < -1.0) _movementInput = -1.0;
  }

  /// Reset the horizontal velocity coefficient when drag ends.
  void handleDragEnd() {
    _movementInput = 0.0;
  }

  @override
  void update(double dt) {
    // If there is no active input, decay the input to 0 quickly for responsiveness
    if (_movementInput != 0.0) {
      if (_movementInput > 0) {
        _movementInput -= _decayRate * dt;
        if (_movementInput < 0) _movementInput = 0;
      } else {
        _movementInput += _decayRate * dt;
        if (_movementInput > 0) _movementInput = 0;
      }
    }
  }
}

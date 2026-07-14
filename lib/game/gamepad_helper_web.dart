import 'dart:html' as html;
import 'megamania_game.dart';

class GamepadHelper {
  static void pollGamepads(MegamaniaGame game) {
    try {
      if (game.state != GameState.playing) return;

      final gamepads = html.window.navigator.getGamepads();
      if (gamepads == null) return;

      for (int i = 0; i < gamepads.length; i++) {
        final gp = gamepads[i];
        if (gp == null) continue;

        // Axis 0 is horizontal analog stick (left/right). Typically ranges from -1.0 (left) to 1.0 (right).
        // We check a deadzone of 0.15.
        if (gp.axes != null && gp.axes!.isNotEmpty) {
          final double axisX = gp.axes![0].toDouble();
          if (axisX.abs() > 0.15) {
            game.keyboardInputController.axisInputX = axisX;
            game.keyboardInputController.useMouseInput = false; // Gamepad movement disengages mouse control
          } else {
            game.keyboardInputController.axisInputX = 0.0;
          }
        }

        // Buttons mapping:
        // Standard mapping: button 0 is 'A' (fire), button 1 is 'B' (fire), etc.
        // Button 7 is RT (Right Trigger).
        if (gp.buttons != null && gp.buttons!.isNotEmpty) {
          bool isFiringPressed = false;
          // Check face buttons (A, B, X, Y) or triggers
          for (int b in [0, 1, 2, 3, 7]) {
            if (b < gp.buttons!.length) {
              final btn = gp.buttons![b];
              if (btn != null && btn.pressed == true) {
                isFiringPressed = true;
                break;
              }
            }
          }
          game.keyboardInputController.gamepadFiring = isFiringPressed;
        }

        // Pause button (Start button typically index 9)
        if (gp.buttons != null && gp.buttons!.length > 9) {
          final startBtn = gp.buttons![9];
          if (startBtn != null && startBtn.pressed == true) {
            // Debounce to prevent rapid toggling
            if (!game.keyboardInputController.wasStartPressed) {
              game.togglePause();
              game.keyboardInputController.wasStartPressed = true;
            }
          } else {
            game.keyboardInputController.wasStartPressed = false;
          }
        }
      }
    } catch (e) {
      // Gracefully prevent browser gamepad API errors (like SecurityError in iframe, or Cast errors) from freezing the game.
    }
  }
}

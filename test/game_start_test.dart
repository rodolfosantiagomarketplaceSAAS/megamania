import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:megamania/game/megamania_game.dart';
import 'package:flame/game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MegamaniaGame startGame with Starhawk and update/render test', () async {
    final game = MegamaniaGame();
    
    // Select Starhawk ship type
    game.selectedShipType.value = ShipType.starhawk;
    
    // Call onLoad to initialize components
    await game.onLoad();
    
    // Set size to simulate layout
    game.onGameResize(Vector2(800, 600));
    
    // Register mock overlays to prevent assertion errors in tests
    game.overlays.addEntry('MainMenu', (context, game) => Container());
    game.overlays.addEntry('GameOver', (context, game) => Container());
    game.overlays.addEntry('HUD', (context, game) => Container());
    
    // Call startGame
    game.startGame();
    
    expect(game.state, GameState.playing);
    expect(game.score, 0);
    expect(game.lives, 3);
    expect(game.wave, 1);
    expect(game.playerShip.active, true);
    expect(game.waveManager.active, true);
    
    // Run update cycles
    game.update(0.016);
    
    // Mock canvas to test render methods do not throw
    final canvas = Canvas(PictureRecorder());
    game.playerShip.render(canvas);
  });
}

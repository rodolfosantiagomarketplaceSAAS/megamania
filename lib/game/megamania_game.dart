import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../components/player_ship.dart';
import '../components/visual_effects.dart';
import '../components/meteor.dart';
import '../services/supabase_service.dart';
import 'gamepad_helper.dart';
import 'input_controller.dart';
import 'wave_manager.dart';

enum GameState {
  menu,
  playing,
  gameOver,
}

enum ShipType {
  dreamCruiser, // GC-001
  starhawk,     // GC-7
}

class MegamaniaGame extends FlameGame 
    with HasCollisionDetection, KeyboardEvents, DragCallbacks {
  
  // Game states
  GameState state = GameState.menu;
  int score = 0;
  int lives = 3;
  int wave = 1;
  double dreamEnergy = 100.0;

  // Camera Shake state
  double _shakeTimer = 0.0;
  double _shakeIntensity = 0.0;

  // Meteor Spawner state
  double _meteorTimer = 0.0;
  double _nextMeteorDelay = 12.0; // seconds before first meteor alert

  // Background Music state
  bool _isMusicPlaying = false;

  // Selected ship type
  final ValueNotifier<ShipType> selectedShipType = ValueNotifier<ShipType>(ShipType.dreamCruiser);

  // Optimized Audio Pools (nullable to prevent blocking onLoad)
  AudioPool? laserPool;
  AudioPool? explosionPool;
  AudioPool? hitPool;
  AudioPool? powerUpPool;
  AudioPool? clickPool;
  
  // Parameterized values
  final double maxDreamEnergy = 100.0;
  final double energyConsumptionRate = 6.0; // Energy points depleted per second
  
  // Controllers
  final KeyboardInputController keyboardInputController = KeyboardInputController();
  final DragInputController dragInputController = DragInputController();

  // Components
  final PlayerShip playerShip = PlayerShip();
  final WaveManager waveManager = WaveManager();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _initAudioPools();
    }

    // Load background image and add background component
    try {
      final Sprite backgroundSprite = await loadSprite('background.png');
      add(SpaceBackground(sprite: backgroundSprite));
    } catch (e) {
      debugPrint('Error loading background image: $e');
    }

    // Add moving starfield
    add(Starfield());

    // Core engine starts in menu state, overlays handle the start UI
    // We add the components, but keep them inactive until startGame is called.
    add(playerShip);
    add(waveManager);
    
    // Initially pause components
    playerShip.active = false;
    waveManager.active = false;
  }

  /// Initialize or reset the game play state
  void startGame() {
    debugPrint('--- startGame() started ---');
    score = 0;
    lives = 3;
    wave = 1;
    dreamEnergy = maxDreamEnergy;
    state = GameState.playing;
    _shakeTimer = 0.0;
    _shakeIntensity = 0.0;
    _meteorTimer = 0.0;
    _nextMeteorDelay = 12.0;
    
    // Reset components
    debugPrint('--- Resetting player ship ---');
    try {
      playerShip.resetPosition();
      debugPrint('--- Player ship reset successful ---');
    } catch (e, s) {
      debugPrint('--- ERROR in playerShip.resetPosition(): $e');
      debugPrint(s.toString());
    }
    playerShip.active = true;
    
    debugPrint('--- Resetting wave manager ---');
    try {
      waveManager.resetWave();
      debugPrint('--- Wave manager reset successful ---');
    } catch (e, s) {
      debugPrint('--- ERROR in waveManager.resetWave(): $e');
      debugPrint(s.toString());
    }
    waveManager.active = true;

    // Manage overlays
    debugPrint('--- Transitioning overlays ---');
    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    overlays.add('HUD');
    startMusic();
    debugPrint('--- startGame() finished successfully ---');
  }

  /// Triggered when the ship is hit or energy runs out
  void loseLife() {
    playHit();

    lives--;
    dreamEnergy = maxDreamEnergy;
    
    if (lives <= 0) {
      state = GameState.gameOver;
      playerShip.active = false;
      waveManager.active = false;
      
      overlays.remove('HUD');
      overlays.add('GameOver');
      stopMusic();
      
      // Save high score to Supabase asynchronously
      _saveScoreToBackend();
    } else {
      playerShip.resetPosition();
      waveManager.resetWave();
    }
  }

  /// Syncs player scores to Supabase if authenticated
  Future<void> _saveScoreToBackend() async {
    final userId = SupabaseService.instance.currentUserId;
    if (userId != null) {
      await SupabaseService.instance.savePlayerScore(userId, score, wave);
    }
  }

  /// Awards score and restores energy upon enemy destruction
  void awardKill(int points, double energyReward) {
    if (state != GameState.playing) return;
    
    score += points;
    dreamEnergy += energyReward;
    if (dreamEnergy > maxDreamEnergy) {
      dreamEnergy = maxDreamEnergy;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Decrement shake timer if active
    if (_shakeTimer > 0.0) {
      _shakeTimer -= dt;
      if (_shakeTimer <= 0.0) {
        _shakeTimer = 0.0;
        _shakeIntensity = 0.0;
      }
    }

    if (state == GameState.playing) {
      // Poll connected gamepads/joysticks
      GamepadHelper.pollGamepads(this);

      // Update inputs
      keyboardInputController.update(dt);
      dragInputController.update(dt);

      // Decrease Dream Energy over time
      dreamEnergy -= energyConsumptionRate * dt;
      if (dreamEnergy <= 0) {
        dreamEnergy = 0.0;
        loseLife();
      }

      // Update meteor spawn timer
      _meteorTimer += dt;
      if (_meteorTimer >= _nextMeteorDelay) {
        _meteorTimer = 0.0;
        _nextMeteorDelay = 12.0 + Random().nextDouble() * 8.0;

        final double margin = 60.0;
        final double randomX = margin + Random().nextDouble() * (canvasSize.x - margin * 2);
        add(MeteorAlert(targetX: randomX));
      }
    }
  }

  void shakeCamera({double duration = 0.20, double intensity = 4.5}) {
    _shakeTimer = duration;
    _shakeIntensity = intensity;
  }

  @override
  void render(Canvas canvas) {
    if (_shakeTimer > 0.0) {
      canvas.save();
      final double dx = (Random().nextDouble() - 0.5) * 2.0 * _shakeIntensity;
      final double dy = (Random().nextDouble() - 0.5) * 2.0 * _shakeIntensity;
      canvas.translate(dx, dy);
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }

  // Toggle pause overlay and freeze Flame engine
  void togglePause() {
    if (state != GameState.playing) return;

    if (overlays.isActive('Pause')) {
      overlays.remove('Pause');
      paused = false;
      try {
        FlameAudio.bgm.resume();
      } catch (_) {}
    } else {
      overlays.add('Pause');
      paused = true;
      try {
        FlameAudio.bgm.pause();
      } catch (_) {}
    }
    playClick();
  }

  // Intercept Keyboard Input
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (state == GameState.menu) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
            event.logicalKey == LogicalKeyboardKey.keyA) {
          if (selectedShipType.value != ShipType.dreamCruiser) {
            selectedShipType.value = ShipType.dreamCruiser;
            playClick();
          }
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
            event.logicalKey == LogicalKeyboardKey.keyD) {
          if (selectedShipType.value != ShipType.starhawk) {
            selectedShipType.value = ShipType.starhawk;
            playClick();
          }
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          playClick();
          startGame();
          return KeyEventResult.handled;
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.escape) {
        togglePause();
        return KeyEventResult.handled;
      }
    }
    keyboardInputController.onKeyEvent(event);
    return KeyEventResult.handled;
  }

  // Intercept Touch/Drag Input on Mobile
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (state == GameState.playing) {
      final screenHeight = canvasSize.y;
      final touchY = event.canvasEndPosition.y;
      
      // Capacitive input is active only on the bottom half of the screen
      if (touchY > screenHeight * 0.5) {
        dragInputController.handleDragUpdate(event.localDelta.x, canvasSize.x);
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    dragInputController.handleDragEnd();
  }

  double _lastMouseX = -1.0;

  // Handler for mouse cursor positioning
  void handleMousePosition(double localX) {
    if (state == GameState.playing && playerShip.active && !paused) {
      // Only switch to mouse control if the mouse has actually moved significantly (more than 2 pixels)
      if (_lastMouseX >= 0.0 && (localX - _lastMouseX).abs() > 2.0) {
        keyboardInputController.useMouseInput = true;
      }
      _lastMouseX = localX;

      if (keyboardInputController.useMouseInput) {
        final double minX = playerShip.size.x / 2;
        double maxX = canvasSize.x - minX;
        if (maxX < minX) {
          maxX = minX;
        }
        playerShip.position.x = localX.clamp(minX, maxX);
      }
    }
  }

  // Handler for mouse click firing
  void handleMouseClick(bool isPressed) {
    if (state == GameState.playing && !paused) {
      keyboardInputController.mouseFiring = isPressed;
    }
  }

  // Asynchronous non-blocking audio pool initialization
  Future<void> _initAudioPools() async {
    try {
      await FlameAudio.bgm.initialize();
      laserPool = await FlameAudio.createPool('laser.wav', minPlayers: 2, maxPlayers: 6);
      explosionPool = await FlameAudio.createPool('explosion.wav', minPlayers: 2, maxPlayers: 6);
      hitPool = await FlameAudio.createPool('player_hit.wav', minPlayers: 1, maxPlayers: 2);
      powerUpPool = await FlameAudio.createPool('power_up.wav', minPlayers: 1, maxPlayers: 2);
      clickPool = await FlameAudio.createPool('click.wav', minPlayers: 1, maxPlayers: 3);
    } catch (e) {
      debugPrint('Error creating audio pools: $e');
    }
  }

  void startMusic() {
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest) return;

    try {
      if (!_isMusicPlaying) {
        FlameAudio.bgm.play('background_music.mp3', volume: 0.4).catchError((e) {
          debugPrint('Error playing background music: $e');
        });
        _isMusicPlaying = true;
      }
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  void stopMusic() {
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest) return;

    try {
      FlameAudio.bgm.stop().catchError((e) {
        debugPrint('Error stopping background music: $e');
      });
      _isMusicPlaying = false;
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  // Safe sound player helper methods
  void playLaser() {
    laserPool?.start().catchError((e) {
      debugPrint('Error playing laser sound: $e');
    });
  }

  void playExplosion() {
    explosionPool?.start().catchError((e) {
      debugPrint('Error playing explosion sound: $e');
    });
  }

  void playHit() {
    hitPool?.start().catchError((e) {
      debugPrint('Error playing hit sound: $e');
    });
  }

  void playPowerUp() {
    powerUpPool?.start().catchError((e) {
      debugPrint('Error playing powerUp sound: $e');
    });
  }

  void playClick() {
    clickPool?.start().catchError((e) {
      debugPrint('Error playing click sound: $e');
    });
  }
}

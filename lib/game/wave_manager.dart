import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import '../components/enemy_component.dart';
import '../components/enemies/winged_hamburger.dart';
import '../components/enemies/cosmic_die.dart';
import '../components/enemies/sidereal_wheel.dart';
import 'megamania_game.dart';

class WaveManager extends Component with HasGameRef<MegamaniaGame> {
  bool active = false;
  
  int _enemiesToSpawn = 0;
  int _enemiesSpawned = 0;
  double _spawnTimer = 0.0;
  double _spawnInterval = 1.0;

  // Level transition status
  bool _inTransition = false;
  double _transitionTimer = 0.0;
  static const double transitionDelay = 2.2; // Seconds between levels

  /// Configures parameters for the current wave level
  void resetWave() {
    clearActiveEnemies();
    _inTransition = false;
    _transitionTimer = 0.0;
    _enemiesSpawned = 0;
    
    // Scale count: base of 8, adding 2 more enemies per level
    _enemiesToSpawn = 8 + (gameRef.wave * 2);
    
    // Scaled frequency of spawns: becomes quicker on subsequent waves
    _spawnInterval = (1.3 - (gameRef.wave * 0.08)).clamp(0.45, 1.6);
    _spawnTimer = 0.0;
  }

  /// Wipe all active enemies from the viewport
  void clearActiveEnemies() {
    final List<Component> toRemove = [];
    for (final child in gameRef.children) {
      if (child is EnemyComponent) {
        toRemove.add(child);
      }
    }
    for (final enemy in toRemove) {
      enemy.removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!active || gameRef.state != GameState.playing) return;

    if (_inTransition) {
      _transitionTimer += dt;
      if (_transitionTimer >= transitionDelay) {
        _inTransition = false;
        gameRef.wave++;
        resetWave();
      }
      return;
    }

    // Spawn logic
    if (_enemiesSpawned < _enemiesToSpawn) {
      _spawnTimer += dt;
      if (_spawnTimer >= _spawnInterval) {
        _spawnTimer = 0.0;
        _spawnEnemy();
      }
    } else {
      // Check if all spawned enemies are cleared to advance waves
      bool hasActiveEnemies = false;
      for (final child in gameRef.children) {
        if (child is EnemyComponent) {
          hasActiveEnemies = true;
          break;
        }
      }
      if (!hasActiveEnemies) {
        _inTransition = true;
        _transitionTimer = 0.0;
        
        // Award massive phase bonus
        gameRef.awardKill(300 * gameRef.wave, 35.0);

        try {
          gameRef.playPowerUp();
        } catch (e) {
          // Fail gracefully
        }
      }
    }
  }

  void _spawnEnemy() {
    _enemiesSpawned++;

    // Alternates enemies every 3 waves
    final int enemyType = (gameRef.wave - 1) % 3;
    final double screenWidth = gameRef.canvasSize.x;
    
    // Scale speed linearly with the wave number
    final double speedScale = 1.0 + (gameRef.wave - 1) * 0.12;

    EnemyComponent enemy;

    switch (enemyType) {
      case 0:
        // Winged Hamburger (Wave 1, 4, 7...)
        final double divisor = (screenWidth - 80.0).clamp(1.0, double.infinity);
        final double xPos = 40.0 + (_enemiesSpawned * 89.0) % divisor;
        enemy = WingedHamburger(
          position: Vector2(xPos, -30.0),
          speedY: 65.0 * speedScale,
          amplitude: 50.0 + (gameRef.wave * 2.0).clamp(0.0, 40.0),
          frequency: 3.5 + (gameRef.wave * 0.15).clamp(0.0, 2.5),
        );
        break;
      case 1:
        // Cosmic Die (Wave 2, 5, 8...)
        // Alternate entering from Left and Right edges at varied Y heights
        final bool isLeft = _enemiesSpawned % 2 == 0;
        final double startX = isLeft ? -30.0 : screenWidth + 30.0;
        final double startY = 40.0 + (_enemiesSpawned * 36.0) % 220.0;
        enemy = CosmicDie(
          position: Vector2(startX, startY),
          speedX: 150.0 * speedScale,
          direction: isLeft ? 1.0 : -1.0,
          incrementY: 26.0 + (gameRef.wave * 1.5).clamp(0.0, 14.0),
        );
        break;
      case 2:
      default:
        // Sidereal Wheel (Wave 3, 6, 9...)
        final double divisor = (screenWidth - 80.0).clamp(1.0, double.infinity);
        final double xPos = 40.0 + (_enemiesSpawned * 103.0) % divisor;
        final double direction = _enemiesSpawned % 2 == 0 ? 1.0 : -1.0;
        enemy = SiderealWheel(
          position: Vector2(xPos, -30.0),
          speedY: 75.0 * speedScale,
          speedX: 110.0 * speedScale,
          directionX: direction,
        );
        break;
    }

    gameRef.add(enemy);
  }

  /// Exposes whether a transition is happening to overlay widgets
  bool get inTransition => _inTransition;
}

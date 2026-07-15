import 'package:flame/components.dart';
import '../components/enemy_component.dart';
import '../components/enemies/hamburger_enemy.dart';
import '../components/enemies/cookie_enemy.dart';
import '../components/enemies/bug_enemy.dart';
import '../components/enemies/tire_enemy.dart';
import '../components/enemies/die_enemy.dart';
import '../components/enemies/iron_enemy.dart';
import '../components/enemies/bowtie_enemy.dart';
import '../components/enemies/block_enemy.dart';
import 'megamania_game.dart';

class WaveManager extends Component with HasGameRef<MegamaniaGame> {
  bool active = false;
  
  int _enemiesToSpawn = 0;
  int _enemiesSpawned = 0;

  // Level transition status
  bool _inTransition = false;
  double _transitionTimer = 0.0;
  static const double transitionDelay = 2.2; // Seconds between levels

  /// Configures parameters for the current wave level
  void resetWave() {
    clearActiveEnemies();
    _inTransition = false;
    _transitionTimer = 0.0;
    
    _spawnAllEnemies();
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

  void _spawnAllEnemies() {
    final int phaseType = (gameRef.wave - 1) % 8;
    final int cycle = (gameRef.wave - 1) ~/ 8;
    // Speed increases by 25% per full cycle (after phase 8)
    final double difficultyMultiplier = 1.0 + (cycle * 0.25);

    const int count = 12;
    _enemiesToSpawn = count;
    _enemiesSpawned = count;

    final double screenWidth = gameRef.canvasSize.x;
    final double margin = 40.0;
    final double availableWidth = screenWidth - (margin * 2);
    final double spacing = availableWidth / (count - 1);

    for (int i = 0; i < count; i++) {
      final double xPos = margin + i * spacing;
      // Start near the top
      final double yPos = 60.0;

      final EnemyComponent enemy = _createEnemy(phaseType, xPos, yPos, difficultyMultiplier, i);
      gameRef.add(enemy);
    }
  }

  EnemyComponent _createEnemy(int type, double x, double y, double multiplier, int index) {
    final double startDir = 1.0;
    final Vector2 startPos = Vector2(x, y);

    switch (type) {
      case 0:
        // Phase 1: Hamburger (Classic linear speed 120, bounce/descend, shot chance 5%)
        return HamburgerEnemy(
          position: startPos,
          speedX: 120.0 * multiplier,
          direction: startDir,
          baseShotChance: (0.05 * multiplier).clamp(0.0, 0.8),
        );
      case 1:
        // Phase 2: Cookie (Sinusoidal downward movement, speed 140, shot chance 7%)
        return CookieEnemy(
          position: startPos,
          speedY: 140.0 * multiplier,
          baseShotChance: (0.07 * multiplier).clamp(0.0, 0.8),
        );
      case 2:
        // Phase 3: Bug (Crisscross diagonal speed 150, shot chance 9%)
        return BugEnemy(
          position: startPos,
          speedY: 80.0 * multiplier,
          speedX: 150.0 * multiplier,
          directionX: index % 2 == 0 ? 1.0 : -1.0,
          baseShotChance: (0.09 * multiplier).clamp(0.0, 0.8),
        );
      case 3:
        // Phase 4: Tire (Linear speed 130, bounce/descend, shot chance 10%)
        return TireEnemy(
          position: startPos,
          speedX: 130.0 * multiplier,
          direction: startDir,
          baseShotChance: (0.10 * multiplier).clamp(0.0, 0.8),
        );
      case 4:
        // Phase 5: Die (Crisscross diagonal speed 160, shot chance 12%)
        return DieEnemy(
          position: startPos,
          speedY: 80.0 * multiplier,
          speedX: 160.0 * multiplier,
          directionX: index % 2 == 0 ? 1.0 : -1.0,
          baseShotChance: (0.12 * multiplier).clamp(0.0, 0.8),
        );
      case 5:
        // Phase 6: Iron (Linear speed 140, bounce/descend, shot chance 15%)
        return IronEnemy(
          position: startPos,
          speedX: 140.0 * multiplier,
          direction: startDir,
          baseShotChance: (0.15 * multiplier).clamp(0.0, 0.8),
        );
      case 6:
        // Phase 7: Bowtie (Sinusoidal downward movement, speed 170, shot chance 18%)
        return BowtieEnemy(
          position: startPos,
          speedY: 170.0 * multiplier,
          baseShotChance: (0.18 * multiplier).clamp(0.0, 0.8),
        );
      case 7:
      default:
        // Phase 8: Block (Crisscross diagonal speed 180, shot chance 22%)
        return BlockEnemy(
          position: startPos,
          speedY: 85.0 * multiplier,
          speedX: 180.0 * multiplier,
          directionX: index % 2 == 0 ? 1.0 : -1.0,
          baseShotChance: (0.22 * multiplier).clamp(0.0, 0.8),
        );
    }
  }

  /// Exposes whether a transition is happening to overlay widgets
  bool get inTransition => _inTransition;
}

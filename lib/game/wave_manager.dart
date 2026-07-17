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
import '../components/meteor.dart';
import 'megamania_game.dart';

class WaveManager extends Component with HasGameRef<MegamaniaGame> {
  bool active = false;
  
  double _descendCooldownTimer = 0.0;
  double _descendRemaining = 0.0; // Remaining distance for smooth vertical descent

  // Level transition status
  bool _inTransition = false;
  double _transitionTimer = 0.0;
  static const double transitionDelay = 2.2; // Seconds between levels

  // Flag to wait for Flame tree integration before verifying active enemies
  bool _waveJustSpawned = false;

  // Shared direction for block-movement enemies (Hamburger, Tire, Iron)
  double enemyDirection = 1.0;

  /// Configures parameters for the current wave level
  void resetWave() {
    clearActiveEnemies();
    _inTransition = false;
    _transitionTimer = 0.0;
    
    final int phaseType = (gameRef.wave - 1) % 8;
    // Phase 1 (Hamburger) starts moving from right to left (direction -1.0)
    enemyDirection = (phaseType == 0) ? -1.0 : 1.0;
    
    _waveJustSpawned = true;
    _descendCooldownTimer = 0.05; // Allow immediate descend if wall is hit (low cooldown for precision)
    _descendRemaining = 0.0;
    
    _spawnAllEnemies();
  }

  /// Wipe all active enemies, meteors, alerts, and particles from the viewport
  void clearActiveEnemies() {
    final List<Component> toRemove = [];
    for (final child in gameRef.children) {
      if (child is EnemyComponent || child is Meteor || child is MeteorAlert || child is TrailParticle) {
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

    // Track cooldown between block descends
    _descendCooldownTimer += dt;

    if (_inTransition) {
      _transitionTimer += dt;
      if (_transitionTimer >= transitionDelay) {
        _inTransition = false;
        gameRef.wave++;
        resetWave();
      }
      return;
    }

    if (_waveJustSpawned) {
      final hasEnemies = gameRef.children.any((c) => c is EnemyComponent);
      if (hasEnemies) {
        _waveJustSpawned = false;
      } else {
        return;
      }
    }

    // Check if all spawned enemies are cleared to advance waves
    final List<EnemyComponent> enemies = [];
    bool hasActiveEnemies = false;
    for (final child in gameRef.children) {
      if (child is EnemyComponent) {
        hasActiveEnemies = true;
        enemies.add(child);
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
    } else {
      // Handle collective border detection for block-movement enemies
      bool shouldDescend = false;
      double newDirection = enemyDirection;

      // Animate smooth Y descent
      if (_descendRemaining > 0.0) {
        final double step = 150.0 * dt; // Descent speed of 150 pixels per second
        final double actualStep = step > _descendRemaining ? _descendRemaining : step;
        _descendRemaining -= actualStep;

        for (final enemy in enemies) {
          if (enemy is HamburgerEnemy || enemy is TireEnemy || enemy is IronEnemy) {
            enemy.position.y += actualStep;
          }
        }
      }

      if (_descendCooldownTimer >= 0.05 && _descendRemaining <= 0.0) {
        for (final enemy in enemies) {
          if (enemy is HamburgerEnemy || enemy is TireEnemy || enemy is IronEnemy) {
            final double halfWidth = enemy.size.x / 2;
            if (enemyDirection > 0.0 && enemy.position.x >= gameRef.canvasSize.x - halfWidth) {
              shouldDescend = true;
              newDirection = -1.0;
              break;
            } else if (enemyDirection < 0.0 && enemy.position.x <= halfWidth) {
              shouldDescend = true;
              newDirection = 1.0;
              break;
            }
          }
        }
      }

      if (shouldDescend) {
        _descendCooldownTimer = 0.0; // reset cooldown
        enemyDirection = newDirection;
        _descendRemaining = 36.0; // Start smooth descent of 36 pixels
        for (final enemy in enemies) {
          if (enemy is HamburgerEnemy || enemy is TireEnemy || enemy is IronEnemy) {
            if (enemy is HamburgerEnemy) enemy.direction = newDirection;
            if (enemy is TireEnemy) enemy.direction = newDirection;
            if (enemy is IronEnemy) enemy.direction = newDirection;
          }
        }
      }

      // Handle collective bottom wrapping: if ANY enemy reaches near the bottom, shift all up together
      double maxEnemyY = 0.0;
      for (final enemy in enemies) {
        if (enemy.position.y > maxEnemyY) {
          maxEnemyY = enemy.position.y;
        }
      }

      final double wrapThreshold = gameRef.canvasSize.y;
      if (maxEnemyY > wrapThreshold) {
        final double dy = maxEnemyY - 60.0;
        if (dy > 0.0) {
          for (final enemy in enemies) {
            enemy.position.y -= dy;
          }
        }
      }
    }
  }

  void _spawnAllEnemies() {
    final int phaseType = (gameRef.wave - 1) % 8;
    final int cycle = (gameRef.wave - 1) ~/ 8;
    // Speed increases by 25% per full cycle (after phase 8)
    final double difficultyMultiplier = 1.0 + (cycle * 0.25);

    final double screenWidth = gameRef.canvasSize.x;
    final double margin = 80.0; // Increased margin to fit staggered grid safely inside walls
    final double availableWidth = screenWidth - (margin * 2);

    if (phaseType == 0) {
      // Phase 1: Staggered grid of 10 enemies (3 rows: 3-4-3)
      const int cols = 7;
      final double spacingX = availableWidth / (cols - 1);
      const double spacingY = 45.0; // Vertical spacing between rows

      // Column indices for each row
      final List<int> row0Cols = [1, 3, 5];
      final List<int> row1Cols = [0, 2, 4, 6];
      final List<int> row2Cols = [1, 3, 5];

      final List<List<int>> layout = [row0Cols, row1Cols, row2Cols];

      int index = 0;
      for (int r = 0; r < layout.length; r++) {
        for (final int c in layout[r]) {
          final double xPos = margin + c * spacingX;
          final double yPos = 60.0 + r * spacingY;

          final EnemyComponent enemy = _createEnemy(phaseType, xPos, yPos, difficultyMultiplier, index);
          gameRef.add(enemy);
          index++;
        }
      }
    } else {
      // Other phases: 1 row of 12 enemies
      const int count = 12;
      final double spacing = availableWidth / (count - 1);

      for (int i = 0; i < count; i++) {
        final double xPos = margin + i * spacing;
        // Start near the top
        final double yPos = 60.0;

        final EnemyComponent enemy = _createEnemy(phaseType, xPos, yPos, difficultyMultiplier, i);
        gameRef.add(enemy);
      }
    }
  }

  EnemyComponent _createEnemy(int type, double x, double y, double multiplier, int index) {
    final double startDir = enemyDirection;
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

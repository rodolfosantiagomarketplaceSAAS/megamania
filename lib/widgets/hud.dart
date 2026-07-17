import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/megamania_game.dart';

class HUD extends StatefulWidget {
  final MegamaniaGame game;

  const HUD({Key? key, required this.game}) : super(key: key);

  @override
  State<HUD> createState() => _HUDState();
}

class _HUDState extends State<HUD> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  bool _isFireButtonPressed = false;
  bool _isLeftPressed = false;
  bool _isRightPressed = false;

  @override
  void initState() {
    super.initState();
    // Synchronize UI rendering with the Flame engine's frame ticks (60fps)
    _ticker = createTicker((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final percentage = (game.dreamEnergy / game.maxDreamEnergy).clamp(0.0, 1.0);
    
    // Choose dynamic energy bar color based on percentage
    Color energyColor = const Color(0xFF00FFCC); // Neon Teal
    if (percentage < 0.2) {
      // Flash red rapidly when energy is critical
      final int ms = DateTime.now().millisecondsSinceEpoch;
      energyColor = (ms ~/ 150) % 2 == 0 ? const Color(0xFFFF2A55) : Colors.transparent;
    } else if (percentage < 0.5) {
      energyColor = const Color(0xFFFF9900); // Neon Orange
    }

    return SafeArea(
      child: Stack(
        children: [
          // TOP STATS BAR
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score Widget
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCORE',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '${game.score.toString().padLeft(6, '0')}',
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00E5FF),
                        shadows: [
                          const Shadow(
                            color: Color(0x9900E5FF),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Wave Info
                Column(
                  children: [
                    Text(
                      'WAVE',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      '${game.wave}',
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF007F),
                        shadows: [
                          const Shadow(
                            color: Color(0x99FF007F),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Pause Button
                GestureDetector(
                  onTap: () {
                    game.playClick();
                    game.togglePause();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.65),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00E5FF), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pause, size: 14, color: Color(0xFF00E5FF)),
                        const SizedBox(width: 4),
                        Text(
                          'PAUSE',
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00E5FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Remaining Lives
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SHIPS',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(left: 3.0),
                          child: Icon(
                            Icons.navigation,
                            size: 18,
                            color: index < game.lives 
                                ? const Color(0xFF00FFCC) 
                                : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // MID SCREEN WAVE TRANSITION OVERLAY
          if (game.waveManager.inTransition)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF007F), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x33FF007F),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'WAVE CLEAR',
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00FFCC),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PREPARING JUMP...',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // BOTTOM DREAM ENERGY METER
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'DREAM ENERGY',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    color: Colors.white60,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white30,
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 100),
                        widthFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              colors: [
                                energyColor,
                                energyColor.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: energyColor.withOpacity(0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // VIRTUAL D-PAD (Left/Right Buttons) - Only active during live gameplay if touch controls are enabled and style is buttons
          if (game.state == GameState.playing && 
              game.showTouchControls.value && 
              game.mobileControlStyle.value == MobileControlStyle.buttons)
            Positioned(
              bottom: 40,
              left: 32,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.55),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.8), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Left Button
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _isLeftPressed = true;
                        });
                        game.mobileInputController.setButtonInput(-1.0);
                      },
                      onTapUp: (_) {
                        setState(() {
                          _isLeftPressed = false;
                        });
                        game.mobileInputController.setButtonInput(0.0);
                      },
                      onTapCancel: () {
                        setState(() {
                          _isLeftPressed = false;
                        });
                        game.mobileInputController.setButtonInput(0.0);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isLeftPressed
                              ? const Color(0xFF00E5FF).withOpacity(0.3)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: _isLeftPressed ? const Color(0xFF00FFCC) : const Color(0xFF00E5FF),
                          size: 28,
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 44,
                      color: const Color(0xFF00E5FF).withOpacity(0.3),
                    ),
                    // Right Button
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _isRightPressed = true;
                        });
                        game.mobileInputController.setButtonInput(1.0);
                      },
                      onTapUp: (_) {
                        setState(() {
                          _isRightPressed = false;
                        });
                        game.mobileInputController.setButtonInput(0.0);
                      },
                      onTapCancel: () {
                        setState(() {
                          _isRightPressed = false;
                        });
                        game.mobileInputController.setButtonInput(0.0);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRightPressed
                              ? const Color(0xFF00E5FF).withOpacity(0.3)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: _isRightPressed ? const Color(0xFF00FFCC) : const Color(0xFF00E5FF),
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // VIRTUAL FIRE BUTTON (Only active during live gameplay if touch controls are enabled)
          if (game.state == GameState.playing && game.showTouchControls.value)
            Positioned(
              bottom: 40,
              right: 32,
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isFireButtonPressed = true;
                  });
                  game.mobileInputController.isFiring = true;
                },
                onTapUp: (_) {
                  setState(() {
                    _isFireButtonPressed = false;
                  });
                  game.mobileInputController.isFiring = false;
                },
                onTapCancel: () {
                  setState(() {
                    _isFireButtonPressed = false;
                  });
                  game.mobileInputController.isFiring = false;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: _isFireButtonPressed ? 66 : 72,
                  height: _isFireButtonPressed ? 66 : 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isFireButtonPressed
                        ? const Color(0xFFFF007F).withOpacity(0.3)
                        : const Color(0xFF0F172A).withOpacity(0.55),
                    border: Border.all(
                      color: _isFireButtonPressed
                          ? const Color(0xFF00FFCC) // Neon Teal when pressed
                          : const Color(0xFFFF007F), // Neon Pink when idle
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isFireButtonPressed
                            ? const Color(0xFF00FFCC).withOpacity(0.5)
                            : const Color(0xFFFF007F).withOpacity(0.4),
                        blurRadius: _isFireButtonPressed ? 18 : 12,
                        spreadRadius: _isFireButtonPressed ? 3 : 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.local_fire_department,
                      color: _isFireButtonPressed
                          ? const Color(0xFF00FFCC)
                          : const Color(0xFFFF007F),
                      size: _isFireButtonPressed ? 28 : 32,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

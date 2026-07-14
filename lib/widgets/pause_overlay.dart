import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/megamania_game.dart';

class PauseOverlay extends StatelessWidget {
  final MegamaniaGame game;

  const PauseOverlay({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54, // Semi-transparent black background overlay
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: const BoxConstraints(maxHeight: 280),
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.85), // Glassmorphic card
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FFCC), width: 2.0), // Neon teal border
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFCC).withOpacity(0.3),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Paused Title
              Text(
                'MISSION PAUSED',
                style: GoogleFonts.orbitron(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FFCC),
                  letterSpacing: 2,
                  shadows: [
                    const Shadow(
                      color: Color(0x9900FFCC),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Resume Button
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 22),
                label: Text(
                  'RESUME MISSION',
                  style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                onPressed: game.togglePause,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFCC),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 14),

              // Quit to Menu Button
              OutlinedButton.icon(
                icon: const Icon(Icons.exit_to_app, size: 18),
                label: Text(
                  'QUIT TO HANGAR',
                  style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                onPressed: () {
                  game.paused = false;
                  game.state = GameState.menu;
                  game.playerShip.active = false;
                  game.waveManager.active = false;
                  game.waveManager.clearActiveEnemies();
                  game.overlays.remove('Pause');
                  game.overlays.remove('HUD');
                  game.overlays.add('MainMenu');
                  game.playClick();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF007F), width: 1.5),
                  foregroundColor: const Color(0xFFFF007F),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/megamania_game.dart';

class PauseOverlay extends StatefulWidget {
  final MegamaniaGame game;

  const PauseOverlay({Key? key, required this.game}) : super(key: key);

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  @override
  void initState() {
    super.initState();
    widget.game.showTouchControls.addListener(_onControlsChanged);
    widget.game.mobileControlStyle.addListener(_onControlsChanged);
  }

  @override
  void dispose() {
    widget.game.showTouchControls.removeListener(_onControlsChanged);
    widget.game.mobileControlStyle.removeListener(_onControlsChanged);
    super.dispose();
  }

  void _onControlsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Scaffold(
      backgroundColor: Colors.black54, // Semi-transparent black background overlay
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24.0),
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Paused Title
              Text(
                'MISSION PAUSED',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
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
              const SizedBox(height: 18),

              // Configuração de Controles na Tela
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00FFCC).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.touch_app, color: Color(0xFF00FFCC), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'CONTROLES NA TELA',
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 28,
                          child: Switch.adaptive(
                            value: game.showTouchControls.value,
                            activeColor: const Color(0xFF00FFCC),
                            onChanged: (val) {
                              game.playClick();
                              game.showTouchControls.value = val;
                            },
                          ),
                        ),
                      ],
                    ),
                    if (game.showTouchControls.value) ...[
                      const Divider(color: Colors.white10, height: 12),
                      Text(
                        'ESTILO DE CONTROLE:',
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                game.mobileControlStyle.value = MobileControlStyle.buttons;
                                game.playClick();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: game.mobileControlStyle.value == MobileControlStyle.buttons
                                      ? const Color(0xFF00FFCC).withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: game.mobileControlStyle.value == MobileControlStyle.buttons
                                        ? const Color(0xFF00FFCC)
                                        : Colors.white10,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'BOTÕES D-PAD',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: game.mobileControlStyle.value == MobileControlStyle.buttons
                                          ? const Color(0xFF00FFCC)
                                          : Colors.white60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                game.mobileControlStyle.value = MobileControlStyle.drag;
                                game.playClick();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: game.mobileControlStyle.value == MobileControlStyle.drag
                                      ? const Color(0xFFFF007F).withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: game.mobileControlStyle.value == MobileControlStyle.drag
                                        ? const Color(0xFFFF007F)
                                        : Colors.white10,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'ARRASTAR TELA',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: game.mobileControlStyle.value == MobileControlStyle.drag
                                          ? const Color(0xFFFF007F)
                                          : Colors.white60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 12),

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

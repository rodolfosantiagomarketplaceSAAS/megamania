import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/megamania_game.dart';

class MainMenuOverlay extends StatefulWidget {
  final MegamaniaGame game;

  const MainMenuOverlay({Key? key, required this.game}) : super(key: key);

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  @override
  void initState() {
    super.initState();
    widget.game.selectedShipType.addListener(_onShipChanged);
  }

  @override
  void dispose() {
    widget.game.selectedShipType.removeListener(_onShipChanged);
    super.dispose();
  }

  void _onShipChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FFCC), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFCC).withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Retro-themed title
              Text(
                'MEGAMANIA',
                style: GoogleFonts.orbitron(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00FFCC),
                  letterSpacing: 4,
                  shadows: [
                    const Shadow(
                      color: Color(0xAA00FFCC),
                      blurRadius: 12.0,
                    ),
                  ],
                ),
              ),
              Text(
                'MODERN REMAKE',
                style: GoogleFonts.shareTechMono(
                  fontSize: 14,
                  color: const Color(0xFFFF007F),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 18),

              // Control Instructions Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTROLS:',
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.keyboard, color: Color(0xFF00E5FF), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Desktop: A/D or Arrow keys to move. Space to fire.',
                            style: GoogleFonts.shareTechMono(color: Colors.white60, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.touch_app, color: Color(0xFFFF007F), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mobile: Drag bottom to move. Tap FIRE button.',
                            style: GoogleFonts.shareTechMono(color: Colors.white60, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Ship Selector Panel
              Text(
                'SELECT PILOT SHIP:',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Dream Cruiser Selector Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        game.selectedShipType.value = ShipType.dreamCruiser;
                        game.playClick();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: game.selectedShipType.value == ShipType.dreamCruiser
                              ? const Color(0xFF1E293B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: game.selectedShipType.value == ShipType.dreamCruiser
                                ? const Color(0xFFFFD54F) // Yellow border
                                : Colors.white10,
                            width: 2,
                          ),
                          boxShadow: game.selectedShipType.value == ShipType.dreamCruiser
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFFD54F).withOpacity(0.2),
                                    blurRadius: 8,
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            // Mini ship vector representation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1565C0), // Blue wings
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 12,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFD54F), // Yellow body
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1565C0), // Blue wings
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'DREAM CRUISER',
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: game.selectedShipType.value == ShipType.dreamCruiser
                                    ? const Color(0xFFFFD54F)
                                    : Colors.white60,
                              ),
                            ),
                            Text(
                              'GC-001 (LIGHT)',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 9,
                                color: Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Starhawk Selector Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        game.selectedShipType.value = ShipType.starhawk;
                        game.playClick();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: game.selectedShipType.value == ShipType.starhawk
                              ? const Color(0xFF1E293B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: game.selectedShipType.value == ShipType.starhawk
                                ? const Color(0xFFFF5722) // Orange border
                                : Colors.white10,
                            width: 2,
                          ),
                          boxShadow: game.selectedShipType.value == ShipType.starhawk
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFF5722).withOpacity(0.2),
                                    blurRadius: 8,
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            // Mini ship vector representation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF546E7A),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF37474F),
                                    borderRadius: BorderRadius.all(Radius.circular(3)),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Container(
                                  width: 6,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF5722),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'STARHAWK',
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: game.selectedShipType.value == ShipType.starhawk
                                    ? const Color(0xFFFF5722)
                                    : Colors.white60,
                              ),
                            ),
                            Text(
                              'GC-7 (HEAVY)',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 9,
                                color: Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons
              ElevatedButton(
                onPressed: () {
                  game.playClick();
                  game.startGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF007F),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 5,
                  shadowColor: const Color(0xAAFF007F),
                ),
                child: Text(
                  'START MISSION',
                  style: GoogleFonts.orbitron(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () {
                  game.playClick();
                  game.overlays.remove('MainMenu');
                  game.overlays.add('Leaderboard');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00E5FF)),
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'GLOBAL LEADERBOARD',
                  style: GoogleFonts.orbitron(
                    fontSize: 13,
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

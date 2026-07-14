import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/megamania_game.dart';
import '../services/supabase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final MegamaniaGame game;

  const LeaderboardScreen({Key? key, required this.game}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = SupabaseService.instance.fetchTopScores(10);
  }

  Color _getPositionColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          constraints: const BoxConstraints(maxHeight: 560),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () {
                      game.playClick();
                      game.overlays.remove('Leaderboard');
                      if (game.lives <= 0) {
                        game.overlays.add('GameOver');
                      } else {
                        game.overlays.add('MainMenu');
                      }
                    },
                  ),
                  Text(
                    'GLOBAL LEADERBOARD',
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00E5FF),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 40), // Balanced spacing
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _leaderboardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
                        child: Text(
                          'FAILED TO LOAD LEADERBOARD',
                          style: GoogleFonts.shareTechMono(color: Colors.redAccent, fontSize: 16),
                        ),
                      );
                    }

                    final list = snapshot.data!;
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'NO SCORES SUBMITTED YET',
                          style: GoogleFonts.shareTechMono(color: Colors.white30, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final record = list[index];
                        final maxScore = record['max_score'] as int? ?? 0;
                        final highestWave = record['highest_wave'] as int? ?? 1;
                        
                        // Parse username safely from the joined profiles table
                        final profile = record['profiles'] as Map<String, dynamic>?;
                        final username = profile?['username'] as String? ?? 'Unknown Pilot';

                        final rankColor = _getPositionColor(index);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: index < 3 ? rankColor.withOpacity(0.2) : Colors.white12,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Rank index
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '#${index + 1}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: rankColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Pilot username
                              Expanded(
                                child: Text(
                                  username,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.shareTechMono(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              // Wave count
                              Text(
                                'WAVE $highestWave',
                                style: GoogleFonts.shareTechMono(
                                  fontSize: 12,
                                  color: Colors.white38,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // High score
                              Text(
                                '$maxScore',
                                style: GoogleFonts.orbitron(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00FFCC),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

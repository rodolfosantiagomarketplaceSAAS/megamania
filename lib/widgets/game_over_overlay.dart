import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../game/megamania_game.dart';
import '../services/supabase_service.dart';

class GameOverOverlay extends StatefulWidget {
  final MegamaniaGame game;

  const GameOverOverlay({Key? key, required this.game}) : super(key: key);

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isSaving = false;
  String? _errorMsg;
  bool _saved = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submitScore() async {
    final String nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      setState(() => _errorMsg = 'Nickname cannot be empty');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    try {
      // 1. Authenticate player anonymously via Supabase Auth
      final AuthResponse response = await Supabase.instance.client.auth.signInAnonymously();
      final User? user = response.user;
      
      if (user == null) {
        throw Exception('Authentication failed');
      }

      // 2. Create the profile record
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'username': nickname,
      });

      // 3. Save the leaderboard score
      await SupabaseService.instance.savePlayerScore(
        user.id,
        widget.game.score,
        widget.game.wave,
      );

      setState(() {
        _isSaving = false;
        _saved = true;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMsg = 'Error saving score. Nickname might be taken.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final bool isAuth = SupabaseService.instance.isAuthenticated || _saved;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxHeight: 520),
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF007F), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF007F).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GAME OVER',
                style: GoogleFonts.orbitron(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF007F),
                  letterSpacing: 3,
                  shadows: [
                    const Shadow(
                      color: Color(0xAAFF007F),
                      blurRadius: 12.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Score breakdown card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FINAL SCORE',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${game.score}',
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00FFCC),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Wave achieved
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WAVE REACHED',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${game.wave}',
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFC107),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Supabase sync interface
              if (!isAuth) ...[
                Text(
                  'SYNC TO GLOBAL LEADERBOARD',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    color: Colors.white30,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  maxLength: 12,
                  style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your nickname',
                    hintStyle: const TextStyle(color: Colors.white24),
                    counterText: '',
                    filled: true,
                    fillColor: Colors.black45,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF00FFCC)),
                    ),
                  ),
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _errorMsg!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          widget.game.playClick();
                          _submitScore();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFCC),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          'SUBMIT SCORE',
                          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                        ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF00FFCC), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'SCORE SYNCHRONIZED',
                      style: GoogleFonts.shareTechMono(
                        color: const Color(0xFF00FFCC),
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),

              // Bottom control buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        game.playClick();
                        game.overlays.remove('GameOver');
                        game.overlays.add('Leaderboard');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00E5FF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        'LEADERBOARD',
                        style: GoogleFonts.orbitron(
                          color: const Color(0xFF00E5FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        game.playClick();
                        game.startGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF007F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        'PLAY AGAIN',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

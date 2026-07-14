import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._internal();
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// Fetch top scores for the global leaderboard.
  /// Joins the `leaderboards` table with `profiles` to get player usernames.
  Future<List<Map<String, dynamic>>> fetchTopScores(int limit) async {
    try {
      final List<dynamic> response = await _client
          .from('leaderboards')
          .select('max_score, highest_wave, total_matches_played, profiles(username)')
          .order('max_score', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Return empty list on failure to avoid crashing the game loop
      return [];
    }
  }

  /// Saves the player score. Performs a check to only overwrite the personal record
  /// if the new score is higher, while incrementing total matches played.
  Future<void> savePlayerScore(String userId, int newScore, int waveReached) async {
    try {
      // 1. Check for existing record
      final List<dynamic> existing = await _client
          .from('leaderboards')
          .select('id, max_score, highest_wave, total_matches_played')
          .eq('profile_id', userId)
          .limit(1);

      if (existing.isEmpty) {
        // Create new record
        await _client.from('leaderboards').insert({
          'profile_id': userId,
          'max_score': newScore,
          'highest_wave': waveReached,
          'total_matches_played': 1,
          'last_updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        final record = existing.first as Map<String, dynamic>;
        final int currentMaxScore = record['max_score'] as int;
        final int currentHighestWave = record['highest_wave'] as int;
        final int totalMatches = record['total_matches_played'] as int;
        final int recordId = record['id'] as int;

        final int finalMaxScore = newScore > currentMaxScore ? newScore : currentMaxScore;
        final int finalHighestWave = waveReached > currentHighestWave ? waveReached : currentHighestWave;

        // Update record
        await _client.from('leaderboards').update({
          'max_score': finalMaxScore,
          'highest_wave': finalHighestWave,
          'total_matches_played': totalMatches + 1,
          'last_updated_at': DateTime.now().toIso8601String(),
        }).eq('id', recordId);
      }
    } catch (e) {
      // Handle or log error without crashing the visual game interface
    }
  }

  /// Helper to get current authenticated user's ID, if any.
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Helper to check if user is logged in
  bool get isAuthenticated => _client.auth.currentUser != null;
}

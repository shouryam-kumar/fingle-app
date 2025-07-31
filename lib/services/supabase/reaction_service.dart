import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/reaction_models.dart';

class ReactionService {
  static final _supabase = Supabase.instance.client;

  /// Toggle reaction on any content (video, post, comment)
  static Future<bool> toggleReaction({
    required String contentType, // 'video', 'post', 'comment'
    required String contentId,
    required ReactionType reactionType,
  }) async {
    try {
      final response = await _supabase.rpc('api_toggle_reaction', params: {
        'p_content_type': contentType,
        'p_content_id': contentId,
        'p_reaction_type': reactionType.name,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error toggling reaction: $e');
      return false;
    }
  }

  /// Get reactions for any content
  static Future<ReactionSummary> getReactions({
    required String contentType, // 'video', 'post', 'comment'
    required String contentId,
  }) async {
    try {
      final response = await _supabase.rpc('api_get_reactions', params: {
        'p_content_type': contentType,
        'p_content_id': contentId,
      });

      if (response != null && response['success'] == true) {
        final reactionsData = response['data'] as List;
        final reactions = reactionsData.map((data) => Reaction(
          id: data['id'],
          userId: data['user_id'],
          userName: data['user_name'] ?? 'Unknown',
          userAvatar: data['user_avatar'] ?? '',
          type: ReactionType.values.firstWhere(
            (type) => type.name == data['reaction_type'],
            orElse: () => ReactionType.like,
          ),
          createdAt: DateTime.parse(data['created_at']),
        )).toList();

        return ReactionSummary.fromReactions(reactions, _supabase.auth.currentUser?.id ?? '');
      }
      return const ReactionSummary(counts: {}, reactions: {}, userReaction: null, totalCount: 0);
    } catch (e) {
      print('Error fetching reactions: $e');
      return const ReactionSummary(counts: {}, reactions: {}, userReaction: null, totalCount: 0);
    }
  }

  /// Get popular reactions for trending analysis
  static Future<List<ReactionType>> getPopularReactions({
    String? contentType,
    int days = 7,
    int limit = 10,
  }) async {
    try {
      final response = await _supabase.rpc('api_get_popular_reactions', params: {
        if (contentType != null) 'p_content_type': contentType,
        'p_days': days,
        'p_limit': limit,
      });

      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        return data.map((item) => ReactionType.values.firstWhere(
          (type) => type.name == item['reaction_type'],
          orElse: () => ReactionType.like,
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching popular reactions: $e');
      return [];
    }
  }

  /// Get reaction statistics for a user
  static Future<Map<String, int>> getUserReactionStats(String userId) async {
    try {
      final response = await _supabase.rpc('api_get_user_reaction_stats', params: {
        'p_user_id': userId,
      });

      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        return data.map((key, value) => MapEntry(key, value as int));
      }
      return {};
    } catch (e) {
      print('Error fetching user reaction stats: $e');
      return {};
    }
  }

  /// Batch toggle multiple reactions (for bulk operations)
  static Future<Map<String, bool>> batchToggleReactions(
    List<Map<String, dynamic>> reactions,
  ) async {
    try {
      final response = await _supabase.rpc('api_batch_toggle_reactions', params: {
        'p_reactions': reactions,
      });

      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        return data.map((key, value) => MapEntry(key, value as bool));
      }
      return {};
    } catch (e) {
      print('Error batch toggling reactions: $e');
      return {};
    }
  }

  /// Remove all reactions by a user on specific content
  static Future<bool> removeAllUserReactions({
    required String contentType,
    required String contentId,
  }) async {
    try {
      final response = await _supabase.rpc('api_remove_user_reactions', params: {
        'p_content_type': contentType,
        'p_content_id': contentId,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error removing user reactions: $e');
      return false;
    }
  }

  /// Get reaction history for a user (for analytics)
  static Future<List<Reaction>> getUserReactionHistory({
    required String userId,
    String? contentType,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc('api_get_user_reaction_history', params: {
        'p_user_id': userId,
        if (contentType != null) 'p_content_type': contentType,
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        return data.map((item) => Reaction(
          id: item['id'],
          userId: item['user_id'],
          userName: item['user_name'] ?? 'Unknown',
          userAvatar: item['user_avatar'] ?? '',
          type: ReactionType.values.firstWhere(
            (type) => type.name == item['reaction_type'],
            orElse: () => ReactionType.like,
          ),
          createdAt: DateTime.parse(item['created_at']),
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user reaction history: $e');
      return [];
    }
  }
}
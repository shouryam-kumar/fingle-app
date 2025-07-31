import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/home_models.dart';
import '../../models/reaction_models.dart';
import 'reaction_service.dart';

class HomeFeedService {
  static final _supabase = Supabase.instance.client;

  /// Get unified home feed (posts + videos)
  static Future<List<FeedPost>> getHomeFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc('api_get_home_feed', params: {
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response != null && response['success'] == true) {
        final feedData = response['data'] as List;
        return feedData.map((postData) => _parseFeedPostFromJson(postData)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching home feed: $e');
      return [];
    }
  }

  /// Get trending topics
  static Future<List<TrendingTopic>> getTrendingTopics({
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('trending_topics')
          .select('*')
          .order('post_count', ascending: false)
          .limit(limit);

      return response.map((topicData) => _parseTrendingTopicFromJson(topicData)).toList();
    } catch (e) {
      print('Error fetching trending topics: $e');
      return [];
    }
  }

  /// Toggle reaction on a post
  static Future<bool> togglePostReaction(String postId, ReactionType reactionType) async {
    return await ReactionService.toggleReaction(
      contentType: 'post',
      contentId: postId,
      reactionType: reactionType,
    );
  }

  /// Get post reactions
  static Future<ReactionSummary> getPostReactions(String postId) async {
    return await ReactionService.getReactions(
      contentType: 'post',
      contentId: postId,
    );
  }

  /// Track post view
  static Future<bool> trackPostView(String postId) async {
    try {
      await _supabase.rpc('api_track_post_view', params: {
        'p_post_id': postId,
      });
      return true;
    } catch (e) {
      print('Error tracking post view: $e');
      return false;
    }
  }

  /// Add/remove post recommendation
  static Future<bool> togglePostRecommendation(String postId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      // Check if already recommended
      final existingRec = await _supabase
          .from('post_recommendations')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', currentUser.id)
          .limit(1);

      if (existingRec.isNotEmpty) {
        // Remove recommendation
        await _supabase
            .from('post_recommendations')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUser.id);
      } else {
        // Add recommendation
        await _supabase
            .from('post_recommendations')
            .insert({
              'post_id': postId,
              'user_id': currentUser.id,
              'created_at': DateTime.now().toIso8601String(),
            });
      }

      return true;
    } catch (e) {
      print('Error toggling post recommendation: $e');
      return false;
    }
  }

  /// Bookmark/unbookmark post
  static Future<bool> togglePostBookmark(String postId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      // Check if already bookmarked
      final existingBookmark = await _supabase
          .from('post_bookmarks')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', currentUser.id)
          .limit(1);

      if (existingBookmark.isNotEmpty) {
        // Remove bookmark
        await _supabase
            .from('post_bookmarks')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUser.id);
        return false; // Not bookmarked anymore
      } else {
        // Add bookmark
        await _supabase
            .from('post_bookmarks')
            .insert({
              'post_id': postId,
              'user_id': currentUser.id,
              'created_at': DateTime.now().toIso8601String(),
            });
        return true; // Now bookmarked
      }
    } catch (e) {
      print('Error toggling post bookmark: $e');
      return false;
    }
  }

  /// Parse FeedPost from JSON response
  static FeedPost _parseFeedPostFromJson(Map<String, dynamic> json) {
    // Parse post type
    final postTypeStr = json['post_type'] ?? 'photo';
    final postType = PostType.values.firstWhere(
      (type) => type.name == postTypeStr,
      orElse: () => PostType.photo,
    );

    // Parse media items
    List<MediaItem>? mediaItems;
    if (json['media_items'] != null) {
      final mediaList = json['media_items'] as List;
      mediaItems = mediaList.map((media) => MediaItem(
        url: media['url'] ?? '',
        type: media['type'] == 'video' ? MediaType.video : MediaType.image,
        aspectRatio: media['aspect_ratio'],
        thumbnail: media['thumbnail'],
        duration: media['duration'],
      )).toList();
    }

    // Parse canvas data
    CanvasPost? canvasData;
    if (json['canvas_data'] != null) {
      final canvas = json['canvas_data'];
      canvasData = CanvasPost(
        text: canvas['text'] ?? '',
        backgroundColor: canvas['background_color'],
        backgroundImageUrl: canvas['background_image_url'],
        fontFamily: canvas['font_family'],
        textColor: canvas['text_color'] != null 
          ? Color(int.parse(canvas['text_color'].substring(1), radix: 16) + 0xFF000000)
          : null,
      );
    }

    // Parse reaction summary
    final reactionsData = json['reactions'] ?? [];
    final reactions = (reactionsData as List).map((reactionData) => Reaction(
      id: reactionData['id'] ?? '',
      userId: reactionData['user_id'] ?? '',
      userName: reactionData['user_name'] ?? 'Unknown',
      userAvatar: reactionData['user_avatar'] ?? '',
      type: ReactionType.values.firstWhere(
        (type) => type.name == reactionData['reaction_type'],
        orElse: () => ReactionType.like,
      ),
      createdAt: DateTime.tryParse(reactionData['created_at'] ?? '') ?? DateTime.now(),
    )).toList();

    final reactionSummary = ReactionSummary.fromReactions(reactions, _supabase.auth.currentUser?.id ?? '');

    return FeedPost(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? json['creator_name'] ?? 'Unknown',
      userAvatar: json['user_avatar'] ?? json['creator_avatar'] ?? '',
      userVerified: json['user_verified'] ?? false,
      userOpenToMingle: json['user_open_to_mingle'] ?? false,
      content: json['content'] ?? json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['thumbnail_url'], // Backward compatibility
      timeAgo: _formatTimeAgo(DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now()),
      category: json['category'] ?? json['workout_type'] ?? 'General',
      likes: json['likes_count'] ?? 0,
      comments: json['comments_count'] ?? 0,
      shares: json['shares_count'] ?? 0,
      isLiked: reactionSummary.userReaction == ReactionType.like,
      isBookmarked: json['is_bookmarked'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      postType: postType,
      mediaItems: mediaItems,
      canvasData: canvasData,
      recommendations: json['recommendations_count'] ?? 0,
      isRecommended: json['is_recommended'] ?? false,
      reactionSummary: reactionSummary,
    );
  }

  /// Parse TrendingTopic from JSON response
  static TrendingTopic _parseTrendingTopicFromJson(Map<String, dynamic> json) {
    return TrendingTopic(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '💪',
      gradient: _getGradientFromString(json['gradient_type'] ?? 'purple'),
      postCount: json['post_count'] ?? 0,
    );
  }

  /// Get gradient from string identifier
  static Gradient _getGradientFromString(String gradientType) {
    switch (gradientType.toLowerCase()) {
      case 'purple':
        return const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]);
      case 'mint':
        return const LinearGradient(colors: [Color(0xFF00d2ff), Color(0xFF3a7bd5)]);
      case 'sunset':
        return const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]);
      case 'ocean':
        return const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]);
      default:
        return const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]);
    }
  }

  /// Format time ago string
  static String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
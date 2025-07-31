import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/video_models.dart';
import '../../models/user_model.dart' as app_models;
import '../../models/reaction_models.dart';

class VideoFeedService {
  static final _supabase = Supabase.instance.client;

  /// Get personalized video feed (for_you, following, trending)
  static Future<List<VideoPost>> getVideoFeed({
    required String feedType, // 'for_you', 'following', 'trending'
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc('api_get_video_feed', params: {
        'p_feed_type': feedType,
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response != null && response['success'] == true) {
        final videosData = response['data'] as List;
        return videosData.map((videoData) => _parseVideoPostFromJson(videoData)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching video feed: $e');
      return [];
    }
  }

  /// Get specific video by ID
  static Future<VideoPost?> getVideo(String videoId) async {
    try {
      final response = await _supabase
          .from('videos')
          .select('''
            *,
            creator:profiles!videos_creator_id_fkey(*),
            reactions:video_reactions(*),
            comments:video_comments(count)
          ''')
          .eq('id', videoId)
          .single();

      return _parseVideoPostFromJson(response);
    } catch (e) {
      print('Error fetching video: $e');
      return null;
    }
  }

  /// Toggle reaction on video
  static Future<bool> toggleVideoReaction(String videoId, ReactionType reactionType) async {
    try {
      final response = await _supabase.rpc('api_toggle_reaction', params: {
        'p_content_type': 'video',
        'p_content_id': videoId,
        'p_reaction_type': reactionType.name,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error toggling video reaction: $e');
      return false;
    }
  }

  /// Get video reactions
  static Future<ReactionSummary> getVideoReactions(String videoId) async {
    try {
      final response = await _supabase.rpc('api_get_reactions', params: {
        'p_content_type': 'video',
        'p_content_id': videoId,
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
      print('Error fetching video reactions: $e');
      return const ReactionSummary(counts: {}, reactions: {}, userReaction: null, totalCount: 0);
    }
  }

  /// Add video recommendation
  static Future<bool> addVideoRecommendation(String videoId) async {
    try {
      final response = await _supabase
          .from('video_recommendations')
          .insert({
            'video_id': videoId,
            'user_id': _supabase.auth.currentUser?.id,
            'created_at': DateTime.now().toIso8601String(),
          });

      return true;
    } catch (e) {
      print('Error adding video recommendation: $e');
      return false;
    }
  }

  /// Update video view
  static Future<bool> updateVideoView(String videoId) async {
    try {
      await _supabase.rpc('increment_video_views', params: {
        'video_id': videoId,
      });
      return true;
    } catch (e) {
      print('Error updating video view: $e');
      return false;
    }
  }

  /// Upload video (metadata only, file upload handled separately)
  static Future<String?> uploadVideoMetadata({
    required String videoUrl,
    required String thumbnailUrl,
    required String title,
    required String description,
    required List<String> tags,
    required String workoutType,
    required String difficulty,
    required int duration,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return null;

      final response = await _supabase
          .from('videos')
          .insert({
            'creator_id': currentUser.id,
            'video_url': videoUrl,
            'thumbnail_url': thumbnailUrl,
            'title': title,
            'description': description,
            'tags': tags,
            'workout_type': workoutType,
            'difficulty': difficulty,
            'duration': duration,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error uploading video metadata: $e');
      return null;
    }
  }

  /// Parse video post from JSON response
  static VideoPost _parseVideoPostFromJson(Map<String, dynamic> json) {
    // Parse creator
    final creatorData = json['creator'] ?? json['profiles'] ?? {};
    final creator = app_models.User(
      id: creatorData['id'] ?? '',
      username: creatorData['username'] ?? '',
      name: creatorData['full_name'] ?? creatorData['name'] ?? 'Unknown',
      age: creatorData['age'] ?? 25,
      bio: creatorData['bio'] ?? '',
      profilePic: creatorData['avatar_url'] ?? creatorData['profile_pic'] ?? '',
      coverImage: creatorData['cover_image'] ?? '',
      isVerified: creatorData['is_verified'] ?? false,
      isFollowing: false, // This would need a separate check
      joinedAt: DateTime.tryParse(creatorData['created_at'] ?? '') ?? DateTime.now(),
      interests: List<String>.from(creatorData['interests'] ?? []),
      followers: creatorData['followers_count'] ?? 0,
      following: creatorData['following_count'] ?? 0,
      posts: [], // Empty for video feed
      stats: app_models.UserStats(
        totalPosts: creatorData['posts_count'] ?? 0,
        followers: creatorData['followers_count'] ?? 0,
        following: creatorData['following_count'] ?? 0,
        totalViews: creatorData['total_views'] ?? 0,
      ),
      achievements: [],
    );

    // Parse reactions
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

    // Parse recommendations (simplified)
    final recommendations = <Recommendation>[];

    return VideoPost(
      id: json['id'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      creator: creator,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      workoutType: json['workout_type'] ?? '',
      difficulty: json['difficulty'] ?? '',
      duration: json['duration'] ?? 0,
      views: json['views'] ?? 0,
      shares: json['shares'] ?? 0,
      comments: json['comments_count'] ?? json['comments']?['count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isFollowing: false, // This would need a separate check
      reactionSummary: reactionSummary,
      recommendations: recommendations,
      isRecommended: false, // This would need a separate check
    );
  }
}
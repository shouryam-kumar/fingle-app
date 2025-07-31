import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/comment_models.dart';
import '../../models/user_model.dart' as app_models;
import '../../models/reaction_models.dart';
import 'reaction_service.dart';

class CommentsService {
  static final _supabase = Supabase.instance.client;

  /// Get comments for a video or post
  static Future<List<Comment>> getComments({
    required String contentType, // 'video' or 'post'
    required String contentId,
    String sortBy = 'newest', // 'newest', 'oldest', 'top'
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc('api_get_comments', params: {
        'p_content_type': contentType,
        'p_content_id': contentId,
        'p_sort_by': sortBy,
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response != null && response['success'] == true) {
        final commentsData = response['data'] as List;
        return commentsData.map((commentData) => _parseCommentFromJson(commentData)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  /// Create a new comment
  static Future<Comment?> createComment({
    required String contentType, // 'video' or 'post'
    required String contentId,
    required String content,
    String? parentCommentId, // For replies
  }) async {
    try {
      final response = await _supabase.rpc('api_create_comment', params: {
        'p_content_type': contentType,
        'p_content_id': contentId,
        'p_content': content,
        if (parentCommentId != null) 'p_parent_comment_id': parentCommentId,
      });

      if (response != null && response['success'] == true) {
        final commentData = response['data'];
        return _parseCommentFromJson(commentData);
      }
      return null;
    } catch (e) {
      print('Error creating comment: $e');
      return null;
    }
  }

  /// Update an existing comment
  static Future<Comment?> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final response = await _supabase.rpc('api_update_comment', params: {
        'p_comment_id': commentId,
        'p_content': content,
      });

      if (response != null && response['success'] == true) {
        final commentData = response['data'];
        return _parseCommentFromJson(commentData);
      }
      return null;
    } catch (e) {
      print('Error updating comment: $e');
      return null;
    }
  }

  /// Delete a comment
  static Future<bool> deleteComment({
    required String commentId,
  }) async {
    try {
      final response = await _supabase.rpc('api_delete_comment', params: {
        'p_comment_id': commentId,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  /// Toggle reaction on a comment
  static Future<bool> toggleCommentReaction({
    required String commentId,
    required ReactionType reactionType,
  }) async {
    return await ReactionService.toggleReaction(
      contentType: 'comment',
      contentId: commentId,
      reactionType: reactionType,
    );
  }

  /// Get comment reactions
  static Future<ReactionSummary> getCommentReactions(String commentId) async {
    return await ReactionService.getReactions(
      contentType: 'comment',
      contentId: commentId,
    );
  }

  /// Get current user info for comments
  static Future<app_models.User?> getCurrentUser() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return null;

      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', currentUser.id)
          .single();

      return app_models.User(
        id: response['id'],
        username: response['username'] ?? '',
        name: response['full_name'] ?? response['name'] ?? 'Unknown',
        age: response['age'] ?? 25,
        bio: response['bio'] ?? '',
        profilePic: response['avatar_url'] ?? response['profile_pic'] ?? '',
        coverImage: response['cover_image'] ?? '',
        isVerified: response['is_verified'] ?? false,
        isFollowing: false,
        joinedAt: DateTime.tryParse(response['created_at'] ?? '') ?? DateTime.now(),
        interests: List<String>.from(response['interests'] ?? []),
        followers: response['followers_count'] ?? 0,
        following: response['following_count'] ?? 0,
        posts: [],
        stats: app_models.UserStats(
          totalPosts: response['posts_count'] ?? 0,
          followers: response['followers_count'] ?? 0,
          following: response['following_count'] ?? 0,
          totalViews: response['total_views'] ?? 0,
        ),
        achievements: [],
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Parse comment from JSON response
  static Comment _parseCommentFromJson(Map<String, dynamic> json) {
    // Parse author
    final authorData = json['author'] ?? json['user'] ?? {};
    final author = app_models.User(
      id: authorData['id'] ?? json['user_id'] ?? '',
      username: authorData['username'] ?? '',
      name: authorData['full_name'] ?? authorData['name'] ?? 'Unknown',
      age: authorData['age'] ?? 25,
      bio: authorData['bio'] ?? '',
      profilePic: authorData['avatar_url'] ?? authorData['profile_pic'] ?? '',
      coverImage: authorData['cover_image'] ?? '',
      isVerified: authorData['is_verified'] ?? false,
      isFollowing: false,
      joinedAt: DateTime.tryParse(authorData['created_at'] ?? '') ?? DateTime.now(),
      interests: List<String>.from(authorData['interests'] ?? []),
      followers: authorData['followers_count'] ?? 0,
      following: authorData['following_count'] ?? 0,
      posts: [],
      stats: app_models.UserStats(
        totalPosts: authorData['posts_count'] ?? 0,
        followers: authorData['followers_count'] ?? 0,
        following: authorData['following_count'] ?? 0,
        totalViews: authorData['total_views'] ?? 0,
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

    // Parse replies
    final repliesData = json['replies'] ?? [];
    final replies = (repliesData as List).map((replyData) => _parseCommentFromJson(replyData)).toList();

    final createdAt = DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now();

    return Comment(
      id: json['id'] ?? '',
      videoId: json['content_id'] ?? json['video_id'] ?? '',
      content: json['content'] ?? '',
      author: author,
      createdAt: createdAt,
      timeAgo: _formatTimeAgo(createdAt),
      isEdited: json['is_edited'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      replies: replies,
      reactionSummary: reactionSummary,
    );
  }

  /// Format time ago string
  static String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
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
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart' as app_models;

class UserProfileService {
  static final _supabase = Supabase.instance.client;

  /// Get user profile by ID
  static Future<app_models.User?> getUserProfile(String userId) async {
    try {
      final response = await _supabase.rpc('api_get_user_profile', params: {
        'p_user_id': userId,
      });

      if (response != null && response['success'] == true) {
        final userData = response['data'];
        return app_models.User.fromSupabaseJson(userData);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<bool> updateUserProfile({
    required String userId,
    String? username,
    String? bio,
    String? profilePic,
    String? coverImage,
    List<String>? interests,
  }) async {
    try {
      final response = await _supabase.rpc('api_update_user_profile', params: {
        'p_user_id': userId,
        if (username != null) 'p_username': username,
        if (bio != null) 'p_bio': bio,
        if (profilePic != null) 'p_profile_pic': profilePic,
        if (coverImage != null) 'p_cover_image': coverImage,
        if (interests != null) 'p_interests': interests,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Search users
  static Future<List<app_models.User>> searchUsers({
    String? query,
    List<String>? interests,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc('api_search_users', params: {
        if (query != null && query.isNotEmpty) 'p_query': query,
        if (interests != null && interests.isNotEmpty) 'p_interests': interests,
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response != null && response['success'] == true) {
        final usersData = response['data'] as List;
        return usersData.map((userData) => app_models.User.fromSupabaseJson(userData)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Get current user profile from auth
  static Future<app_models.User?> getCurrentUserProfile() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return null;

      return await getUserProfile(currentUser.id);
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }

  /// Follow user
  static Future<bool> followUser(String targetUserId) async {
    try {
      final response = await _supabase.rpc('api_follow_user', params: {
        'p_target_user_id': targetUserId,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  /// Unfollow user
  static Future<bool> unfollowUser(String targetUserId) async {
    try {
      final response = await _supabase.rpc('api_unfollow_user', params: {
        'p_target_user_id': targetUserId,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }

  /// Get followers list
  static Future<List<app_models.User>> getFollowers({
    String? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final targetUserId = userId ?? _supabase.auth.currentUser?.id;
      if (targetUserId == null) return [];

      final response = await _supabase.rpc('api_get_followers', params: {
        'p_user_id': targetUserId,
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response != null && response['success'] == true) {
        final followersData = response['data'] as List;
        return followersData.map((userData) => app_models.User.fromSupabaseJson(userData)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting followers: $e');
      return [];
    }
  }

  /// Get following list
  static Future<List<app_models.User>> getFollowing({
    String? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final targetUserId = userId ?? _supabase.auth.currentUser?.id;
      if (targetUserId == null) return [];

      final response = await _supabase.rpc('api_get_following', params: {
        'p_user_id': targetUserId,
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response != null && response['success'] == true) {
        final followingData = response['data'] as List;
        return followingData.map((userData) => app_models.User.fromSupabaseJson(userData)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting following: $e');
      return [];
    }
  }

  /// Check if current user is following target user
  static Future<bool> isFollowing(String targetUserId) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      final response = await _supabase
          .from('user_follows')
          .select('id')
          .eq('follower_id', currentUser.id)
          .eq('following_id', targetUserId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }
}
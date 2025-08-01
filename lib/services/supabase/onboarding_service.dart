import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/onboarding_models.dart';
import '../../core/config/supabase_config.dart';
import 'user_profile_service.dart';
import 'auth_service.dart';

class OnboardingService {
  static final _supabase = SupabaseConfig.client;

  /// Check if username is available
  static Future<bool> checkUsernameAvailability(String username) async {
    try {
      return await AuthService.isUsernameAvailable(username);
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  /// Upload user avatar to Supabase Storage
  static Future<String?> uploadAvatar(String imagePath) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final file = File(imagePath);
      final fileExt = imagePath.split('.').last.toLowerCase();
      final fileName = '${currentUser.id}_avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // Upload to avatars bucket
      await _supabase.storage
          .from('avatars')
          .upload(fileName, file);

      // Get public URL
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  /// Get available interest categories from backend
  static Future<List<InterestCategory>> getAvailableInterests() async {
    try {
      // Get trending topics from backend to use as interest suggestions
      final response = await _supabase
          .from('trending_topics')
          .select('id, name, emoji')
          .order('engagement_score', ascending: false)
          .limit(20);

      if (response != null && response is List) {
        final categories = <InterestCategory>[];
        
        for (final topic in response) {
          categories.add(InterestCategory(
            id: topic['name']?.toString().toLowerCase().replaceAll(' ', '_') ?? topic['id'],
            name: topic['name'] ?? 'Unknown',
            emoji: topic['emoji'] ?? '💪',
            description: 'Popular topic in the community',
          ));
        }
        
        // Add default categories if we don't have enough from backend
        final defaultCategories = InterestCategory.getDefaultCategories();
        final existingIds = categories.map((c) => c.id).toSet();
        
        for (final defaultCategory in defaultCategories) {
          if (!existingIds.contains(defaultCategory.id)) {
            categories.add(defaultCategory);
          }
        }
        
        return categories.take(12).toList(); // Limit to 12 categories
      }
      
      // Fallback to default categories
      return InterestCategory.getDefaultCategories();
    } catch (e) {
      print('Error fetching available interests: $e');
      // Return default categories on error
      return InterestCategory.getDefaultCategories();
    }
  }

  /// Complete onboarding and sync all data with backend
  static Future<bool> completeOnboarding(OnboardingData data) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Update user profile with onboarding data
      final profileUpdateSuccess = await UserProfileService.updateUserProfile(
        userId: currentUser.id,
        username: data.username,
        bio: data.bio,
        profilePic: data.avatarUrl,
        interests: data.selectedInterests,
      );

      if (!profileUpdateSuccess) {
        throw Exception('Failed to update user profile');
      }

      // Update user stats with activity level if provided
      if (data.activityLevel != null) {
        await _updateUserActivityLevel(currentUser.id, data.activityLevel!);
      }

      // Mark onboarding as completed in users table
      await _markOnboardingCompleted(currentUser.id);

      // Save onboarding analytics
      await _saveOnboardingAnalytics(currentUser.id, data);

      return true;
    } catch (e) {
      print('Error completing onboarding: $e');
      return false;
    }
  }

  /// Update user activity level in user_stats table
  static Future<void> _updateUserActivityLevel(String userId, ActivityLevel activityLevel) async {
    try {
      // First check if user_stats record exists
      final existingStats = await _supabase
          .from('user_stats')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingStats == null) {
        // Create new user_stats record
        await _supabase.from('user_stats').insert({
          'user_id': userId,
          'total_posts': 0,
          'followers': 0,
          'following': 0,
          'total_views': 0,
          'activity_level': activityLevel.name,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Update existing record
        await _supabase
            .from('user_stats')
            .update({
              'activity_level': activityLevel.name,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId);
      }
    } catch (e) {
      print('Error updating activity level: $e');
      // Don't throw - this is not critical for onboarding completion
    }
  }

  /// Mark onboarding as completed in users table
  static Future<void> _markOnboardingCompleted(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
            'onboarding_completed': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('auth_id', userId);
    } catch (e) {
      print('Error marking onboarding completed: $e');
      // Don't throw - this is not critical
    }
  }

  /// Save onboarding analytics for future improvements
  static Future<void> _saveOnboardingAnalytics(String userId, OnboardingData data) async {
    try {
      final completionTime = data.completedAt != null && data.startedAt != null
          ? data.completedAt!.difference(data.startedAt!).inSeconds
          : null;

      // This would ideally go to an analytics table, but for now we'll just log it
      final analyticsData = {
        'user_id': userId,
        'completed_at': data.completedAt?.toIso8601String(),
        'started_at': data.startedAt?.toIso8601String(),
        'completion_time_seconds': completionTime,
        'interests_selected': data.selectedInterests.length,
        'activity_level': data.activityLevel?.name,
        'permissions_granted': data.permissions.values.where((granted) => granted).length,
        'steps_completed': data.currentStep.index + 1,
      };

      print('Onboarding analytics: $analyticsData');
      
      // TODO: Save to analytics table when implemented
      // await _supabase.from('onboarding_analytics').insert(analyticsData);
    } catch (e) {
      print('Error saving onboarding analytics: $e');
      // Don't throw - analytics are not critical
    }
  }

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('onboarding_completed')
          .eq('auth_id', userId)
          .maybeSingle();

      return response?['onboarding_completed'] == true;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }

  /// Get onboarding completion rate for analytics
  static Future<double> getOnboardingCompletionRate() async {
    try {
      final totalUsersResponse = await _supabase
          .from('users')
          .select('*')
          .count(CountOption.exact);

      final completedUsersResponse = await _supabase
          .from('users')
          .select('*')
          .eq('onboarding_completed', true)
          .count(CountOption.exact);

      final totalUsers = totalUsersResponse.count;
      final completedUsers = completedUsersResponse.count;

      if (totalUsers > 0) {
        return completedUsers / totalUsers;
      }
      return 0.0;
    } catch (e) {
      print('Error getting completion rate: $e');
      return 0.0;
    }
  }

  /// Upload image from ImagePicker
  static Future<String?> uploadImageFromPicker(XFile imageFile) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last.toLowerCase();
      final fileName = '${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // Upload to images bucket
      await _supabase.storage
          .from('images')
          .uploadBinary(fileName, bytes);

      // Get public URL
      final publicUrl = _supabase.storage
          .from('images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading image from picker: $e');
      return null;
    }
  }

  /// Validate onboarding data before completion
  static bool validateOnboardingData(OnboardingData data) {
    // Check required fields
    if (data.fullName == null || data.fullName!.trim().isEmpty) {
      return false;
    }
    
    if (data.username == null || data.username!.trim().isEmpty) {
      return false;
    }
    
    // Username format validation
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(data.username!)) {
      return false;
    }
    
    if (data.username!.length < 3) {
      return false;
    }
    
    return true;
  }
}
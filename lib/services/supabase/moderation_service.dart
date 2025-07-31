import 'package:supabase_flutter/supabase_flutter.dart';

class ModerationService {
  static final _supabase = Supabase.instance.client;

  /// Report content for moderation review
  static Future<bool> reportContent({
    required String contentId,
    required String contentType, // 'video_post', 'feed_post', 'comment', 'story', 'user'
    required String reason, // 'spam', 'harassment', 'inappropriate_content', etc.
    String? description,
  }) async {
    try {
      final response = await _supabase.rpc('api_report_content', params: {
        'p_content_id': contentId,
        'p_content_type': contentType,
        'p_reason': reason,
        if (description != null) 'p_description': description,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error reporting content: $e');
      return false;
    }
  }

  /// Block or unblock a user
  static Future<bool?> toggleUserBlock({
    required String userId,
    String? reason,
  }) async {
    try {
      final response = await _supabase.rpc('api_toggle_user_block', params: {
        'p_user_id': userId,
        if (reason != null) 'p_reason': reason,
      });

      if (response != null && response['success'] == true) {
        return response['data']['is_blocked'] as bool;
      }
      return null;
    } catch (e) {
      print('Error toggling user block: $e');
      return null;
    }
  }

  /// Get list of blocked users
  static Future<List<BlockedUser>> getBlockedUsers() async {
    try {
      final response = await _supabase.rpc('api_get_blocked_users');

      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        return data.map((userData) => BlockedUser.fromJson(userData)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting blocked users: $e');
      return [];
    }
  }

  /// Check if a user is blocked
  static Future<bool> isUserBlocked(String userId) async {
    try {
      final blockedUsers = await getBlockedUsers();
      return blockedUsers.any((user) => user.id == userId);
    } catch (e) {
      print('Error checking if user is blocked: $e');
      return false;
    }
  }

  /// Get user's privacy settings
  static Future<PrivacySettings?> getPrivacySettings() async {
    try {
      final response = await _supabase.rpc('api_get_privacy_settings');

      if (response != null && response['success'] == true) {
        return PrivacySettings.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error getting privacy settings: $e');
      return null;
    }
  }

  /// Update user's privacy settings
  static Future<bool> updatePrivacySettings({
    String? profileVisibility, // 'public', 'followers', 'private'
    String? allowMessagesFrom, // 'everyone', 'followers', 'no_one'
    bool? allowMentions,
    bool? allowTags,
    bool? showActivityStatus,
    bool? discoverableByEmail,
    bool? discoverableByPhone,
  }) async {
    try {
      final response = await _supabase.rpc('api_update_privacy_settings', params: {
        if (profileVisibility != null) 'p_profile_visibility': profileVisibility,
        if (allowMessagesFrom != null) 'p_allow_messages_from': allowMessagesFrom,
        if (allowMentions != null) 'p_allow_mentions': allowMentions,
        if (allowTags != null) 'p_allow_tags': allowTags,
        if (showActivityStatus != null) 'p_show_activity_status': showActivityStatus,
        if (discoverableByEmail != null) 'p_discoverable_by_email': discoverableByEmail,
        if (discoverableByPhone != null) 'p_discoverable_by_phone': discoverableByPhone,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error updating privacy settings: $e');
      return false;
    }
  }
}

/// Model for blocked user data
class BlockedUser {
  final String id;
  final String? username;
  final String name;
  final String? profilePic;
  final DateTime blockedAt;
  final String? reason;

  BlockedUser({
    required this.id,
    this.username,
    required this.name,
    this.profilePic,
    required this.blockedAt,
    this.reason,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'] ?? '',
      username: json['username'],
      name: json['name'] ?? 'Unknown',
      profilePic: json['profile_pic'],
      blockedAt: DateTime.tryParse(json['blocked_at'] ?? '') ?? DateTime.now(),
      reason: json['reason'],
    );
  }
}

/// Model for privacy settings
class PrivacySettings {
  final String profileVisibility;
  final String allowMessagesFrom;
  final bool allowMentions;
  final bool allowTags;
  final bool showActivityStatus;
  final bool discoverableByEmail;
  final bool discoverableByPhone;

  PrivacySettings({
    required this.profileVisibility,
    required this.allowMessagesFrom,
    required this.allowMentions,
    required this.allowTags,
    required this.showActivityStatus,
    required this.discoverableByEmail,
    required this.discoverableByPhone,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profileVisibility: json['profile_visibility'] ?? 'public',
      allowMessagesFrom: json['allow_messages_from'] ?? 'everyone',
      allowMentions: json['allow_mentions'] ?? true,
      allowTags: json['allow_tags'] ?? true,
      showActivityStatus: json['show_activity_status'] ?? true,
      discoverableByEmail: json['discoverable_by_email'] ?? false,
      discoverableByPhone: json['discoverable_by_phone'] ?? false,
    );
  }

  PrivacySettings copyWith({
    String? profileVisibility,
    String? allowMessagesFrom,
    bool? allowMentions,
    bool? allowTags,
    bool? showActivityStatus,
    bool? discoverableByEmail,
    bool? discoverableByPhone,
  }) {
    return PrivacySettings(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      allowMessagesFrom: allowMessagesFrom ?? this.allowMessagesFrom,
      allowMentions: allowMentions ?? this.allowMentions,
      allowTags: allowTags ?? this.allowTags,
      showActivityStatus: showActivityStatus ?? this.showActivityStatus,
      discoverableByEmail: discoverableByEmail ?? this.discoverableByEmail,
      discoverableByPhone: discoverableByPhone ?? this.discoverableByPhone,
    );
  }
}

/// Report reasons enum for content reporting
enum ReportReason {
  spam,
  harassment,
  inappropriateContent,
  misinformation,
  violence,
  hateSpeech,
  copyright,
  other;

  String get displayName {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.inappropriateContent:
        return 'Inappropriate Content';
      case ReportReason.misinformation:
        return 'Misinformation';
      case ReportReason.violence:
        return 'Violence';
      case ReportReason.hateSpeech:
        return 'Hate Speech';
      case ReportReason.copyright:
        return 'Copyright Violation';
      case ReportReason.other:
        return 'Other';
    }
  }

  String get value {
    switch (this) {
      case ReportReason.spam:
        return 'spam';
      case ReportReason.harassment:
        return 'harassment';
      case ReportReason.inappropriateContent:
        return 'inappropriate_content';
      case ReportReason.misinformation:
        return 'misinformation';
      case ReportReason.violence:
        return 'violence';
      case ReportReason.hateSpeech:
        return 'hate_speech';
      case ReportReason.copyright:
        return 'copyright';
      case ReportReason.other:
        return 'other';
    }
  }
}
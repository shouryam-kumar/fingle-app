import 'package:flutter/material.dart';
import 'reaction_models.dart';

enum PostType { photo, video, canvas, carousel, videoReel }

enum MediaType { image, video }

class MediaItem {
  final String url;
  final MediaType type;
  final String? aspectRatio; // "16:9", "9:16", "1:1"
  final String? thumbnail; // for videos
  final int? duration; // for videos in seconds

  MediaItem({
    required this.url,
    required this.type,
    this.aspectRatio,
    this.thumbnail,
    this.duration,
  });
}

class CanvasPost {
  final String text;
  final String? backgroundColor;
  final String? backgroundImageUrl;
  final String? fontFamily;
  final Color? textColor;

  CanvasPost({
    required this.text,
    this.backgroundColor,
    this.backgroundImageUrl,
    this.fontFamily,
    this.textColor,
  });
}

class TrendingTopic {
  final int id;
  final String name;
  final String emoji;
  final Gradient gradient;
  final int postCount;

  TrendingTopic({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gradient,
    required this.postCount,
  });
}

class Story {
  final int id;
  final String name;
  final String avatar;
  final bool viewed;
  final bool isOwn;
  final DateTime? timestamp;

  Story({
    required this.id,
    required this.name,
    required this.avatar,
    this.viewed = false,
    this.isOwn = false,
    this.timestamp,
  });

  Story copyWith({
    int? id,
    String? name,
    String? avatar,
    bool? viewed,
    bool? isOwn,
    DateTime? timestamp,
  }) {
    return Story(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      viewed: viewed ?? this.viewed,
      isOwn: isOwn ?? this.isOwn,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class FeedPost {
  final int id;
  final String userId;
  final String userName;
  final String userAvatar;
  final bool userVerified;
  final bool userOpenToMingle;
  final String content;
  final String? imageUrl; // Keep for backward compatibility
  final String timeAgo;
  final String category;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isBookmarked;
  final List<String> tags;

  // New fields for enhanced content types
  final PostType postType;
  final List<MediaItem>? mediaItems; // For photos/videos/carousel
  final CanvasPost? canvasData; // For canvas posts
  final int recommendations; // New interaction type
  final bool isRecommended;
  final ReactionSummary reactionSummary; // Reaction system like video feed

  FeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.userVerified = false,
    this.userOpenToMingle = false,
    required this.content,
    this.imageUrl,
    required this.timeAgo,
    required this.category,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.tags = const [],
    this.postType = PostType.photo,
    this.mediaItems,
    this.canvasData,
    this.recommendations = 0,
    this.isRecommended = false,
    ReactionSummary? reactionSummary,
  }) : reactionSummary = reactionSummary ?? ReactionSummary.empty();

  /// Factory constructor for creating FeedPost from JSON
  factory FeedPost.fromSupabaseJson(Map<String, dynamic> json) {
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

    return FeedPost(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? json['creator_name'] ?? 'Unknown',
      userAvatar: json['user_avatar'] ?? json['creator_avatar'] ?? '',
      userVerified: json['user_verified'] ?? false,
      userOpenToMingle: json['user_open_to_mingle'] ?? false,
      content: json['content'] ?? json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['thumbnail_url'],
      timeAgo: _formatTimeAgo(DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now()),
      category: json['category'] ?? json['workout_type'] ?? 'General',
      likes: json['likes_count'] ?? 0,
      comments: json['comments_count'] ?? 0,
      shares: json['shares_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      postType: postType,
      mediaItems: mediaItems,
      canvasData: canvasData,
      recommendations: json['recommendations_count'] ?? 0,
      isRecommended: json['is_recommended'] ?? false,
    );
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

  FeedPost copyWith({
    int? id,
    String? userId,
    String? userName,
    String? userAvatar,
    bool? userVerified,
    bool? userOpenToMingle,
    String? content,
    String? imageUrl,
    String? timeAgo,
    String? category,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    bool? isBookmarked,
    List<String>? tags,
    PostType? postType,
    List<MediaItem>? mediaItems,
    CanvasPost? canvasData,
    int? recommendations,
    bool? isRecommended,
    ReactionSummary? reactionSummary,
  }) {
    return FeedPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userVerified: userVerified ?? this.userVerified,
      userOpenToMingle: userOpenToMingle ?? this.userOpenToMingle,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      timeAgo: timeAgo ?? this.timeAgo,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      tags: tags ?? this.tags,
      postType: postType ?? this.postType,
      mediaItems: mediaItems ?? this.mediaItems,
      canvasData: canvasData ?? this.canvasData,
      recommendations: recommendations ?? this.recommendations,
      isRecommended: isRecommended ?? this.isRecommended,
      reactionSummary: reactionSummary ?? this.reactionSummary,
    );
  }
}

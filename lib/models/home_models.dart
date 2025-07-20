import 'package:flutter/material.dart';

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
  });

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
    );
  }
}

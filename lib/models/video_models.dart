import 'user_model.dart';
import 'reaction_models.dart';

class VideoPost {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final User creator;
  final String title;
  final String description;
  final List<String> tags;
  final String workoutType;
  final String difficulty;
  final int duration;
  final int views;
  final int shares;
  final int comments;
  final DateTime createdAt;
  final bool isFollowing;

  // Updated reaction fields
  final ReactionSummary reactionSummary;
  final List<Recommendation> recommendations;
  final bool isRecommended;

  const VideoPost({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.creator,
    required this.title,
    required this.description,
    required this.tags,
    required this.workoutType,
    required this.difficulty,
    required this.duration,
    required this.views,
    required this.shares,
    required this.comments,
    required this.createdAt,
    required this.isFollowing,
    required this.reactionSummary,
    required this.recommendations,
    required this.isRecommended,
  });

  // Legacy getter for backward compatibility
  int get likes => reactionSummary.totalCount;
  bool get isLiked => reactionSummary.userReaction != null;

  VideoPost copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    User? creator,
    String? title,
    String? description,
    List<String>? tags,
    String? workoutType,
    String? difficulty,
    int? duration,
    int? views,
    int? shares,
    int? comments,
    DateTime? createdAt,
    bool? isFollowing,
    ReactionSummary? reactionSummary,
    List<Recommendation>? recommendations,
    bool? isRecommended,
  }) {
    return VideoPost(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      creator: creator ?? this.creator,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      workoutType: workoutType ?? this.workoutType,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      shares: shares ?? this.shares,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      isFollowing: isFollowing ?? this.isFollowing,
      reactionSummary: reactionSummary ?? this.reactionSummary,
      recommendations: recommendations ?? this.recommendations,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }
}

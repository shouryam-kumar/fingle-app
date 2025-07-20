import 'user_model.dart';
import 'reaction_models.dart';

class Comment {
  final String id;
  final String videoId;
  final String content;
  final User author;
  final DateTime createdAt;
  final String timeAgo;
  final bool isEdited;
  final bool isPinned;
  final List<Comment> replies;

  // Updated reaction fields
  final ReactionSummary reactionSummary;

  const Comment({
    required this.id,
    required this.videoId,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.timeAgo,
    required this.isEdited,
    required this.isPinned,
    required this.replies,
    required this.reactionSummary,
  });

  // Legacy getters for backward compatibility
  int get likes => reactionSummary.totalCount;
  bool get isLiked => reactionSummary.userReaction != null;
  bool get hasReplies => replies.isNotEmpty;

  Comment copyWith({
    String? id,
    String? videoId,
    String? content,
    User? author,
    DateTime? createdAt,
    String? timeAgo,
    bool? isEdited,
    bool? isPinned,
    List<Comment>? replies,
    ReactionSummary? reactionSummary,
  }) {
    return Comment(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      timeAgo: timeAgo ?? this.timeAgo,
      isEdited: isEdited ?? this.isEdited,
      isPinned: isPinned ?? this.isPinned,
      replies: replies ?? this.replies,
      reactionSummary: reactionSummary ?? this.reactionSummary,
    );
  }
}

class CommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSubmitting;
  final bool hasMoreComments;
  final int totalComments;
  final String? error;
  final String? replyingToId;
  final User? replyingToUser;

  const CommentsState({
    required this.comments,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isSubmitting,
    required this.hasMoreComments,
    required this.totalComments,
    this.error,
    this.replyingToId,
    this.replyingToUser,
  });

  factory CommentsState.initial() {
    return const CommentsState(
      comments: [],
      isLoading: false,
      isLoadingMore: false,
      isSubmitting: false,
      hasMoreComments: true,
      totalComments: 0,
      error: null,
      replyingToId: null,
      replyingToUser: null,
    );
  }

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSubmitting,
    bool? hasMoreComments,
    int? totalComments,
    String? error,
    String? replyingToId,
    User? replyingToUser,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      totalComments: totalComments ?? this.totalComments,
      error: error ?? this.error,
      replyingToId: replyingToId ?? this.replyingToId,
      replyingToUser: replyingToUser ?? this.replyingToUser,
    );
  }
}

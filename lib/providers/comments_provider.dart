 import 'package:flutter/foundation.dart';
import '../models/comment_models.dart';
import '../models/user_model.dart';

class CommentsProvider extends ChangeNotifier {
  // Map of video ID to comments state
  final Map<String, CommentsState> _videoComments = {};
  
  // Current video being viewed
  String? _currentVideoId;
  
  // Mock current user (in real app, this would come from AuthProvider)
  final User _currentUser = User(
    id: 'current_user',
    name: 'You',
    age: 25,
    bio: 'Fitness enthusiast',
    profilePic: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    coverImage: '',
    isVerified: false,
    joinedAt: DateTime.now().subtract(const Duration(days: 30)),
    interests: ['Fitness'],
    posts: [],
    stats: UserStats(totalPosts: 0, followers: 0, following: 0, totalViews: 0),
    achievements: [],
  );

  // Getters
  CommentsState getCommentsState(String videoId) {
    return _videoComments[videoId] ?? CommentsState();
  }

  List<Comment> getComments(String videoId) {
    return getCommentsState(videoId).comments;
  }

  bool isLoading(String videoId) {
    return getCommentsState(videoId).isLoading;
  }

  bool isSubmitting(String videoId) {
    return getCommentsState(videoId).isSubmitting;
  }

  String? getReplyingToId(String videoId) {
    return getCommentsState(videoId).replyingToId;
  }

  User? getReplyingToUser(String videoId) {
    return getCommentsState(videoId).replyingToUser;
  }

  int getTotalComments(String videoId) {
    return getCommentsState(videoId).totalComments;
  }

  User get currentUser => _currentUser;

  // Set current video
  void setCurrentVideoId(String videoId) {
    _currentVideoId = videoId;
    
    // Auto-load comments if not already loaded
    if (!_videoComments.containsKey(videoId)) {
      loadComments(videoId);
    }
  }

  // Load comments for a video
  Future<void> loadComments(String videoId) async {
    if (getCommentsState(videoId).isLoading) return;

    _updateState(videoId, getCommentsState(videoId).copyWith(isLoading: true));

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // In real app, this would be an API call
      final comments = _getMockCommentsForVideo(videoId);
      final totalComments = _calculateTotalComments(comments);

      _updateState(videoId, CommentsState(
        comments: comments,
        isLoading: false,
        hasMoreComments: comments.length >= 10, // Simulate pagination
        totalComments: totalComments,
      ));

    } catch (e) {
      _updateState(videoId, getCommentsState(videoId).copyWith(
        isLoading: false,
        error: 'Failed to load comments',
      ));
    }
  }

  // Add a new comment
  Future<void> addComment(String videoId, String content) async {
    if (content.trim().isEmpty) return;

    final state = getCommentsState(videoId);
    _updateState(videoId, state.copyWith(isSubmitting: true));

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final newComment = Comment(
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        videoId: videoId,
        author: _currentUser,
        content: content.trim(),
        createdAt: DateTime.now(),
        likes: 0,
        isLiked: false,
        mentions: _extractMentions(content),
      );

      // Add to the beginning of the list (newest first)
      final updatedComments = [newComment, ...state.comments];
      final totalComments = _calculateTotalComments(updatedComments);

      _updateState(videoId, state.copyWith(
        comments: updatedComments,
        isSubmitting: false,
        totalComments: totalComments,
        error: null,
      ));

      debugPrint('✅ Comment added successfully');

    } catch (e) {
      _updateState(videoId, state.copyWith(
        isSubmitting: false,
        error: 'Failed to add comment',
      ));
    }
  }

  // Reply to a comment
  Future<void> replyToComment(String videoId, String commentId, String content) async {
    if (content.trim().isEmpty) return;

    final state = getCommentsState(videoId);
    _updateState(videoId, state.copyWith(isSubmitting: true));

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final newReply = Comment(
        id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
        videoId: videoId,
        parentCommentId: commentId,
        author: _currentUser,
        content: content.trim(),
        createdAt: DateTime.now(),
        likes: 0,
        isLiked: false,
        mentions: _extractMentions(content),
      );

      // Find the parent comment and add reply
      final updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          return comment.copyWith(replies: [...comment.replies, newReply]);
        }
        return comment;
      }).toList();

      final totalComments = _calculateTotalComments(updatedComments);

      _updateState(videoId, state.copyWith(
        comments: updatedComments,
        isSubmitting: false,
        replyingToId: null,
        replyingToUser: null,
        totalComments: totalComments,
        error: null,
      ));

      debugPrint('✅ Reply added successfully');

    } catch (e) {
      _updateState(videoId, state.copyWith(
        isSubmitting: false,
        error: 'Failed to add reply',
      ));
    }
  }

  // Toggle like on a comment
  Future<void> toggleCommentLike(String videoId, String commentId, {bool isReply = false}) async {
    final state = getCommentsState(videoId);
    
    // Optimistic update
    List<Comment> updatedComments;
    
    if (isReply) {
      // Handle reply like
      updatedComments = state.comments.map((comment) {
        final updatedReplies = comment.replies.map((reply) {
          if (reply.id == commentId) {
            return reply.copyWith(
              isLiked: !reply.isLiked,
              likes: reply.isLiked ? reply.likes - 1 : reply.likes + 1,
            );
          }
          return reply;
        }).toList();
        return comment.copyWith(replies: updatedReplies);
      }).toList();
    } else {
      // Handle main comment like
      updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          return comment.copyWith(
            isLiked: !comment.isLiked,
            likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
          );
        }
        return comment;
      }).toList();
    }

    _updateState(videoId, state.copyWith(comments: updatedComments));

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      // In real app, this would be an API call
      debugPrint('✅ Comment like toggled successfully');

    } catch (e) {
      // Revert optimistic update on error
      _updateState(videoId, state);
      debugPrint('❌ Failed to toggle comment like');
    }
  }

  // Set replying state
  void setReplyingTo(String videoId, String commentId, User user) {
    final state = getCommentsState(videoId);
    _updateState(videoId, state.copyWith(
      replyingToId: commentId,
      replyingToUser: user,
    ));
  }

  // Clear replying state
  void clearReplyingTo(String videoId) {
    final state = getCommentsState(videoId);
    _updateState(videoId, state.copyWith(
      replyingToId: null,
      replyingToUser: null,
    ));
  }

  // Load more comments (pagination)
  Future<void> loadMoreComments(String videoId) async {
    final state = getCommentsState(videoId);
    
    if (state.isLoadingMore || !state.hasMoreComments) return;

    _updateState(videoId, state.copyWith(isLoadingMore: true));

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 600));

      // In real app, this would fetch more comments from API
      final moreComments = _getMockCommentsForVideo(videoId, offset: state.comments.length);
      final updatedComments = [...state.comments, ...moreComments];
      final totalComments = _calculateTotalComments(updatedComments);

      _updateState(videoId, state.copyWith(
        comments: updatedComments,
        isLoadingMore: false,
        hasMoreComments: moreComments.length >= 5, // Simulate end of pagination
        totalComments: totalComments,
      ));

    } catch (e) {
      _updateState(videoId, state.copyWith(
        isLoadingMore: false,
        error: 'Failed to load more comments',
      ));
    }
  }

  // Delete a comment (only if user is the author)
  Future<void> deleteComment(String videoId, String commentId, {bool isReply = false, String? parentCommentId}) async {
    final state = getCommentsState(videoId);

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      List<Comment> updatedComments;

      if (isReply && parentCommentId != null) {
        // Delete reply
        updatedComments = state.comments.map((comment) {
          if (comment.id == parentCommentId) {
            final updatedReplies = comment.replies.where((reply) => reply.id != commentId).toList();
            return comment.copyWith(replies: updatedReplies);
          }
          return comment;
        }).toList();
      } else {
        // Delete main comment
        updatedComments = state.comments.where((comment) => comment.id != commentId).toList();
      }

      final totalComments = _calculateTotalComments(updatedComments);

      _updateState(videoId, state.copyWith(
        comments: updatedComments,
        totalComments: totalComments,
      ));

      debugPrint('✅ Comment deleted successfully');

    } catch (e) {
      _updateState(videoId, state.copyWith(
        error: 'Failed to delete comment',
      ));
    }
  }

  // Clear error
  void clearError(String videoId) {
    final state = getCommentsState(videoId);
    _updateState(videoId, state.copyWith(error: null));
  }

  // Helper methods
  void _updateState(String videoId, CommentsState newState) {
    _videoComments[videoId] = newState;
    notifyListeners();
  }

  List<Comment> _getMockCommentsForVideo(String videoId, {int offset = 0}) {
    // In real app, this would be an API call
    if (offset > 0) {
      // Return fewer comments for pagination simulation
      return mockComments.take(2).toList();
    }
    return List.from(mockComments);
  }

  int _calculateTotalComments(List<Comment> comments) {
    int total = comments.length;
    for (final comment in comments) {
      total += comment.replies.length;
    }
    return total;
  }

  List<String> _extractMentions(String content) {
    final RegExp mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }

  // Cleanup
  void dispose() {
    _videoComments.clear();
    super.dispose();
  }
}
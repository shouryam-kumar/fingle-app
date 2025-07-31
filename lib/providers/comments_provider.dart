import 'package:flutter/foundation.dart';
import '../models/comment_models.dart';
import '../models/user_model.dart';
import '../models/reaction_models.dart';
import '../services/supabase/comments_service.dart';

class CommentsProvider extends ChangeNotifier {
  // Map of video ID to comments state
  final Map<String, CommentsState> _videoComments = {};

  // Current video being viewed
  String? _currentVideoId;

  // Current user (loaded from Supabase)
  User? _currentUser;

  // Mock comments data
  List<Comment> get mockComments => [
        Comment(
          id: '1',
          videoId: 'video_1',
          content: 'Great workout! This really motivated me to push harder 💪',
          author: User(
            id: 'user_1',
            username: 'sarahjohnson',
            name: 'Sarah Johnson',
            age: 26,
            bio: 'Fitness lover',
            profilePic:
                'https://images.unsplash.com/photo-1494790108755-2616b612b02c?w=150&h=150&fit=crop&crop=face',
            coverImage: '',
            isVerified: true,
            isFollowing: false,
            joinedAt: DateTime.now().subtract(const Duration(days: 100)),
            interests: ['Fitness'],
            followers: 1200,
            following: 800,
            posts: [],
            stats: UserStats(
                totalPosts: 0, followers: 0, following: 0, totalViews: 0),
            achievements: [],
          ),
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          timeAgo: '30m ago',
          isEdited: false,
          isPinned: false,
          replies: [],
          reactionSummary: const ReactionSummary(
            counts: {},
            reactions: {},
            userReaction: null,
            totalCount: 0,
          ),
        ),
        Comment(
          id: '2',
          videoId: 'video_1',
          content: 'Amazing form! How long have you been training?',
          author: User(
            id: 'user_2',
            username: 'mikechen',
            name: 'Mike Chen',
            age: 28,
            bio: 'Personal trainer',
            profilePic:
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
            coverImage: '',
            isVerified: false,
            isFollowing: false,
            joinedAt: DateTime.now().subtract(const Duration(days: 200)),
            interests: ['Training'],
            followers: 800,
            following: 600,
            posts: [],
            stats: UserStats(
                totalPosts: 0, followers: 0, following: 0, totalViews: 0),
            achievements: [],
          ),
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          timeAgo: '1h ago',
          isEdited: false,
          isPinned: false,
          replies: [],
          reactionSummary: const ReactionSummary(
            counts: {},
            reactions: {},
            userReaction: null,
            totalCount: 0,
          ),
        ),
      ];

  // Getters
  CommentsState getCommentsState(String videoId) {
    return _videoComments[videoId] ?? CommentsState.initial();
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

  User? get currentUser => _currentUser;

  // Set current video
  void setCurrentVideoId(String videoId) {
    _currentVideoId = videoId;

    // Auto-load comments if not already loaded
    if (!_videoComments.containsKey(videoId)) {
      loadComments(videoId);
    }
  }

  // Load comments for a video
  Future<void> loadComments(String videoId, {String contentType = 'video'}) async {
    if (getCommentsState(videoId).isLoading) return;

    _updateState(videoId, getCommentsState(videoId).copyWith(isLoading: true));

    try {
      // Load current user if not already loaded
      if (_currentUser == null) {
        _currentUser = await CommentsService.getCurrentUser();
      }

      // Load comments from Supabase
      var comments = await CommentsService.getComments(
        contentType: contentType,
        contentId: videoId,
        sortBy: 'newest',
        limit: 20,
        offset: 0,
      );

      // Fallback to mock data if no comments from API
      if (comments.isEmpty) {
        comments = _getMockCommentsForVideo(videoId);
      }

      // Sort comments with pinned ones first
      comments = _sortCommentsWithPinnedFirst(comments);

      final totalComments = _calculateTotalComments(comments);

      _updateState(
          videoId,
          CommentsState(
            comments: comments,
            isLoading: false,
            isLoadingMore: false,
            isSubmitting: false,
            hasMoreComments: comments.length >= 10,
            totalComments: totalComments,
          ));
    } catch (e) {
      debugPrint('❌ Error loading comments: $e');
      
      // Fallback to mock data on error
      try {
        var comments = _getMockCommentsForVideo(videoId);
        comments = _sortCommentsWithPinnedFirst(comments);
        final totalComments = _calculateTotalComments(comments);

        _updateState(
            videoId,
            CommentsState(
              comments: comments,
              isLoading: false,
              isLoadingMore: false,
              isSubmitting: false,
              hasMoreComments: comments.length >= 10,
              totalComments: totalComments,
              error: 'Using cached comments',
            ));
      } catch (fallbackError) {
        _updateState(
            videoId,
            getCommentsState(videoId).copyWith(
              isLoading: false,
              error: 'Failed to load comments',
            ));
      }
    }
  }

  List<Comment> _sortCommentsWithPinnedFirst(List<Comment> comments) {
    // Separate pinned and regular comments
    final pinnedComments =
        comments.where((comment) => comment.isPinned).toList();
    final regularComments =
        comments.where((comment) => !comment.isPinned).toList();

    // Sort pinned comments by creation time (newest first)
    pinnedComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Sort regular comments by creation time (newest first)
    regularComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Return pinned comments first, then regular comments
    return [...pinnedComments, ...regularComments];
  }

  // Add a new comment
  Future<void> addComment(String videoId, String content, {String contentType = 'video'}) async {
    if (content.trim().isEmpty || _currentUser == null) return;

    final state = getCommentsState(videoId);
    _updateState(videoId, state.copyWith(isSubmitting: true));

    try {
      // Create comment via Supabase API
      final newComment = await CommentsService.createComment(
        contentType: contentType,
        contentId: videoId,
        content: content.trim(),
      );

      if (newComment != null) {
        // Add new comment to the list
        var updatedComments = [newComment, ...state.comments];

        // Re-sort to ensure pinned comments stay at top
        updatedComments = _sortCommentsWithPinnedFirst(updatedComments);

        final totalComments = _calculateTotalComments(updatedComments);

        _updateState(
            videoId,
            state.copyWith(
              comments: updatedComments,
              isSubmitting: false,
              totalComments: totalComments,
              error: null,
            ));

        debugPrint('✅ Comment added successfully via API');
      } else {
        // Fallback to local comment creation
        final fallbackComment = Comment(
          id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
          videoId: videoId,
          author: _currentUser!,
          content: content.trim(),
          createdAt: DateTime.now(),
          timeAgo: 'now',
          isEdited: false,
          isPinned: false,
          replies: [],
          reactionSummary: const ReactionSummary(
            counts: {},
            reactions: {},
            userReaction: null,
            totalCount: 0,
          ),
        );

        var updatedComments = [fallbackComment, ...state.comments];
        updatedComments = _sortCommentsWithPinnedFirst(updatedComments);
        final totalComments = _calculateTotalComments(updatedComments);

        _updateState(
            videoId,
            state.copyWith(
              comments: updatedComments,
              isSubmitting: false,
              totalComments: totalComments,
              error: 'Comment saved locally',
            ));

        debugPrint('⚠️ Comment added locally (API failed)');
      }
    } catch (e) {
      debugPrint('❌ Error adding comment: $e');
      _updateState(
          videoId,
          state.copyWith(
            isSubmitting: false,
            error: 'Failed to add comment',
          ));
    }
  }

  // Reply to a comment
  Future<void> replyToComment(
      String videoId, String commentId, String content, {String contentType = 'video'}) async {
    if (content.trim().isEmpty || _currentUser == null) return;

    final state = getCommentsState(videoId);
    _updateState(videoId, state.copyWith(isSubmitting: true));

    try {
      // Create reply via Supabase API
      final newReply = await CommentsService.createComment(
        contentType: contentType,
        contentId: videoId,
        content: content.trim(),
        parentCommentId: commentId,
      );

      if (newReply != null) {
        // Find the parent comment and add reply
        final updatedComments = state.comments.map((comment) {
          if (comment.id == commentId) {
            return comment.copyWith(replies: [...comment.replies, newReply]);
          }
          return comment;
        }).toList();

        final totalComments = _calculateTotalComments(updatedComments);

        _updateState(
            videoId,
            CommentsState(
              comments: updatedComments,
              isLoading: false,
              isLoadingMore: false,
              isSubmitting: false,
              hasMoreComments: state.hasMoreComments,
              totalComments: totalComments,
              error: null,
              replyingToId: null,
              replyingToUser: null,
            ));

        debugPrint('✅ Reply added successfully via API');
      } else {
        // Fallback to local reply creation
        final fallbackReply = Comment(
          id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
          videoId: videoId,
          author: _currentUser!,
          content: content.trim(),
          createdAt: DateTime.now(),
          timeAgo: 'now',
          isEdited: false,
          isPinned: false,
          replies: [],
          reactionSummary: const ReactionSummary(
            counts: {},
            reactions: {},
            userReaction: null,
            totalCount: 0,
          ),
        );

        final updatedComments = state.comments.map((comment) {
          if (comment.id == commentId) {
            return comment.copyWith(replies: [...comment.replies, fallbackReply]);
          }
          return comment;
        }).toList();

        final totalComments = _calculateTotalComments(updatedComments);

        _updateState(
            videoId,
            CommentsState(
              comments: updatedComments,
              isLoading: false,
              isLoadingMore: false,
              isSubmitting: false,
              hasMoreComments: state.hasMoreComments,
              totalComments: totalComments,
              error: 'Reply saved locally',
              replyingToId: null,
              replyingToUser: null,
            ));

        debugPrint('⚠️ Reply added locally (API failed)');
      }
    } catch (e) {
      debugPrint('❌ Error adding reply: $e');
      _updateState(
          videoId,
          state.copyWith(
            isSubmitting: false,
            error: 'Failed to add reply',
          ));
    }
  }

  // Toggle like on a comment
  Future<void> toggleCommentLike(String videoId, String commentId,
      {bool isReply = false}) async {
    final state = getCommentsState(videoId);

    // Store original state for potential revert
    final originalComments = List<Comment>.from(state.comments);

    // Optimistic update
    List<Comment> updatedComments;

    if (isReply) {
      // Handle reply like
      updatedComments = state.comments.map((comment) {
        final updatedReplies = comment.replies.map((reply) {
          if (reply.id == commentId) {
            // Toggle like reaction (using ReactionType.like)
            final newUserReaction = reply.isLiked ? null : ReactionType.like;
            final newTotalCount =
                reply.isLiked ? reply.likes - 1 : reply.likes + 1;

            final newCounts =
                Map<ReactionType, int>.from(reply.reactionSummary.counts);

            if (reply.isLiked) {
              // Remove like
              newCounts[ReactionType.like] =
                  (newCounts[ReactionType.like] ?? 1) - 1;
              if (newCounts[ReactionType.like]! <= 0) {
                newCounts.remove(ReactionType.like);
              }
            } else {
              // Add like
              newCounts[ReactionType.like] =
                  (newCounts[ReactionType.like] ?? 0) + 1;
            }

            final newReactionSummary = ReactionSummary(
              counts: newCounts,
              reactions: reply.reactionSummary.reactions,
              userReaction: newUserReaction,
              totalCount: newTotalCount,
            );

            return reply.copyWith(reactionSummary: newReactionSummary);
          }
          return reply;
        }).toList();
        return comment.copyWith(replies: updatedReplies);
      }).toList();
    } else {
      // Handle main comment like
      updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          // Toggle like reaction (using ReactionType.like)
          final newUserReaction = comment.isLiked ? null : ReactionType.like;
          final newTotalCount =
              comment.isLiked ? comment.likes - 1 : comment.likes + 1;

          final newCounts =
              Map<ReactionType, int>.from(comment.reactionSummary.counts);

          if (comment.isLiked) {
            // Remove like
            newCounts[ReactionType.like] =
                (newCounts[ReactionType.like] ?? 1) - 1;
            if (newCounts[ReactionType.like]! <= 0) {
              newCounts.remove(ReactionType.like);
            }
          } else {
            // Add like
            newCounts[ReactionType.like] =
                (newCounts[ReactionType.like] ?? 0) + 1;
          }

          final newReactionSummary = ReactionSummary(
            counts: newCounts,
            reactions: comment.reactionSummary.reactions,
            userReaction: newUserReaction,
            totalCount: newTotalCount,
          );

          return comment.copyWith(reactionSummary: newReactionSummary);
        }
        return comment;
      }).toList();
    }

    _updateState(videoId, state.copyWith(comments: updatedComments));

    try {
      // Call Supabase API to toggle reaction
      final success = await CommentsService.toggleCommentReaction(
        commentId: commentId,
        reactionType: ReactionType.like,
      );

      if (success) {
        debugPrint('✅ Comment reaction toggled successfully via API');
      } else {
        // Revert optimistic update on API failure
        _updateState(videoId, state.copyWith(comments: originalComments));
        debugPrint('❌ Failed to toggle comment reaction via API, reverted');
      }
    } catch (e) {
      // Revert optimistic update on error
      _updateState(videoId, state.copyWith(comments: originalComments));
      debugPrint('❌ Error toggling comment reaction: $e');
    }
  }

  // ✅ ENHANCED: Set replying state with better logging
  void setReplyingTo(String videoId, String commentId, User user) {
    debugPrint('🔄 CommentsProvider: Setting reply state');
    debugPrint(
        '🔄 VideoId: $videoId, CommentId: $commentId, User: ${user.name}');

    final state = getCommentsState(videoId);

    // ✅ Use explicit new state instead of copyWith for critical state changes
    final newState = CommentsState(
      comments: state.comments,
      isLoading: state.isLoading,
      isLoadingMore: state.isLoadingMore,
      isSubmitting: state.isSubmitting,
      hasMoreComments: state.hasMoreComments,
      totalComments: state.totalComments,
      error: state.error,
      replyingToId: commentId, // ✅ Explicitly set
      replyingToUser: user, // ✅ Explicitly set
    );

    _updateState(videoId, newState);

    debugPrint('🔄 Reply state set successfully');
    debugPrint(
        '🔄 Current replyingToId: ${getCommentsState(videoId).replyingToId}');
  }

  // ✅ ENHANCED: Clear replying state with explicit null setting
  void clearReplyingTo(String videoId) {
    debugPrint('🔄 CommentsProvider: Clearing reply state for video: $videoId');

    final state = getCommentsState(videoId);

    // ✅ Use explicit new state instead of copyWith for critical state changes
    final newState = CommentsState(
      comments: state.comments,
      isLoading: state.isLoading,
      isLoadingMore: state.isLoadingMore,
      isSubmitting: state.isSubmitting,
      hasMoreComments: state.hasMoreComments,
      totalComments: state.totalComments,
      error: state.error,
      replyingToId: null, // ✅ Explicitly set to null
      replyingToUser: null, // ✅ Explicitly set to null
    );

    _updateState(videoId, newState);

    debugPrint('🔄 Reply state cleared successfully');
    debugPrint(
        '🔄 Current replyingToId: ${getCommentsState(videoId).replyingToId}');
    debugPrint(
        '🔄 Current replyingToUser: ${getCommentsState(videoId).replyingToUser}');
  }

  // Load more comments (pagination)
  Future<void> loadMoreComments(String videoId, {String contentType = 'video'}) async {
    final state = getCommentsState(videoId);

    if (state.isLoadingMore || !state.hasMoreComments) return;

    _updateState(videoId, state.copyWith(isLoadingMore: true));

    try {
      // Load more comments from Supabase
      final moreComments = await CommentsService.getComments(
        contentType: contentType,
        contentId: videoId,
        sortBy: 'newest',
        limit: 10,
        offset: state.comments.length,
      );

      if (moreComments.isNotEmpty) {
        final updatedComments = [...state.comments, ...moreComments];
        final totalComments = _calculateTotalComments(updatedComments);

        _updateState(
            videoId,
            state.copyWith(
              comments: updatedComments,
              isLoadingMore: false,
              hasMoreComments: moreComments.length >= 10,
              totalComments: totalComments,
            ));

        debugPrint('✅ Loaded ${moreComments.length} more comments via API');
      } else {
        // No more comments available
        _updateState(
            videoId,
            state.copyWith(
              isLoadingMore: false,
              hasMoreComments: false,
            ));

        debugPrint('📝 No more comments available');
      }
    } catch (e) {
      debugPrint('❌ Error loading more comments: $e');
      
      // Try fallback to mock data
      try {
        final moreComments =
            _getMockCommentsForVideo(videoId, offset: state.comments.length);
        
        if (moreComments.isNotEmpty) {
          final updatedComments = [...state.comments, ...moreComments];
          final totalComments = _calculateTotalComments(updatedComments);

          _updateState(
              videoId,
              state.copyWith(
                comments: updatedComments,
                isLoadingMore: false,
                hasMoreComments: moreComments.length >= 5,
                totalComments: totalComments,
                error: 'Using cached comments',
              ));
        } else {
          _updateState(
              videoId,
              state.copyWith(
                isLoadingMore: false,
                hasMoreComments: false,
              ));
        }
      } catch (fallbackError) {
        _updateState(
            videoId,
            state.copyWith(
              isLoadingMore: false,
              error: 'Failed to load more comments',
            ));
      }
    }
  }

  // Delete a comment (only if user is the author)
  Future<void> deleteComment(String videoId, String commentId,
      {bool isReply = false, String? parentCommentId}) async {
    final state = getCommentsState(videoId);

    // Store original state for potential revert
    final originalComments = List<Comment>.from(state.comments);

    // Optimistic update - remove comment immediately
    List<Comment> updatedComments;

    if (isReply && parentCommentId != null) {
      // Delete reply
      updatedComments = state.comments.map((comment) {
        if (comment.id == parentCommentId) {
          final updatedReplies = comment.replies
              .where((reply) => reply.id != commentId)
              .toList();
          return comment.copyWith(replies: updatedReplies);
        }
        return comment;
      }).toList();
    } else {
      // Delete main comment
      updatedComments =
          state.comments.where((comment) => comment.id != commentId).toList();
    }

    final totalComments = _calculateTotalComments(updatedComments);

    _updateState(
        videoId,
        state.copyWith(
          comments: updatedComments,
          totalComments: totalComments,
        ));

    try {
      // Call Supabase API to delete comment
      final success = await CommentsService.deleteComment(commentId: commentId);

      if (success) {
        debugPrint('✅ Comment deleted successfully via API');
      } else {
        // Revert optimistic update on API failure
        _updateState(
            videoId,
            state.copyWith(
              comments: originalComments,
              totalComments: _calculateTotalComments(originalComments),
              error: 'Failed to delete comment',
            ));
        debugPrint('❌ Failed to delete comment via API, reverted');
      }
    } catch (e) {
      // Revert optimistic update on error
      _updateState(
          videoId,
          state.copyWith(
            comments: originalComments,
            totalComments: _calculateTotalComments(originalComments),
            error: 'Failed to delete comment',
          ));
      debugPrint('❌ Error deleting comment: $e');
    }
  }

  // Clear error
  void clearError(String videoId) {
    final state = getCommentsState(videoId);
    _updateState(videoId, state.copyWith(error: null));
  }

  // ✅ ENHANCED: Helper method with better logging
  void _updateState(String videoId, CommentsState newState) {
    _videoComments[videoId] = newState;
    debugPrint('🔄 State updated for video: $videoId');
    debugPrint('🔄 New replyingToId: ${newState.replyingToId}');
    notifyListeners();
    debugPrint('🔄 Listeners notified');
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
  @override
  void dispose() {
    _videoComments.clear();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import '../models/comment_models.dart';
import '../models/user_model.dart';
import '../models/reaction_models.dart';

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
    isFollowing: false,
    joinedAt: DateTime.now().subtract(const Duration(days: 30)),
    interests: ['Fitness'],
    followers: 0,
    following: 0,
    posts: [],
    stats: UserStats(totalPosts: 0, followers: 0, following: 0, totalViews: 0),
    achievements: [],
  );

  // Mock comments data
  List<Comment> get mockComments => [
    Comment(
      id: '1',
      videoId: 'video_1',
      content: 'Great workout! This really motivated me to push harder 💪',
      author: User(
        id: 'user_1',
        name: 'Sarah Johnson',
        age: 26,
        bio: 'Fitness lover',
        profilePic: 'https://images.unsplash.com/photo-1494790108755-2616b612b02c?w=150&h=150&fit=crop&crop=face',
        coverImage: '',
        isVerified: true,
        isFollowing: false,
        joinedAt: DateTime.now().subtract(const Duration(days: 100)),
        interests: ['Fitness'],
        followers: 1200,
        following: 800,
        posts: [],
        stats: UserStats(totalPosts: 0, followers: 0, following: 0, totalViews: 0),
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
        name: 'Mike Chen',
        age: 28,
        bio: 'Personal trainer',
        profilePic: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        coverImage: '',
        isVerified: false,
        isFollowing: false,
        joinedAt: DateTime.now().subtract(const Duration(days: 200)),
        interests: ['Training'],
        followers: 800,
        following: 600,
        posts: [],
        stats: UserStats(totalPosts: 0, followers: 0, following: 0, totalViews: 0),
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
        var comments = _getMockCommentsForVideo(videoId);
        
        //  Sort comments with pinned ones first
        comments = _sortCommentsWithPinnedFirst(comments);
        
        final totalComments = _calculateTotalComments(comments);

        _updateState(videoId, CommentsState(
        comments: comments,
        isLoading: false,
        isLoadingMore: false,
        isSubmitting: false,
        hasMoreComments: comments.length >= 10,
        totalComments: totalComments,
        ));

    } catch (e) {
        _updateState(videoId, getCommentsState(videoId).copyWith(
        isLoading: false,
        error: 'Failed to load comments',
        ));
    }
  }

  List<Comment> _sortCommentsWithPinnedFirst(List<Comment> comments) {
  // Separate pinned and regular comments
  final pinnedComments = comments.where((comment) => comment.isPinned).toList();
  final regularComments = comments.where((comment) => !comment.isPinned).toList();
  
  // Sort pinned comments by creation time (newest first)
  pinnedComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  // Sort regular comments by creation time (newest first)
  regularComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  // Return pinned comments first, then regular comments
  return [...pinnedComments, ...regularComments];
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

        // Add new comment to the list
        var updatedComments = [newComment, ...state.comments];
        
        // ✅ FIXED: Re-sort to ensure pinned comments stay at top
        updatedComments = _sortCommentsWithPinnedFirst(updatedComments);
        
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
        author: _currentUser,
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

      // Find the parent comment and add reply
      final updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          return comment.copyWith(replies: [...comment.replies, newReply]);
        }
        return comment;
      }).toList();

      final totalComments = _calculateTotalComments(updatedComments);

      // ✅ ENHANCED: Use explicit null clearing for reply state
      _updateState(videoId, CommentsState(
        comments: updatedComments,
        isLoading: false,
        isLoadingMore: false,
        isSubmitting: false,
        hasMoreComments: state.hasMoreComments,
        totalComments: totalComments,
        error: null,
        replyingToId: null,      // ✅ Explicitly set to null
        replyingToUser: null,    // ✅ Explicitly set to null
      ));

      debugPrint('✅ Reply added successfully and reply state cleared');

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
            // TODO: Implement reaction system for comments
            return reply;
          }
          return reply;
        }).toList();
        return comment.copyWith(replies: updatedReplies);
      }).toList();
    } else {
      // Handle main comment like
      updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          // TODO: Implement reaction system for comments
          return comment;
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

  // ✅ ENHANCED: Set replying state with better logging
  void setReplyingTo(String videoId, String commentId, User user) {
    debugPrint('🔄 CommentsProvider: Setting reply state');
    debugPrint('🔄 VideoId: $videoId, CommentId: $commentId, User: ${user.name}');
    
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
      replyingToId: commentId,        // ✅ Explicitly set
      replyingToUser: user,           // ✅ Explicitly set
    );
    
    _updateState(videoId, newState);
    
    debugPrint('🔄 Reply state set successfully');
    debugPrint('🔄 Current replyingToId: ${getCommentsState(videoId).replyingToId}');
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
      replyingToId: null,             // ✅ Explicitly set to null
      replyingToUser: null,           // ✅ Explicitly set to null
    );
    
    _updateState(videoId, newState);
    
    debugPrint('🔄 Reply state cleared successfully');
    debugPrint('🔄 Current replyingToId: ${getCommentsState(videoId).replyingToId}');
    debugPrint('🔄 Current replyingToUser: ${getCommentsState(videoId).replyingToUser}');
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
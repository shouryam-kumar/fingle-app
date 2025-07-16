import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/video_models.dart';
import '../../../models/comment_models.dart';
import '../../../providers/comments_provider.dart';
import 'comment_item.dart';

class CommentList extends StatefulWidget {
  final VideoPost video;
  final ScrollController scrollController;
  final VoidCallback? onResetTimeout;

  const CommentList({
    super.key,
    required this.video,
    required this.scrollController,
    this.onResetTimeout,
  });

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  @override
  void initState() {
    super.initState();
    
    // Listen to scroll events for pagination
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    widget.onResetTimeout?.call();
    
    // Check if we need to load more comments
    if (widget.scrollController.position.pixels >= 
        widget.scrollController.position.maxScrollExtent - 200) {
      
      final commentsProvider = Provider.of<CommentsProvider>(context, listen: false);
      commentsProvider.loadMoreComments(widget.video.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentsProvider>(
      builder: (context, commentsProvider, child) {
        final state = commentsProvider.getCommentsState(widget.video.id);
        
        if (state.isLoading && state.comments.isEmpty) {
          return _buildLoadingState();
        }

        if (state.comments.isEmpty && !state.isLoading) {
          return _buildEmptyState();
        }

        return _buildCommentsList(state, commentsProvider);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading comments...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No comments yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to comment!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(CommentsState state, CommentsProvider commentsProvider) {
    return Column(
      children: [
        // Comments list
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: state.comments.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end
              if (index == state.comments.length) {
                return _buildLoadingMoreIndicator();
              }

              final comment = state.comments[index];
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Column(
                  children: [
                    // Main comment
                    CommentItem(
                      comment: comment,
                      video: widget.video,
                      onResetTimeout: widget.onResetTimeout,
                      onReply: () => _handleReply(comment),
                      onLike: () => _handleLike(comment, commentsProvider),
                      onDelete: () => _handleDelete(comment, commentsProvider),
                    ),
                    
                    // Replies
                    if (comment.hasReplies) ...[
                      const SizedBox(height: 8),
                      ...comment.replies.map((reply) => Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: CommentItem(
                          comment: reply,
                          video: widget.video,
                          isReply: true,
                          onResetTimeout: widget.onResetTimeout,
                          onReply: () => _handleReply(comment, replyToReply: reply),
                          onLike: () => _handleLike(reply, commentsProvider, isReply: true),
                          onDelete: () => _handleDelete(reply, commentsProvider, parentComment: comment),
                        ),
                      )),
                    ],
                    
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Error message
        if (state.error != null)
          _buildErrorMessage(state.error!, commentsProvider),
      ],
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading more comments...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error, CommentsProvider commentsProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[300],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              commentsProvider.clearError(widget.video.id);
              // Retry loading comments
              commentsProvider.loadComments(widget.video.id);
            },
            child: Text(
              'Retry',
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleReply(Comment comment, {Comment? replyToReply}) {
    widget.onResetTimeout?.call();
    
    final commentsProvider = Provider.of<CommentsProvider>(context, listen: false);
    
    // If replying to a reply, use the original comment as parent
    final targetUser = replyToReply?.author ?? comment.author;
    
    commentsProvider.setReplyingTo(
      widget.video.id,
      comment.id,
      targetUser,
    );
    
    // Show haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleLike(Comment comment, CommentsProvider commentsProvider, {bool isReply = false}) {
    widget.onResetTimeout?.call();
    
    commentsProvider.toggleCommentLike(
      widget.video.id,
      comment.id,
      isReply: isReply,
    );
    
    // Show haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleDelete(Comment comment, CommentsProvider commentsProvider, {Comment? parentComment}) {
    widget.onResetTimeout?.call();
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Comment',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this comment?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              commentsProvider.deleteComment(
                widget.video.id,
                comment.id,
                isReply: parentComment != null,
                parentCommentId: parentComment?.id,
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
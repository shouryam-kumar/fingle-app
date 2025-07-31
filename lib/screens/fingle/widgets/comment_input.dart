import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/video_models.dart';
import '../../../models/comment_models.dart';
import '../../../providers/comments_provider.dart';

class CommentInput extends StatefulWidget {
  final VideoPost video;
  final FocusNode focusNode;
  final VoidCallback? onResetTimeout;
  final VoidCallback? onSubmitted;

  const CommentInput({
    super.key,
    required this.video,
    required this.focusNode,
    this.onResetTimeout,
    this.onSubmitted,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  bool _hasText = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);

    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _sendButtonAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });

      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  Future<void> _submitComment() async {
    final content = _textController.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    widget.onResetTimeout?.call();

    setState(() {
      _isSubmitting = true;
    });

    final commentsProvider =
        Provider.of<CommentsProvider>(context, listen: false);
    final state = commentsProvider.getCommentsState(widget.video.id);
    final wasReplying = state.replyingToId != null;

    try {
      if (wasReplying) {
        // Replying to a comment
        await commentsProvider.replyToComment(
          widget.video.id,
          state.replyingToId!,
          content,
        );

        debugPrint('✅ Reply sent successfully');
      } else {
        // Adding a new comment
        await commentsProvider.addComment(widget.video.id, content);

        debugPrint('✅ Comment sent successfully');
      }

      // Clear input after sending
      _textController.clear();

      // Automatically clear reply state after successful submission
      if (wasReplying) {
        commentsProvider.clearReplyingTo(widget.video.id);
        debugPrint('🔄 Reply state cleared automatically after sending');
      }

      // Unfocus input
      widget.focusNode.unfocus();

      // Haptic feedback
      HapticFeedback.lightImpact();

      // Notify parent
      widget.onSubmitted?.call();
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _cancelReply() {
    // ✅ ENHANCED: Better cancel reply with explicit state management
    widget.onResetTimeout?.call();

    debugPrint('🔄 Cancel reply button clicked');

    final commentsProvider =
        Provider.of<CommentsProvider>(context, listen: false);

    // ✅ FORCE STATE UPDATE: Clear reply state and trigger rebuild
    try {
      commentsProvider.clearReplyingTo(widget.video.id);
      debugPrint('🔄 Reply state cleared in provider');

      // ✅ FORCE REBUILD: Ensure the UI updates immediately
      if (mounted) {
        setState(() {
          // This forces a rebuild of this widget to reflect the change
        });
      }

      debugPrint('🔄 UI state updated - reply indicator should disappear');
    } catch (e) {
      debugPrint('❌ Error clearing reply state: $e');
    }

    // ✅ DO NOT clear text - keep user's typed content
    // ✅ DO NOT unfocus - let user continue typing

    // Haptic feedback
    HapticFeedback.lightImpact();

    debugPrint('🔄 Reply cancelled - text preserved, indicator should be gone');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentsProvider>(
      builder: (context, commentsProvider, child) {
        final state = commentsProvider.getCommentsState(widget.video.id);
        final isReplying = state.replyingToId != null;

        // ✅ DEBUG: Log the current state
        debugPrint(
            '🔍 Build - isReplying: $isReplying, replyingToId: ${state.replyingToId}');

        return Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Reply indicator - conditionally shown
              if (isReplying) ...[
                _buildReplyIndicator(state, commentsProvider),
                const SizedBox(height: 8),
              ],

              // Input row
              Row(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: 14,
                    backgroundImage:
                        NetworkImage(commentsProvider.currentUser?.profilePic ?? 'https://via.placeholder.com/150'),
                    backgroundColor: Colors.grey[800],
                  ),

                  const SizedBox(width: 10),

                  // Input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.focusNode.hasFocus
                              ? AppColors.primary.withOpacity(0.4)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: widget.focusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: isReplying
                              ? 'Reply to ${state.replyingToUser?.name}...'
                              : 'Add a comment...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        maxLines: 3,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        onTap: widget.onResetTimeout,
                        onChanged: (_) => widget.onResetTimeout?.call(),
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  AnimatedBuilder(
                    animation: _sendButtonAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _sendButtonAnimation.value,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _hasText && !_isSubmitting
                                ? AppColors.primary
                                : Colors.grey[700],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _hasText && !_isSubmitting
                                ? _submitComment
                                : null,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    Icons.send,
                                    color: _hasText
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    size: 16,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplyIndicator(
      CommentsState state, CommentsProvider commentsProvider) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            color: AppColors.primary,
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Replying to ${state.replyingToUser?.name}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // ✅ ENHANCED: More robust cancel button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                debugPrint('🔄 X button tapped');
                _cancelReply();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

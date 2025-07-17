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

    final commentsProvider = Provider.of<CommentsProvider>(context, listen: false);
    final state = commentsProvider.getCommentsState(widget.video.id);

    try {
      if (state.replyingToId != null) {
        // Replying to a comment
        await commentsProvider.replyToComment(
          widget.video.id,
          state.replyingToId!,
          content,
        );
        
        // Clear replying state
        commentsProvider.clearReplyingTo(widget.video.id);
      } else {
        // Adding a new comment
        await commentsProvider.addComment(widget.video.id, content);
      }

      // Clear input and hide keyboard
      _textController.clear();
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
    widget.onResetTimeout?.call();
    final commentsProvider = Provider.of<CommentsProvider>(context, listen: false);
    commentsProvider.clearReplyingTo(widget.video.id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentsProvider>(
      builder: (context, commentsProvider, child) {
        final state = commentsProvider.getCommentsState(widget.video.id);
        final isReplying = state.replyingToId != null;
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reply indicator
              if (isReplying) ...[
                _buildReplyIndicator(state),
                const SizedBox(height: 12),
              ],
              
              // Input row
              Row(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(commentsProvider.currentUser.profilePic),
                    backgroundColor: Colors.grey[800],
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: widget.focusNode.hasFocus 
                              ? AppColors.primary.withOpacity(0.5)
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
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 4,
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _hasText && !_isSubmitting
                                ? AppColors.primary
                                : Colors.grey[700],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _hasText && !_isSubmitting ? _submitComment : null,
                            icon: _isSubmitting
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    Icons.send,
                                    color: _hasText ? Colors.white : Colors.white.withOpacity(0.5),
                                    size: 18,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              // Character count (optional)
              if (_textController.text.length > 50)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_textController.text.length}/500',
                      style: TextStyle(
                        color: _textController.text.length > 450
                            ? Colors.red[300]
                            : Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplyIndicator(CommentsState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replying to ${state.replyingToUser?.name}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: _cancelReply,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
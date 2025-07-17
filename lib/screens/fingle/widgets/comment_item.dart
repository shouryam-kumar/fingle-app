import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/video_models.dart';
import '../../../models/comment_models.dart';
import '../../../providers/comments_provider.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;
  final VideoPost video;
  final bool isReply;
  final VoidCallback? onResetTimeout;
  final VoidCallback? onReply;
  final VoidCallback? onLike;
  final VoidCallback? onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    required this.video,
    this.isReply = false,
    this.onResetTimeout,
    this.onReply,
    this.onLike,
    this.onDelete,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  
  bool _showFullContent = false;

  @override
  void initState() {
    super.initState();
    
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));

    // Check if content is long
    _showFullContent = widget.comment.content.length <= 80;
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    widget.onResetTimeout?.call();
    
    // Animate like button
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    
    widget.onLike?.call();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleReply() {
    widget.onResetTimeout?.call();
    widget.onReply?.call();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _handleDelete() {
    widget.onResetTimeout?.call();
    widget.onDelete?.call();
  }

  void _toggleExpanded() {
    setState(() {
      _showFullContent = !_showFullContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentsProvider = Provider.of<CommentsProvider>(context);
    final currentUser = commentsProvider.currentUser;
    final isOwnComment = widget.comment.author.id == currentUser.id;
    final isVideoCreator = widget.comment.author.id == widget.video.creator.id;

    return Container(
      margin: EdgeInsets.only(
        bottom: widget.comment.isPinned ? 12 : 8,
        top: widget.comment.isPinned ? 6 : 0,
      ),
      padding: const EdgeInsets.all(10), // More compact padding
      decoration: BoxDecoration(
        color: widget.comment.isPinned 
            ? AppColors.primary.withOpacity(0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: widget.comment.isPinned
            ? Border.all(
                color: AppColors.primary.withOpacity(0.25), 
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned indicator
          if (widget.comment.isPinned && !widget.isReply)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.push_pin,
                    size: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    'Pinned',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          
          // Main comment content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildAvatar(),
              
              const SizedBox(width: 10),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info
                    _buildUserInfo(isVideoCreator),
                    
                    const SizedBox(height: 3),
                    
                    // Comment content
                    _buildCommentContent(),
                    
                    const SizedBox(height: 6),
                    
                    // Actions
                    _buildActions(isOwnComment),
                  ],
                ),
              ),
              
              // Like button
              _buildLikeButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () {
        widget.onResetTimeout?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('View ${widget.comment.author.name}\'s profile'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: widget.isReply ? 24 : 28,
        height: widget.isReply ? 24 : 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.comment.author.isVerified 
                ? AppColors.primary 
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: CircleAvatar(
          radius: widget.isReply ? 10 : 12,
          backgroundImage: NetworkImage(widget.comment.author.profilePic),
          backgroundColor: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildUserInfo(bool isVideoCreator) {
    return Row(
      children: [
        // Username
        Text(
          widget.comment.author.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.isReply ? 12 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Verified badge
        if (widget.comment.author.isVerified) ...[
          const SizedBox(width: 3),
          Icon(
            Icons.verified,
            color: AppColors.primary,
            size: widget.isReply ? 10 : 12,
          ),
        ],
        
        // Creator badge
        if (isVideoCreator) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Creator',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 7,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        
        // Time ago
        const SizedBox(width: 6),
        Text(
          widget.comment.timeAgo,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: widget.isReply ? 10 : 11,
          ),
        ),
        
        // Edited indicator
        if (widget.comment.isEdited) ...[
          const SizedBox(width: 3),
          Text(
            '(edited)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: widget.isReply ? 9 : 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentContent() {
    final content = widget.comment.content;
    final shouldTruncate = content.length > 80 && !_showFullContent;
    final displayContent = shouldTruncate 
        ? '${content.substring(0, 80)}...' 
        : content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment text
        _buildFormattedText(displayContent),
        
        // Show more/less button
        if (content.length > 80)
          GestureDetector(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                _showFullContent ? 'Show less' : 'Show more',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormattedText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: widget.isReply ? 12 : 13,
        height: 1.2,
      ),
    );
  }

  Widget _buildActions(bool isOwnComment) {
    return Row(
      children: [
        // Reply button
        if (!widget.isReply)
          InkWell(
            onTap: _handleReply,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: Text(
                'Reply',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        
        // Delete button (only for own comments)
        if (isOwnComment) ...[
          const SizedBox(width: 12),
          InkWell(
            onTap: _handleDelete,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLikeButton() {
    return AnimatedBuilder(
      animation: _likeAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _likeScaleAnimation.value,
          child: GestureDetector(
            onTap: _handleLike,
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.comment.isLiked 
                        ? Icons.favorite 
                        : Icons.favorite_border,
                    color: widget.comment.isLiked 
                        ? Colors.red 
                        : Colors.white.withOpacity(0.6),
                    size: widget.isReply ? 14 : 16,
                  ),
                  
                  if (widget.comment.likes > 0) ...[
                    const SizedBox(height: 1),
                    Text(
                      _formatLikeCount(widget.comment.likes),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatLikeCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
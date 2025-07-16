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
  late Animation<double> _likeOpacityAnimation;
  
  bool _isExpanded = false;
  bool _showFullContent = false;

  @override
  void initState() {
    super.initState();
    
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _likeOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.easeOut,
    ));

    // Check if content is long
    _showFullContent = widget.comment.content.length <= 100;
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.comment.isPinned 
            ? AppColors.primary.withOpacity(0.05) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: widget.comment.isPinned
            ? Border.all(color: AppColors.primary.withOpacity(0.2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned indicator
          if (widget.comment.isPinned && !widget.isReply)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pinned',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info and content
                    _buildUserInfo(isVideoCreator),
                    
                    const SizedBox(height: 4),
                    
                    // Comment content
                    _buildCommentContent(),
                    
                    const SizedBox(height: 8),
                    
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
        // TODO: Navigate to user profile
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('View ${widget.comment.author.name}\'s profile'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: widget.isReply ? 28 : 32,
        height: widget.isReply ? 28 : 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.comment.author.isVerified 
                ? AppColors.primary 
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: widget.isReply ? 12 : 14,
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
            fontSize: widget.isReply ? 13 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Verified badge
        if (widget.comment.author.isVerified) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.verified,
            color: AppColors.primary,
            size: widget.isReply ? 12 : 14,
          ),
        ],
        
        // Creator badge
        if (isVideoCreator) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Creator',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        
        // Time ago
        const SizedBox(width: 8),
        Text(
          widget.comment.timeAgo,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: widget.isReply ? 11 : 12,
          ),
        ),
        
        // Edited indicator
        if (widget.comment.isEdited) ...[
          const SizedBox(width: 4),
          Text(
            '(edited)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: widget.isReply ? 10 : 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentContent() {
    final content = widget.comment.content;
    final shouldTruncate = content.length > 100 && !_showFullContent;
    final displayContent = shouldTruncate 
        ? '${content.substring(0, 100)}...' 
        : content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment text with mention highlighting
        _buildFormattedText(displayContent),
        
        // Show more/less button
        if (content.length > 100)
          GestureDetector(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _showFullContent ? 'Show less' : 'Show more',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormattedText(String text) {
    // Simple mention highlighting
    final mentionRegex = RegExp(r'@(\w+)');
    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in mentionRegex.allMatches(text)) {
      // Add text before mention
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: widget.isReply ? 13 : 14,
          ),
        ));
      }
      
      // Add mention
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
          color: AppColors.primary,
          fontSize: widget.isReply ? 13 : 14,
          fontWeight: FontWeight.w600,
        ),
      ));
      
      lastIndex = match.end;
    }
    
    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: widget.isReply ? 13 : 14,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildActions(bool isOwnComment) {
    return Row(
      children: [
        // Reply button
        if (!widget.isReply)
          GestureDetector(
            onTap: _handleReply,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Reply',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        
        // Delete button (only for own comments)
        if (isOwnComment) ...[
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _handleDelete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red.withOpacity(0.7),
                  fontSize: 12,
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
          child: Opacity(
            opacity: _likeOpacityAnimation.value,
            child: GestureDetector(
              onTap: _handleLike,
              child: Container(
                padding: const EdgeInsets.all(8),
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
                      size: widget.isReply ? 16 : 18,
                    ),
                    
                    if (widget.comment.likes > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatLikeCount(widget.comment.likes),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
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
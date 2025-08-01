import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/home_models.dart';
import '../models/reaction_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../screens/fingle/widgets/reaction_button.dart';
import '../screens/fingle/widgets/enhanced_reaction_picker.dart';
import '../models/post_action.dart';
import 'action_button.dart';
import 'video_player_post.dart';
import 'common/enhanced_glassmorphic_modal.dart';

class PostCard extends StatefulWidget {
  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onRecommend;
  final VoidCallback? onUserTap;
  final Function(ReactionType)? onReactionSelected;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.onRecommend,
    this.onUserTap,
    this.onReactionSelected,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  Function(bool)? _videoVisibilityHandler;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _onLike() {
    _likeController.forward().then((_) {
      _likeController.reverse();
    });
    widget.onLike?.call();
  }

  void _handleVideoVisibilityChanged(bool isVisible) {
    // This will be called when video visibility changes
    debugPrint(
        '📹 PostCard: Video ${widget.post.id} visibility changed: $isVisible');

    // Call the VideoPlayerPost's visibility handler if available
    _videoVisibilityHandler?.call(isVisible);
  }

  void _handleMenuAction(String action) {
    if (!mounted) return;
    debugPrint(
        '📋 PostCard: Menu action selected: $action for @${widget.post.userName}');

    switch (action) {
      case 'report':
        debugPrint(
            '🚩 Reporting post ${widget.post.id} by @${widget.post.userName}');
        _showActionSnackBar(
          icon: Icons.flag,
          message: 'Post reported successfully',
          backgroundColor: Colors.orange.shade700,
        );
        break;
      case 'invite':
        debugPrint('👥 Inviting @${widget.post.userName} to LockerRoom');
        _showActionSnackBar(
          icon: Icons.group_add,
          message: 'Invitation sent to LockerRoom',
          backgroundColor: AppColors.success,
        );
        break;
      case 'unfollow':
        debugPrint('👤 Unfollowing @${widget.post.userName}');
        _showActionSnackBar(
          icon: Icons.person_remove,
          message: 'You have unfollowed @${widget.post.userName}',
          backgroundColor: AppColors.warning,
        );
        break;
      case 'mute':
        debugPrint('🔇 Muting @${widget.post.userName}');
        _showActionSnackBar(
          icon: Icons.volume_off,
          message: 'You have muted @${widget.post.userName}',
          backgroundColor: AppColors.textSecondary,
        );
        break;
    }
  }

  void _showActionSnackBar({
    required IconData icon,
    required String message,
    required Color backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  List<PostAction> _getPostActions() {
    return [
      PostAction(
        type: PostActionType.report,
        title: 'Report',
        subtitle: 'Report this post',
        icon: Icons.flag_outlined,
        iconColor: Colors.orange.shade700,
        onPressed: () => _handleMenuAction('report'),
      ),
      PostAction(
        type: PostActionType.invite,
        title: 'Invite to LockerRoom',
        subtitle: 'Send invitation',
        icon: Icons.group_add_outlined,
        iconColor: AppColors.success,
        onPressed: () => _handleMenuAction('invite'),
      ),
      PostAction(
        type: PostActionType.unfollow,
        title: 'Unfollow',
        subtitle: '@${widget.post.userName}',
        icon: Icons.person_remove_outlined,
        iconColor: AppColors.warning,
        onPressed: () => _handleMenuAction('unfollow'),
      ),
      PostAction(
        type: PostActionType.mute,
        title: 'Mute',
        subtitle: 'Hide posts from this user',
        icon: Icons.volume_off_outlined,
        iconColor: AppColors.textSecondary,
        onPressed: () => _handleMenuAction('mute'),
      ),
    ];
  }

  void _showGlassmorphicModal() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) => EnhancedGlassmorphicModal(
        actions: _getPostActions(),
        userName: widget.post.userName,
        onClose: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onUserTap,
          child: Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.post.userAvatar,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.post.userName,
                        style: AppTextStyles.postUserName.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (widget.post.userVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          color: AppColors.secondary,
                          size: 16,
                        ),
                      ],
                      if (widget.post.userOpenToMingle) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'MINGLE',
                            style: AppTextStyles.postCategory.copyWith(
                              color: AppColors.accent,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        widget.post.timeAgo,
                        style: AppTextStyles.postTimeAgo.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          widget.post.category.toUpperCase(),
                          style: AppTextStyles.postCategory.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _showGlassmorphicModal,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassMorphism,
            ),
            child: Icon(
              Icons.more_horiz,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show text content for non-canvas posts
        if (widget.post.postType != PostType.canvas &&
            widget.post.content.isNotEmpty) ...[
          Text(
            widget.post.content,
            style: AppTextStyles.postContent.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Content based on post type
        if (widget.post.postType == PostType.canvas)
          _buildCanvasContent()
        else if (widget.post.postType == PostType.video ||
            widget.post.postType == PostType.videoReel)
          _buildVideoContent()
        else if (widget.post.postType == PostType.carousel)
          _buildCarouselContent()
        else if (widget.post.postType == PostType.photo)
          _buildPhotoContent(),
      ],
    );
  }

  Widget _buildCanvasContent() {
    if (widget.post.canvasData == null) return const SizedBox.shrink();

    final canvas = widget.post.canvasData!;
    Color bgColor = AppColors.primary;

    // Parse background color from hex string
    if (canvas.backgroundColor != null) {
      try {
        bgColor =
            Color(int.parse(canvas.backgroundColor!.replaceFirst('#', '0xFF')));
      } catch (e) {
        bgColor = AppColors.primary;
      }
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 150,
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        gradient: canvas.backgroundImageUrl == null
            ? null
            : LinearGradient(
                colors: [bgColor.withOpacity(0.8), bgColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            canvas.text,
            style: AppTextStyles.postContent.copyWith(
              color: canvas.textColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (widget.post.mediaItems == null || widget.post.mediaItems!.isEmpty) {
      return const SizedBox.shrink();
    }

    final media = widget.post.mediaItems!.first;
    final isReel = widget.post.postType == PostType.videoReel;

    return VisibilityDetector(
      key: Key('video_post_${widget.post.id}'),
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        final isVisible = visiblePercentage > 50.0; // 50% threshold
        _handleVideoVisibilityChanged(isVisible);
      },
      child: VideoPlayerPost(
        mediaItem: media,
        isReel: isReel,
        autoPlay: false, // Start paused for better UX
        isMuted: true, // Start muted for better UX
        onTap: () {
          // Video play/pause is handled by VideoPlayerPost
        },
        onDoubleTap: () {
          // Double-tap to like
          widget.onLike?.call();
          _onLike();
        },
        onViewportVisibilityChanged: (handler) {
          // Store the handler so we can call it when visibility changes
          _videoVisibilityHandler = handler;
        },
      ),
    );
  }

  Widget _buildCarouselContent() {
    if (widget.post.mediaItems == null || widget.post.mediaItems!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: PageView.builder(
          itemCount: widget.post.mediaItems!.length,
          itemBuilder: (context, index) {
            final media = widget.post.mediaItems![index];
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: media.url,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.image,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.error,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhotoContent() {
    // Use imageUrl for backward compatibility or mediaItems for new posts
    String? imageUrl = widget.post.imageUrl;
    if (widget.post.mediaItems != null && widget.post.mediaItems!.isNotEmpty) {
      imageUrl = widget.post.mediaItems!.first.url;
    }

    if (imageUrl == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 150,
          maxHeight: MediaQuery.of(context).size.height * 0.25,
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 150,
              maxHeight: MediaQuery.of(context).size.height * 0.25,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.image,
              color: AppColors.primary,
              size: 48,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 150,
              maxHeight: MediaQuery.of(context).size.height * 0.25,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.error,
              color: AppColors.primary,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 320;
        
        if (isSmallScreen) {
          // For very small screens, use Wrap to prevent overflow
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Reaction button (like with emoji picker)
              SizedBox(
                width: 60,
                height: 60,
                child: ReactionButton(
                  reactionSummary: widget.post.reactionSummary,
                  onReactionSelected: (ReactionType type) {
                    widget.onReactionSelected?.call(type);
                    // Remove animation for reactions - looks bad
                  },
                  onViewReactions: () {
                    // TODO: Show reaction details
                  },
                  pickerLayout: ReactionPickerLayout.horizontal,
                  useHomeSize: true,
                ),
              ),
              // Recommend button
              ActionButton(
                icon: Icons.keyboard_arrow_up_outlined,
                activeIcon: Icons.keyboard_arrow_up,
                count: widget.post.recommendations,
                isActive: widget.post.isRecommended,
                activeColor: AppColors.success,
                showAnimation: true,
                onTap: () {
                  widget.onRecommend?.call();
                  _onLike(); // Use the same animation for recommend
                },
              ),
              // Comment button
              ActionButton(
                icon: Icons.comment_outlined,
                count: widget.post.comments,
                onTap: widget.onComment,
              ),
              // Share button
              ActionButton(
                icon: Icons.share_outlined,
                count: widget.post.shares,
                onTap: widget.onShare,
              ),
              // Bookmark button
              ActionButton(
                icon: Icons.bookmark_border,
                activeIcon: Icons.bookmark,
                isActive: widget.post.isBookmarked,
                activeColor: AppColors.warning,
                onTap: widget.onBookmark,
              ),
            ],
          );
        }
        
        // For larger screens, use Row with Spacer
        return Row(
          children: [
            // Reaction button (like with emoji picker)
            SizedBox(
              width: 60,
              height: 60,
              child: ReactionButton(
                reactionSummary: widget.post.reactionSummary,
                onReactionSelected: (ReactionType type) {
                  widget.onReactionSelected?.call(type);
                  // Remove animation for reactions - looks bad
                },
                onViewReactions: () {
                  // TODO: Show reaction details
                },
                pickerLayout: ReactionPickerLayout.horizontal,
                useHomeSize: true,
              ),
            ),
            const SizedBox(width: 8),

            // Recommend button
            ActionButton(
              icon: Icons.keyboard_arrow_up_outlined,
              activeIcon: Icons.keyboard_arrow_up,
              count: widget.post.recommendations,
              isActive: widget.post.isRecommended,
              activeColor: AppColors.success,
              showAnimation: true,
              onTap: () {
                widget.onRecommend?.call();
                _onLike(); // Use the same animation for recommend
              },
            ),
            const SizedBox(width: 8),

            // Comment button
            ActionButton(
              icon: Icons.comment_outlined,
              count: widget.post.comments,
              onTap: widget.onComment,
            ),
            const SizedBox(width: 8),

            // Share button
            ActionButton(
              icon: Icons.share_outlined,
              count: widget.post.shares,
              onTap: widget.onShare,
            ),
            const Spacer(),

            // Bookmark button
            ActionButton(
              icon: Icons.bookmark_border,
              activeIcon: Icons.bookmark,
              isActive: widget.post.isBookmarked,
              activeColor: AppColors.warning,
              onTap: widget.onBookmark,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.postCardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.glassShadow,
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(),
                  const SizedBox(height: 12),
                  _buildContent(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/home_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'video_player_post.dart';

class PostCard extends StatefulWidget {
  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onRecommend;
  final VoidCallback? onUserTap;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onBookmark,
    this.onRecommend,
    this.onUserTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _likeController,
      curve: Curves.elasticOut,
    ));
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

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
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
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.more_horiz,
            color: AppColors.textSecondary,
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
      height: 200,
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
    if (widget.post.mediaItems == null || widget.post.mediaItems!.isEmpty)
      return const SizedBox.shrink();

    final media = widget.post.mediaItems!.first;
    final isReel = widget.post.postType == PostType.videoReel;

    return VideoPlayerPost(
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
    );
  }

  Widget _buildCarouselContent() {
    if (widget.post.mediaItems == null || widget.post.mediaItems!.isEmpty)
      return const SizedBox.shrink();

    return SizedBox(
      height: 250,
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
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: double.infinity,
          height: 180,
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
          height: 180,
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Like button
        GestureDetector(
          onTap: _onLike,
          child: AnimatedBuilder(
            animation: _likeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _likeAnimation.value,
                child: Row(
                  children: [
                    Icon(
                      widget.post.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.post.isLiked
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatCount(widget.post.likes),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 20),

        // Comment button
        GestureDetector(
          onTap: widget.onComment,
          child: Row(
            children: [
              Icon(
                Icons.comment_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                _formatCount(widget.post.comments),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // Share button
        GestureDetector(
          onTap: widget.onShare,
          child: Row(
            children: [
              Icon(
                Icons.share_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                _formatCount(widget.post.shares),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // Recommend button
        GestureDetector(
          onTap: widget.onRecommend,
          child: Row(
            children: [
              Icon(
                widget.post.isRecommended
                    ? Icons.thumb_up
                    : Icons.thumb_up_outlined,
                color: widget.post.isRecommended
                    ? AppColors.success
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                _formatCount(widget.post.recommendations),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        // Bookmark button
        GestureDetector(
          onTap: widget.onBookmark,
          child: Icon(
            widget.post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: widget.post.isBookmarked
                ? AppColors.warning
                : AppColors.textSecondary,
            size: 20,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassMorphism,
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

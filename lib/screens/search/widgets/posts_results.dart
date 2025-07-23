import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../models/home_models.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_badge.dart';

class PostsResults extends StatelessWidget {
  const PostsResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final postResults = searchProvider.filteredResults;

        if (postResults.isEmpty) {
          return _buildEmptyState();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Get device pixel ratio for high-DPI screen adjustments
            final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
            
            // Calculate precise content height requirements
            const double imageHeight = 120;
            const double contentPadding = 24; // 12px top + 12px bottom
            const double badgeHeight = 22; // GlassBadge small size
            const double badgeSpacing = 6;
            const double titleHeight = 42; // Increased for bold text (18px × 2 lines + 6px buffer)
            const double titleSpacing = 4;
            const double creatorHeight = 20; // CircleAvatar + text
            const double statsHeight = 16; // Engagement stats
            const double deviceBuffer = 26; // Increased for Android device compatibility
            const double precisionBuffer = 6; // Increased buffer for emoji and special characters
            
            // Calculate total height with precision-safe rounding
            final double baseHeight = imageHeight + 
                                    contentPadding + 
                                    badgeHeight + 
                                    badgeSpacing + 
                                    titleHeight + 
                                    titleSpacing + 
                                    creatorHeight + 
                                    statsHeight + 
                                    deviceBuffer + 
                                    precisionBuffer;
            
            // Adjust for high-DPI screens and use ceiling to avoid sub-pixel issues
            final double adjustedHeight = (baseHeight * (devicePixelRatio > 2 ? 1.02 : 1.0));
            final double mainAxisExtent = adjustedHeight.ceilToDouble();
            
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: mainAxisExtent, // Use fixed height instead of aspect ratio
              ),
              itemCount: postResults.length,
              itemBuilder: (context, index) {
                final result = postResults[index];
                if (result.post != null) {
                  return _PostCard(post: result.post!);
                } else if (result.video != null) {
                  return _VideoCard(post: result.video!);
                }
                return const SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_view_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No posts found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching for workouts or fitness content',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final FeedPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: GlassContainer(
            borderRadius: 16,
            padding: EdgeInsets.zero,
            hasHoverEffect: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post image/content
                _buildPostImage(),
                
                // Content with overflow-safe constraints
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 100, // Minimum content height
                      maxHeight: (constraints.maxHeight - 120).clamp(100, double.infinity), // Safe height calculation
                    ),
                    child: ClipRect(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Content type badge
                              _buildContentTypeBadge(),
                              
                              const SizedBox(height: 6),
                              
                              // Title with fixed height constraints and enhanced overflow protection
                              SizedBox(
                                height: 40, // Fixed height for 2 lines of bold text
                                child: ClipRect(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 40,
                                      minHeight: 36,
                                    ),
                                    child: Text(
                                      post.content,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        height: 1.3, // Explicit line height for consistency
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textHeightBehavior: const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Creator info with height constraints
                              SizedBox(
                                height: 18, // Fixed height for creator info
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 8,
                                      backgroundImage: NetworkImage(post.userAvatar),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: ClipRect(
                                        child: Text(
                                          post.userName,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                            height: 1.2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const Spacer(),
                              
                              // Engagement stats
                              _buildEngagementStats(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Container(
        height: 120,
        width: double.infinity,
        child: post.mediaItems?.isNotEmpty == true
            ? Image.network(
                post.mediaItems!.first.url,
                fit: BoxFit.cover,
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: AppColors.oceanGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.article,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContentTypeBadge() {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (post.postType) {
      case PostType.photo:
        badgeColor = AppColors.accent;
        badgeText = 'PHOTO';
        badgeIcon = Icons.photo;
        break;
      case PostType.video:
        badgeColor = AppColors.primary;
        badgeText = 'VIDEO';
        badgeIcon = Icons.play_arrow;
        break;
      case PostType.canvas:
        badgeColor = AppColors.secondary;
        badgeText = 'CANVAS';
        badgeIcon = Icons.brush;
        break;
      case PostType.carousel:
        badgeColor = AppColors.warning;
        badgeText = 'CAROUSEL';
        badgeIcon = Icons.view_carousel;
        break;
      case PostType.videoReel:
        badgeColor = AppColors.success;
        badgeText = 'BITES';
        badgeIcon = Icons.movie;
        break;
      default:
        badgeColor = AppColors.textSecondary;
        badgeText = 'POST';
        badgeIcon = Icons.article;
        break;
    }

    return GlassBadge(
      text: badgeText,
      style: GlassBadgeStyle.secondary,
      customColor: badgeColor,
      // customBackgroundColor not supported in current API
      prefixIcon: Icon(badgeIcon, size: 12),
      size: GlassBadgeSize.small,
      // padding parameter not supported in current API - handled by size
    );
  }

  Widget _buildEngagementStats() {
    return SizedBox(
      height: 16, // Fixed height for engagement stats
      child: ClipRect(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: _buildStatItem(Icons.favorite_border, post.likes.toString())),
            const SizedBox(width: 8),
            Flexible(child: _buildStatItem(Icons.comment_outlined, post.comments.toString())),
            const SizedBox(width: 8),
            Flexible(child: _buildStatItem(Icons.share_outlined, post.shares.toString())),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return SizedBox(
      height: 14, // Fixed height for stat items
      child: ClipRect(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 2),
            Text(
              count,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final post; // VideoPost from video_models.dart

  const _VideoCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: GlassContainer(
            borderRadius: 16,
            padding: EdgeInsets.zero,
            hasHoverEffect: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        child: Image.network(
                          post.thumbnailUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // Play button overlay
                      const Positioned.fill(
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      // Duration badge
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatDuration(post.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content with overflow-safe constraints
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 100, // Minimum content height
                      maxHeight: (constraints.maxHeight - 120).clamp(100, double.infinity), // Safe height calculation
                    ),
                    child: ClipRect(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Video type and difficulty badges
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GlassBadge(
                                    text: 'LIVE',
                                    style: GlassBadgeStyle.secondary,
                                    customColor: AppColors.error,
                                    size: GlassBadgeSize.small,
                                  ),
                                  
                                  if (post.difficulty != null) ...[
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: GlassBadge(
                                        text: post.difficulty!.toUpperCase(),
                                        style: GlassBadgeStyle.secondary,
                                        customColor: _getDifficultyColor(post.difficulty!),
                                        size: GlassBadgeSize.small,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                  
                              const SizedBox(height: 6),
                              
                              // Title with fixed height constraints and enhanced overflow protection
                              SizedBox(
                                height: 40, // Fixed height for 2 lines of bold text
                                child: ClipRect(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 40,
                                      minHeight: 36,
                                    ),
                                    child: Text(
                                      post.title ?? 'Fitness Video',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        height: 1.3, // Explicit line height for consistency
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textHeightBehavior: const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Creator info with height constraints
                              SizedBox(
                                height: 18, // Fixed height for creator info
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 8,
                                      backgroundImage: NetworkImage(post.creator.profilePic),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: ClipRect(
                                        child: Text(
                                          post.creator.name,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                            height: 1.2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const Spacer(),
                              
                              // Video stats
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(child: _buildStatItem(Icons.visibility_outlined, post.views.toString())),
                                  const SizedBox(width: 6),
                                  Flexible(child: _buildStatItem(Icons.favorite_border, post.likes.toString())),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildStatItem(IconData icon, String count) {
    return SizedBox(
      height: 14, // Fixed height for stat items
      child: ClipRect(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 2),
            Text(
              _formatNumber(int.parse(count)),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
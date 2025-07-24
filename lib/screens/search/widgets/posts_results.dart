import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
        
        // Debug logging to diagnose data flow
        debugPrint('🔍 PostsResults: Current tab = ${searchProvider.currentTab}');
        debugPrint('🔍 PostsResults: All results count = ${searchProvider.searchResults.length}');
        debugPrint('🔍 PostsResults: Filtered results count = ${postResults.length}');
        debugPrint('🔍 PostsResults: Post types = ${postResults.map((r) => r.type).toList()}');

        if (postResults.isEmpty) {
          debugPrint('🔍 PostsResults: Showing empty state');
          return _buildEmptyState();
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive grid configuration like all_results_feed.dart
              int crossAxisCount;
              double spacing;

              if (constraints.maxWidth >= 600) {
                crossAxisCount = 3;
                spacing = 16;
              } else if (constraints.maxWidth >= 360) {
                crossAxisCount = 2;
                spacing = 12;
              } else {
                crossAxisCount = 1;
                spacing = 10;
              }

              return MasonryGridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
          ),
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
    return GlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      hasHoverEffect: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post image/content
          _buildPostImage(),

          // Content with responsive layout
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Content type badge
                _buildContentTypeBadge(),

                const SizedBox(height: 6),

                // Title
                Text(
                  post.content,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Creator info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundImage: NetworkImage(post.userAvatar),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post.userName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Engagement stats
                _buildEngagementStats(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive height based on available width
          final imageHeight =
              constraints.maxWidth * 0.6; // 60% of width for better proportions
          return SizedBox(
            height: imageHeight.clamp(80.0, 140.0), // Min 80px, max 140px
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
          );
        },
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
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildStatItem(Icons.favorite_border, post.likes.toString()),
        _buildStatItem(Icons.comment_outlined, post.comments.toString()),
        _buildStatItem(Icons.share_outlined, post.shares.toString()),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
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
          ),
        ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final post; // VideoPost from video_models.dart

  const _VideoCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate responsive height based on available width
                final imageHeight = constraints.maxWidth * 0.6; // 60% of width
                return SizedBox(
                  height: imageHeight.clamp(80.0, 140.0), // Min 80px, max 140px
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
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
                );
              },
            ),
          ),

          // Content with responsive layout
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Video type and difficulty badges
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    GlassBadge(
                      text: 'LIVE',
                      style: GlassBadgeStyle.secondary,
                      customColor: AppColors.error,
                      size: GlassBadgeSize.small,
                    ),
                    if (post.difficulty != null)
                      GlassBadge(
                        text: post.difficulty!.toUpperCase(),
                        style: GlassBadgeStyle.secondary,
                        customColor: _getDifficultyColor(post.difficulty!),
                        size: GlassBadgeSize.small,
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Title
                Text(
                  post.title ?? 'Fitness Video',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Creator info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundImage: NetworkImage(post.creator.profilePic),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post.creator.name,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Video stats
                Wrap(
                  spacing: 6,
                  children: [
                    _buildStatItem(Icons.visibility_outlined,
                        post.views.toString()),
                    _buildStatItem(
                        Icons.favorite_border, post.likes.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
    return Row(
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
          ),
        ),
      ],
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

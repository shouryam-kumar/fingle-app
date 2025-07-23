import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/glass_badge.dart';

class TrendingResults extends StatefulWidget {
  const TrendingResults({super.key});

  @override
  State<TrendingResults> createState() => _TrendingResultsState();
}

class _TrendingResultsState extends State<TrendingResults>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final trendingResults = _getTrendingResults(searchProvider);

        if (trendingResults.isEmpty) {
          return _buildEmptyState();
        }

        return CustomScrollView(
          slivers: [
            // Trending header with live updates
            SliverToBoxAdapter(
              child: _buildTrendingHeader(searchProvider),
            ),

            // Trending timeline
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final trendingItem = trendingResults[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: index == trendingResults.length - 1 ? 20 : 16,
                    ),
                    child: _buildTrendingCard(trendingItem, index),
                  );
                },
                childCount: trendingResults.length,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendingHeader(SearchProvider searchProvider) {
    final trendingMetrics = searchProvider.trendingMetrics;
    final topTrending = trendingMetrics.isNotEmpty ? trendingMetrics.first : null;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.veryActiveGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.veryActiveGreen.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              const Text(
                'Trending Now',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 60, // Fixed reasonable width for LIVE badge
                ),
                child: GlassBadge(
                  text: 'LIVE',
                  style: GlassBadgeStyle.success,
                  size: GlassBadgeSize.small,
                  isPulsing: true,
                  hasGlow: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (topTrending != null)
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              intensity: GlassIntensity.medium,
              elevation: GlassElevation.medium,
              customTint: AppColors.veryActiveGreen.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: AppColors.veryActiveGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Top Trending',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      GlassBadge(
                        text: '${(topTrending.trendingScore * 100).round()}%',
                        style: GlassBadgeStyle.success,
                        size: GlassBadgeSize.small,
                        hasGlow: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    topTrending.trendingReason,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(TrendingItem item, int index) {
    final rank = index + 1;
    final isTopThree = rank <= 3;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: double.infinity,
      ),
      child: GlassContainer(
        borderRadius: 20,
        intensity: GlassIntensity.medium,
        elevation: isTopThree ? GlassElevation.high : GlassElevation.medium,
        hasHoverEffect: true,
        customTint: _getTrendingRankColor(rank).withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ranking badge
              _buildRankingBadge(rank),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTrendingContent(item),
                    
                    const SizedBox(height: 8),
                    
                    _buildTrendingMetrics(item.metrics),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action button
              SizedBox(
                width: 80,
                child: _buildTrendingAction(item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankingBadge(int rank) {
    final isTopThree = rank <= 3;
    final color = _getTrendingRankColor(rank);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingContent(TrendingItem item) {
    final result = item.result;
    
    switch (result.type) {
      case SearchResultType.people:
        return _buildUniformContent(
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(result.user!.profilePic),
          ),
          title: result.user!.name,
          subtitle: '${result.user!.followers} followers • ${result.user!.stats.totalPosts} posts',
          badges: [
            GlassBadge(
              text: 'Person',
              style: GlassBadgeStyle.secondary,
              size: GlassBadgeSize.small,
            ),
            if (result.user!.openToMingle)
              GlassBadge.mingle(size: GlassBadgeSize.small),
          ],
        );
      case SearchResultType.topics:
        return _buildUniformContent(
          leading: Text(
            result.topic!.emoji,
            style: const TextStyle(fontSize: 32),
          ),
          title: result.topic!.name,
          subtitle: '${result.topic!.analytics.postsLast24h} posts • ${result.topic!.analytics.activeUsers} active users',
          badges: [
            GlassBadge(
              text: 'Topic',
              style: GlassBadgeStyle.secondary,
              size: GlassBadgeSize.small,
            ),
          ],
        );
      case SearchResultType.communities:
        return _buildUniformContent(
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(result.community!.imageUrl),
          ),
          title: result.community!.name,
          subtitle: '${result.community!.memberCount} members • ${result.community!.postsToday} posts today',
          badges: [
            GlassBadge(
              text: 'Community',
              style: GlassBadgeStyle.success,
              size: GlassBadgeSize.small,
            ),
          ],
        );
      case SearchResultType.posts:
        return _buildUniformContent(
          leading: const Icon(
            Icons.article,
            color: AppColors.info,
            size: 28,
          ),
          title: 'Trending Post',
          subtitle: 'High engagement content with viral potential',
          badges: [
            GlassBadge(
              text: 'Post',
              style: GlassBadgeStyle.custom,
              customColor: AppColors.info,
              size: GlassBadgeSize.small,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUniformContent({
    required Widget leading,
    required String title,
    required String subtitle,
    required List<Widget> badges,
  }) {
    return Row(
      children: [
        leading,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (badges.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: badges,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }





  Widget _buildTrendingMetrics(TrendingMetrics metrics) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _buildMetricChip(
          Icons.trending_up,
          '${(metrics.trendingScore * 100).round()}%',
          AppColors.veryActiveGreen,
        ),
        _buildMetricChip(
          Icons.people,
          '${metrics.engagementRate}',
          AppColors.accent,
        ),
        _buildMetricChip(
          Icons.schedule,
          _formatTimeAgo(metrics.lastUpdated),
          AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildMetricChip(IconData icon, String value, Color color) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 100, // Fixed reasonable max width
        minWidth: 50,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingAction(TrendingItem item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Handle infinite or invalid constraints
        final availableWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 30
            ? constraints.maxWidth
            : 80.0; // Fallback width
            
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: availableWidth,
              child: GlassButton(
                text: 'View',
                style: GlassButtonStyle.primary,
                size: GlassButtonSize.small,
                onPressed: () {
                  // Navigate to content
                },
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: availableWidth,
              child: GlassButton(
                text: _getActionText(item.result.type),
                style: GlassButtonStyle.success,
                size: GlassButtonSize.small,
                isOutlined: true,
                onPressed: () {
                  // Perform type-specific action
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _getActionText(SearchResultType type) {
    switch (type) {
      case SearchResultType.people:
        return 'Follow';
      case SearchResultType.topics:
        return 'Follow';
      case SearchResultType.communities:
        return 'Join';
      case SearchResultType.posts:
        return 'Like';
      default:
        return 'View';
    }
  }

  Color _getTrendingRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    if (rank <= 10) return AppColors.veryActiveGreen;
    return AppColors.textSecondary;
  }

  List<TrendingItem> _getTrendingResults(SearchProvider searchProvider) {
    final trendingMetrics = searchProvider.trendingMetrics;
    final filteredResults = searchProvider.filteredResults;
    
    final trendingItems = <TrendingItem>[];
    
    // Match trending metrics with filtered results
    for (int i = 0; i < trendingMetrics.length && i < filteredResults.length; i++) {
      trendingItems.add(TrendingItem(
        result: filteredResults[i],
        metrics: trendingMetrics[i],
      ));
    }
    
    return trendingItems;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No trending content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for trending updates',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class TrendingItem {
  final SearchResult result;
  final TrendingMetrics metrics;

  TrendingItem({
    required this.result,
    required this.metrics,
  });
}
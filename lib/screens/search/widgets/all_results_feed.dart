import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../models/user_model.dart';

class AllResultsFeed extends StatelessWidget {
  const AllResultsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final mixedResults = searchProvider.mixedContentResults;

        if (mixedResults.isEmpty) {
          return _buildEmptyState();
        }

        return CustomScrollView(
          slivers: [
            // Quick stats header
            SliverToBoxAdapter(
              child: _buildQuickStatsHeader(searchProvider),
            ),

            // Mixed content masonry grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive grid configuration
                    int crossAxisCount;
                    double spacing;

                    if (constraints.maxWidth >= 1200) {
                      crossAxisCount = 4;
                      spacing = 16;
                    } else if (constraints.maxWidth >= 800) {
                      crossAxisCount = 3;
                      spacing = 14;
                    } else if (constraints.maxWidth >= 500) {
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
                      itemCount: mixedResults.length,
                      itemBuilder: (context, index) {
                        final mixedResult = mixedResults[index];
                        return _buildMixedContentCard(
                            mixedResult, index, constraints.maxWidth);
                      },
                    );
                  },
                ),
              ),
            ),

            // Load more button
            SliverToBoxAdapter(
              child: _buildLoadMoreButton(searchProvider),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStatsHeader(SearchProvider searchProvider) {
    final totalResults = searchProvider.searchResults.length;
    final peopleCount =
        searchProvider.getTabResultCount(SearchResultType.people);
    final topicsCount =
        searchProvider.getTabResultCount(SearchResultType.topics);
    final postsCount = searchProvider.getTabResultCount(SearchResultType.posts);
    final communitiesCount =
        searchProvider.getTabResultCount(SearchResultType.communities);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Found $totalResults results',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Quick filter chips
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 500;
              final chipSpacing = isSmallScreen ? 6.0 : 8.0;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickFilterChip(
                      'People ($peopleCount)',
                      AppColors.secondary,
                      SearchResultType.people,
                      searchProvider,
                      constraints.maxWidth,
                    ),
                    SizedBox(width: chipSpacing),
                    _buildQuickFilterChip(
                      'Topics ($topicsCount)',
                      AppColors.accent,
                      SearchResultType.topics,
                      searchProvider,
                      constraints.maxWidth,
                    ),
                    SizedBox(width: chipSpacing),
                    _buildQuickFilterChip(
                      'Posts ($postsCount)',
                      AppColors.info,
                      SearchResultType.posts,
                      searchProvider,
                      constraints.maxWidth,
                    ),
                    SizedBox(width: chipSpacing),
                    _buildQuickFilterChip(
                      'Communities ($communitiesCount)',
                      AppColors.success,
                      SearchResultType.communities,
                      searchProvider,
                      constraints.maxWidth,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(
    String label,
    Color color,
    SearchResultType type,
    SearchProvider searchProvider,
    double screenWidth,
  ) {
    final isSmallScreen = screenWidth < 500;
    final fontSize = isSmallScreen ? 10.0 : 12.0;
    final horizontalPadding = isSmallScreen ? 8.0 : 12.0;
    final verticalPadding = isSmallScreen ? 6.0 : 8.0;
    final indicatorSize = isSmallScreen ? 4.0 : 6.0;
    return InkWell(
      onTap: () {
        // Switch to specific tab
        final tabIndex = searchProvider.tabs.indexOf(type);
        if (tabIndex != -1) {
          searchProvider.selectTab(tabIndex);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: indicatorSize,
              height: indicatorSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: isSmallScreen ? 4 : 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMixedContentCard(MixedContentResult mixedResult, int index,
      [double? screenWidth]) {
    final result = mixedResult.result;
    final reason = mixedResult.displayReason;
    final typeColor = _getContentTypeColor(result.type);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Content type indicator - only show if enough space
              if (availableHeight > 100)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getContentTypeIcon(result.type),
                        size: 10,
                        color: typeColor,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        flex: reason.isNotEmpty ? 2 : 3,
                        child: Text(
                          _getContentTypeName(result.type),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (reason.isNotEmpty && constraints.maxWidth > 140) ...[
                        const SizedBox(width: 2),
                        Flexible(
                          flex: 1,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.3,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              reason,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: typeColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Actions menu
                      Consumer<SearchProvider>(
                        builder: (context, searchProvider, child) {
                          final isBookmarked = searchProvider.isBookmarked(result.id);
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Bookmark button
                              GestureDetector(
                                onTap: () => searchProvider.toggleBookmark(result.id),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    size: 12,
                                    color: isBookmarked ? typeColor : typeColor.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // More actions
                              GestureDetector(
                                onTap: () => _showResultActions(context, result, searchProvider),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.more_vert,
                                    size: 12,
                                    color: typeColor.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

              // Content area with flexible sizing
              Padding(
                padding: EdgeInsets.all(
                    screenWidth != null && screenWidth < 500 ? 6 : 8),
                child:
                    _buildContentByType(result, screenWidth, availableHeight),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getContentTypeColor(SearchResultType type) {
    switch (type) {
      case SearchResultType.people:
        return AppColors.secondary;
      case SearchResultType.topics:
        return AppColors.accent;
      case SearchResultType.posts:
        return AppColors.info;
      case SearchResultType.communities:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _getContentTypeIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.people:
        return Icons.person;
      case SearchResultType.topics:
        return Icons.tag;
      case SearchResultType.posts:
        return Icons.article;
      case SearchResultType.communities:
        return Icons.groups;
      default:
        return Icons.search;
    }
  }

  String _getContentTypeName(SearchResultType type) {
    switch (type) {
      case SearchResultType.people:
        return 'Person';
      case SearchResultType.topics:
        return 'Topic';
      case SearchResultType.posts:
        return 'Post';
      case SearchResultType.communities:
        return 'Community';
      default:
        return 'Content';
    }
  }

  Widget _buildContentByType(SearchResult result,
      [double? screenWidth, double? availableHeight]) {
    switch (result.type) {
      case SearchResultType.people:
        return _buildPersonContent(result.user!, screenWidth, availableHeight);
      case SearchResultType.topics:
        return _buildTopicContent(result.topic!, screenWidth, availableHeight);
      case SearchResultType.posts:
        return _buildPostContent(result, screenWidth, availableHeight);
      case SearchResultType.communities:
        return _buildCommunityContent(
            result.community!, screenWidth, availableHeight);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonContent(User user,
      [double? screenWidth, double? availableHeight]) {
    final isSmallScreen = screenWidth != null && screenWidth < 500;
    final isShortHeight = availableHeight != null && availableHeight < 200;
    final verticalSpacing = isSmallScreen || isShortHeight ? 4.0 : 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar and name
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: isShortHeight ? 14 : 18,
              backgroundImage: NetworkImage(user.profilePic),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: isShortHeight ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${user.followers} followers',
                    style: TextStyle(
                      fontSize: isShortHeight ? 10 : 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (user.openToMingle && !isShortHeight)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.minglePink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.minglePink.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Mingle',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.minglePink,
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: verticalSpacing),

        // Bio - only show if enough space
        if (!isShortHeight)
          Text(
            user.bio,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        if (!isShortHeight) SizedBox(height: verticalSpacing),

        SizedBox(height: verticalSpacing),

        // Action button - always show
        SizedBox(
          width: double.infinity,
          height: isShortHeight ? 28 : 32,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isFollowing
                  ? AppColors.textSecondary.withOpacity(0.1)
                  : AppColors.primary,
              foregroundColor:
                  user.isFollowing ? AppColors.textSecondary : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: user.isFollowing
                    ? BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        width: 1,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Text(
              user.isFollowing ? 'Following' : 'Follow',
              style: TextStyle(
                fontSize: isShortHeight ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicContent(SearchTopic topic,
      [double? screenWidth, double? availableHeight]) {
    final isSmallScreen = screenWidth != null && screenWidth < 500;
    final isShortHeight = availableHeight != null && availableHeight < 200;
    final verticalSpacing = isSmallScreen || isShortHeight ? 4.0 : 8.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Topic header
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  topic.emoji,
                  style: TextStyle(fontSize: isSmallScreen ? 18 : 22),
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(
                  flex: topic.isTrending ? 2 : 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        topic.name,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (topic.isTrending)
                  Flexible(
                    flex: 1,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.3,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 3 : 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.veryActiveGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.veryActiveGreen.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Trending',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 8 : 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.veryActiveGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 8),

        // Description
        Text(
          topic.description,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Analytics
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getActivityLevelColor(topic.analytics.activityLevel)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getActivityLevelColor(topic.analytics.activityLevel)
                      .withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _getActivityLevelText(topic.analytics.activityLevel),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getActivityLevelColor(topic.analytics.activityLevel),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${topic.analytics.postsLast24h} posts',
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

        // Action button
        SizedBox(
          width: double.infinity,
          height: 32,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: topic.isFollowing
                  ? AppColors.textSecondary.withOpacity(0.1)
                  : AppColors.accent,
              foregroundColor:
                  topic.isFollowing ? AppColors.textSecondary : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: topic.isFollowing
                    ? BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        width: 1,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Text(
              topic.isFollowing ? 'Following' : 'Follow',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(SearchResult result,
      [double? screenWidth, double? availableHeight]) {
    final isSmallScreen = screenWidth != null && screenWidth < 500;
    final isShortHeight = availableHeight != null && availableHeight < 180;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Post Content',
          style: TextStyle(
            fontSize: isShortHeight ? 14 : 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        SizedBox(height: isShortHeight ? 4 : 8),

        if (!isShortHeight)
          Text(
            'This is a preview of post content that would show in the mixed feed...',
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

        SizedBox(height: isShortHeight ? 4 : 12),

        // Engagement indicators - always show but compact when short
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border,
                size: isShortHeight ? 14 : 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              '${(result.relevanceScore * 100).round()}',
              style: TextStyle(
                fontSize: isShortHeight ? 10 : 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.comment_outlined,
                size: isShortHeight ? 14 : 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${(result.relevanceScore * 50).round()}',
                style: TextStyle(
                  fontSize: isShortHeight ? 10 : 11,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommunityContent(SearchCommunity community,
      [double? screenWidth, double? availableHeight]) {
    final isSmallScreen = screenWidth != null && screenWidth < 500;
    final isShortHeight = availableHeight != null && availableHeight < 200;
    final verticalSpacing = isSmallScreen || isShortHeight ? 4.0 : 8.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Community header
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: isShortHeight ? 12 : 15,
              backgroundImage: NetworkImage(community.imageUrl),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    community.name,
                    style: TextStyle(
                      fontSize: isShortHeight ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${community.memberCount} members',
                    style: TextStyle(
                      fontSize: isShortHeight ? 10 : 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: verticalSpacing),

        // Description - only show if enough space
        if (!isShortHeight)
          Text(
            community.description,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        if (!isShortHeight) SizedBox(height: verticalSpacing),

        // Activity - show if enough space
        if (!isShortHeight)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getActivityLevelColor(community.activityLevel)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getActivityLevelColor(community.activityLevel)
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getActivityLevelText(community.activityLevel),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getActivityLevelColor(community.activityLevel),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${community.postsToday} posts today',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

        if (!isShortHeight) SizedBox(height: verticalSpacing),

        SizedBox(height: verticalSpacing),

        // Action button - always show
        SizedBox(
          width: double.infinity,
          height: isShortHeight ? 28 : 32,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: community.isMember
                  ? AppColors.textSecondary.withOpacity(0.1)
                  : AppColors.success,
              foregroundColor:
                  community.isMember ? AppColors.textSecondary : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: community.isMember
                    ? BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        width: 1,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Text(
              community.isMember ? 'Joined' : 'Join',
              style: TextStyle(
                fontSize: isShortHeight ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.dashboard_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Discover trending content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Search is loading popular fitness content...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              if (!searchProvider.isSearching) ...[
                const Text(
                  'Try searching for:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: searchProvider.trendingSuggestions.take(6).map((suggestion) {
                    return InkWell(
                      onTap: () {
                        searchProvider.performSearch(query: suggestion);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getActivityLevelColor(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.veryActive:
        return AppColors.veryActiveGreen;
      case ActivityLevel.active:
        return AppColors.activeOrange;
      case ActivityLevel.moderate:
        return AppColors.moderateGray;
    }
  }

  String _getActivityLevelText(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.active:
        return 'Active';
      case ActivityLevel.moderate:
        return 'Moderate';
    }
  }

  Widget _buildLoadMoreButton(SearchProvider searchProvider) {
    if (!searchProvider.hasMoreResults) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: searchProvider.isLoadingMore
            ? Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Loading more results...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ElevatedButton(
                onPressed: () => searchProvider.loadMoreResults(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Load More',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showResultActions(BuildContext context, SearchResult result, SearchProvider searchProvider) {
    final typeColor = _getContentTypeColor(result.type);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getContentTypeIcon(result.type),
                      color: typeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getResultTitle(result),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getContentTypeName(result.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: typeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                // Share action
                _buildActionItem(
                  icon: Icons.share,
                  label: 'Share',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.pop(context);
                    _shareResult(result);
                  },
                ),
                
                // Open action
                _buildActionItem(
                  icon: Icons.open_in_new,
                  label: 'Open',
                  color: AppColors.success,
                  onTap: () {
                    Navigator.pop(context);
                    _openResult(result);
                  },
                ),
                
                // Copy link action
                _buildActionItem(
                  icon: Icons.link,
                  label: 'Copy Link',
                  color: AppColors.accent,
                  onTap: () {
                    Navigator.pop(context);
                    _copyResultLink(result);
                  },
                ),
                
                // Report action
                _buildActionItem(
                  icon: Icons.flag,
                  label: 'Report',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    _reportResult(context, result);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getResultTitle(SearchResult result) {
    switch (result.type) {
      case SearchResultType.people:
        return result.user?.name ?? 'Unknown User';
      case SearchResultType.topics:
        return result.topic?.name ?? 'Unknown Topic';
      case SearchResultType.posts:
        return result.post?.content ?? result.video?.title ?? 'Unknown Post';
      case SearchResultType.communities:
        return result.community?.name ?? 'Unknown Community';
      default:
        return 'Unknown Result';
    }
  }

  void _shareResult(SearchResult result) {
    // Implementation for sharing result
    // Could integrate with Flutter's share plugin
    final title = _getResultTitle(result);
    print('Sharing: $title');
    // share.share('Check out this ${_getContentTypeName(result.type)}: $title');
  }

  void _openResult(SearchResult result) {
    // Implementation for opening result
    // Navigate to detailed view based on result type
    print('Opening: ${_getResultTitle(result)}');
  }

  void _copyResultLink(SearchResult result) {
    // Implementation for copying result link
    // Could use clipboard to copy link
    print('Copying link for: ${_getResultTitle(result)}');
  }

  void _reportResult(BuildContext context, SearchResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Report Content',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you reporting this ${_getContentTypeName(result.type).toLowerCase()}?',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              'Inappropriate content',
              'Spam or misleading',
              'Copyright violation',
              'Harassment',
              'Other',
            ].map((reason) => InkWell(
              onTap: () {
                Navigator.pop(context);
                _submitReport(result, reason);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _submitReport(SearchResult result, String reason) {
    // Implementation for submitting report
    print('Reporting ${_getResultTitle(result)} for: $reason');
    // In real app, would send to backend
  }
}

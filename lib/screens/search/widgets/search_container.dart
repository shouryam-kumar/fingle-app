import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/glass_badge.dart';
import 'search_header.dart';
import 'search_tabs.dart';
import 'all_results_feed.dart';
import 'people_results.dart';
import 'topics_results.dart';
import 'posts_results.dart';
import 'community_results.dart';
import 'trending_results.dart';
import 'saved_results.dart';

class SearchContainer extends StatefulWidget {
  const SearchContainer({Key? key}) : super(key: key);

  @override
  State<SearchContainer> createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer>
    with TickerProviderStateMixin {
  late AnimationController _resultsController;
  late Animation<double> _resultsAnimation;

  @override
  void initState() {
    super.initState();
    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _resultsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultsController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _resultsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        // Trigger results animation when search results change
        if (searchProvider.hasSearched &&
            searchProvider.searchResults.isNotEmpty) {
          _resultsController.forward();
        } else {
          _resultsController.reverse();
        }

        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.searchBackgroundGradient,
          ),
          child: Column(
            children: [
              // Search header with input and suggestions
              const SearchHeader(),

              // Search tabs (only show when we have results)
              if (searchProvider.hasSearched)
                AnimatedBuilder(
                  animation: _resultsAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -20 * (1 - _resultsAnimation.value)),
                      child: Opacity(
                        opacity: _resultsAnimation.value,
                        child: const SearchTabs(),
                      ),
                    );
                  },
                ),

              // Results area
              Expanded(
                child: _buildResultsArea(searchProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsArea(SearchProvider searchProvider) {
    // Loading state
    if (searchProvider.isSearching) {
      return _buildLoadingState();
    }

    // No search performed yet
    if (!searchProvider.hasSearched) {
      return _buildInitialState(searchProvider);
    }

    // No results found
    if (searchProvider.searchResults.isEmpty) {
      return _buildNoResultsState(searchProvider);
    }

    // Show results based on selected tab
    return AnimatedBuilder(
      animation: _resultsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _resultsAnimation.value)),
          child: Opacity(
            opacity: _resultsAnimation.value,
            child: _buildResultsForCurrentTab(searchProvider),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        borderRadius: 24,
        intensity: GlassIntensity.medium,
        elevation: GlassElevation.medium,
        enableShimmerEffect: true,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Searching...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Finding the best matches for you',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(SearchProvider searchProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          const Center(
            child: Column(
              children: [
                Icon(
                  Icons.search,
                  size: 80,
                  color: AppColors.primary,
                ),
                SizedBox(height: 20),
                Text(
                  'Discover Amazing Content',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Search for people, topics, posts, and communities\nthat match your fitness interests',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Search suggestions
          _buildSearchSuggestions(),

          const SizedBox(height: 30),

          // Trending topics preview
          _buildTrendingTopicsPreview(),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      'HIIT workouts',
      'Yoga poses',
      'Open to mingle',
      'Morning workouts',
      'Nutrition tips',
      'CrossFit',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return _buildSuggestionChip(suggestion);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 20,
      intensity: GlassIntensity.medium,
      elevation: GlassElevation.low,
      hasRippleEffect: true,
      onTap: () {
        context.read<SearchProvider>().performSearch(query: suggestion);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.trending_up,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            suggestion,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTopicsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending Topics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        // Trending topics would come from mock data
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          intensity: GlassIntensity.medium,
          elevation: GlassElevation.medium,
          hasHoverEffect: true,
          onTap: () {
            context
                .read<SearchProvider>()
                .performSearch(query: 'HIIT Workouts');
          },
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: AppColors.veryActiveGradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🔥', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HIIT Workouts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '127 posts today • 2.3K active users',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GlassBadge.trending(text: 'Hot'),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsState(SearchProvider searchProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textSecondary,
          ),

          const SizedBox(height: 20),

          const Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'We couldn\'t find anything for "${searchProvider.searchQuery}"',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // Suggestions for no results
          const Text(
            'Try searching for:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['fitness', 'yoga', 'workout', 'nutrition'].map((term) {
              return _buildSuggestionChip(term);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsForCurrentTab(SearchProvider searchProvider) {
    switch (searchProvider.currentTab) {
      case SearchResultType.all:
        return const AllResultsFeed();
      case SearchResultType.people:
        return const PeopleResults();
      case SearchResultType.topics:
        return const TopicsResults();
      case SearchResultType.posts:
        return const PostsResults();
      case SearchResultType.communities:
        return const CommunityResults();
      case SearchResultType.trending:
        return const TrendingResults();
      case SearchResultType.saved:
        return const SavedResults();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/glass_badge.dart';
import 'enhanced_search_tabs.dart';
import 'all_results_feed.dart';
import 'trending_results.dart';
import 'people_results.dart';
import 'topics_results.dart';
import 'posts_results.dart';
import 'community_results.dart';

class EnhancedPremiumSearchDemo extends StatefulWidget {
  const EnhancedPremiumSearchDemo({super.key});

  @override
  State<EnhancedPremiumSearchDemo> createState() =>
      _EnhancedPremiumSearchDemoState();
}

class _EnhancedPremiumSearchDemoState extends State<EnhancedPremiumSearchDemo> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Auto-perform a demo search after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.read<SearchProvider>().performSearch(query: 'fitness');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return Column(
            children: [
              const SizedBox(height: 50),

              // Enhanced search header
              _buildEnhancedSearchHeader(searchProvider),

              // Enhanced search tabs
              EnhancedSearchTabs(pageController: _pageController),

              // Content area with page view
              Expanded(
                child: _buildContentArea(searchProvider),
              ),
            ],
          );
        },
      ),
      // Move floating controls to a less intrusive position
      floatingActionButton: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return _buildFloatingDemoButton(searchProvider);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEnhancedSearchHeader(SearchProvider searchProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Search',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Clean search input
          _buildCleanSearchInput(searchProvider),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCleanSearchInput(SearchProvider searchProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: searchProvider.searchQuery.isEmpty
                      ? 'Search for people, topics, posts...'
                      : searchProvider.searchQuery,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    searchProvider.performSearch(query: query);
                  }
                },
              ),
            ),

            // Voice search
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _startVoiceSearch();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.mic_none,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea(SearchProvider searchProvider) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        searchProvider.selectTab(index);
      },
      children: [
        // All tab - Mixed content feed
        const AllResultsFeed(),

        // People tab
        const PeopleResults(),

        // Topics tab
        const TopicsResults(),

        // Posts tab
        const PostsResults(),

        // Communities tab
        const CommunityResults(),

        // Trending tab
        const TrendingResults(),
      ],
    );
  }

  Widget _buildFloatingDemoButton(SearchProvider searchProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDemoOptions(searchProvider),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  void _showDemoOptions(SearchProvider searchProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Try Demo Searches',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...['fitness', 'yoga', 'HIIT workouts', 'nutrition'].map(
              (query) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    searchProvider.performSearch(query: query);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      query,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
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
  }

  void _startVoiceSearch() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Listening...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Say your search query',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate voice recognition after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      context
          .read<SearchProvider>()
          .performSearch(query: 'morning workout routine');
    });
  }
}

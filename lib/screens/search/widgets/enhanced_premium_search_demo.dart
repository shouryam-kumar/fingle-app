import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/glass_badge.dart';
import '../../../services/voice_search_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'enhanced_search_tabs.dart';
import 'all_results_feed.dart';
import 'trending_results.dart';
import 'people_results.dart';
import 'topics_results.dart';
import 'posts_results.dart';
import 'community_results.dart';
import 'search_history.dart';
import 'advanced_filters.dart';
import 'saved_results.dart';
import 'enhanced_suggestions.dart';

class EnhancedPremiumSearchDemo extends StatefulWidget {
  const EnhancedPremiumSearchDemo({super.key});

  @override
  State<EnhancedPremiumSearchDemo> createState() =>
      _EnhancedPremiumSearchDemoState();
}

class _EnhancedPremiumSearchDemoState extends State<EnhancedPremiumSearchDemo> {
  late PageController _pageController;
  final VoiceSearchService _voiceSearchService = VoiceSearchService();
  bool _isVoiceSearching = false;
  String _voiceSearchText = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize search provider and load initial content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = context.read<SearchProvider>();
      
      // Initialize provider with history and bookmarks
      searchProvider.initialize();
      
      // Load initial trending content after a delay
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          // Only load if no content exists yet
          if (!searchProvider.hasInitialContent && searchProvider.searchResults.isEmpty) {
            searchProvider.loadInitialTrendingContent();
          }
        }
      });
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

              // Advanced filters
              const AdvancedFilters(),

              // Enhanced suggestions (only when typing)
              if (searchProvider.searchQuery.isNotEmpty && !searchProvider.hasSearched)
                const EnhancedSuggestions(),

              // Enhanced search tabs
              EnhancedSearchTabs(pageController: _pageController),

              // Content area with page view or search history
              Expanded(
                child: searchProvider.searchQuery.isEmpty && !searchProvider.hasSearched
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            const SearchHistory(),
                            const SizedBox(height: 16),
                            _buildTrendingSuggestions(searchProvider),
                            const SizedBox(height: 16),
                            _buildPopularSearches(searchProvider),
                          ],
                        ),
                      )
                    : _buildContentArea(searchProvider),
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
                onChanged: (query) {
                  searchProvider.updateSearchQuery(query);
                },
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    searchProvider.performSearch(query: query);
                  }
                },
              ),
            ),

            // Visual search
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _startVisualSearch();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
            ),

            const SizedBox(width: 8),

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

        // Saved tab
        const SavedResults(),
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

  Future<void> _startVoiceSearch() async {
    HapticFeedback.lightImpact();

    // Initialize voice search service
    final initialized = await _voiceSearchService.initialize();
    if (!initialized) {
      _showVoiceSearchError('Microphone permission required for voice search');
      return;
    }

    setState(() {
      _isVoiceSearching = true;
      _voiceSearchText = '';
    });

    // Show voice search dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mic animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isVoiceSearching 
                      ? AppColors.primary 
                      : AppColors.textSecondary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              
              // Status text
              Text(
                _isVoiceSearching ? 'Listening...' : 'Processing...',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              
              // Voice text preview
              if (_voiceSearchText.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _voiceSearchText,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Instructions
              Text(
                _voiceSearchText.isEmpty 
                    ? 'Say your search query'
                    : 'Processing your request...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Cancel button
              TextButton(
                onPressed: () async {
                  await _voiceSearchService.cancel();
                  setState(() {
                    _isVoiceSearching = false;
                  });
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Start listening
      final result = await _voiceSearchService.startListening(
        timeout: const Duration(seconds: 10),
        onPartialResult: (partialText) {
          setState(() {
            _voiceSearchText = partialText;
          });
        },
      );

      // Close dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() {
        _isVoiceSearching = false;
      });

      // Process result
      if (result != null && result.isNotEmpty) {
        if (mounted) {
          context.read<SearchProvider>().performSearch(query: result);
        }
      } else {
        _showVoiceSearchError('No speech detected. Please try again.');
      }

    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      setState(() {
        _isVoiceSearching = false;
      });
      _showVoiceSearchError('Voice search failed. Please try again.');
    }
  }

  void _showVoiceSearchError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTrendingSuggestions(SearchProvider searchProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Searches',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searchProvider.trendingSuggestions
                .take(6)
                .map((suggestion) => GestureDetector(
                      onTap: () => searchProvider.performSearch(query: suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              suggestion,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _startVisualSearch() async {
    final ImagePicker picker = ImagePicker();
    
    // Show options for camera vs gallery
    final source = await showModalBottomSheet<ImageSource>(
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
          children: [
            const Text(
              'Visual Search',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for workouts by taking a photo or selecting from gallery',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: AppColors.accent,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Camera',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library,
                            color: AppColors.info,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        _processVisualSearch(File(image.path));
      }
    } catch (e) {
      _showVoiceSearchError('Failed to capture image: $e');
    }
  }

  void _processVisualSearch(File imageFile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image preview
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Processing indicator
            Container(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Analyzing Image...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finding similar workouts and exercises',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Simulate image analysis
    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Generate search query based on "image analysis"
      final queries = [
        'yoga poses',
        'strength training',
        'home workout',
        'pilates exercises',
        'cardio workout',
      ];
      
      final randomQuery = queries[DateTime.now().millisecondsSinceEpoch % queries.length];
      
      if (mounted) {
        context.read<SearchProvider>().performSearch(query: randomQuery);
      }
    });
  }

  Widget _buildPopularSearches(SearchProvider searchProvider) {
    final popularSearches = searchProvider.popularSearches;
    
    if (popularSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Popular Searches',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: popularSearches.take(5).length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final search = popularSearches[index];
              final searchCount = searchProvider.searchAnalytics[search] ?? 0;
              
              return GestureDetector(
                onTap: () => searchProvider.performSearch(query: search),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          search,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$searchCount searches',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Cache info
          if (searchProvider.cacheSize > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.offline_bolt,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${searchProvider.cacheSize} searches cached for offline use',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      searchProvider.clearCache();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Search cache cleared'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

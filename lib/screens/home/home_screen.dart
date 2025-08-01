import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/home_models.dart';
import '../../models/reaction_models.dart';
import '../../services/supabase/home_feed_service.dart';
import '../../services/supabase/user_profile_service.dart';
import '../../utils/sample_data.dart';
import '../../widgets/trending_item.dart';
import '../../widgets/story_item.dart';
import '../../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();
  
  List<FeedPost> _feedPosts = [];
  List<TrendingTopic> _trendingTopics = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));

    // Start pulsing animation for FAB
    _fabController.repeat(reverse: true);

    // Add scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);

    // Load initial data
    _loadInitialData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load both feed posts and trending topics in parallel
      final results = await Future.wait([
        HomeFeedService.getHomeFeed(limit: 20, offset: 0),
        HomeFeedService.getTrendingTopics(limit: 10),
      ]);

      final feedPosts = results[0] as List<FeedPost>;
      final trendingTopics = results[1] as List<TrendingTopic>;

      if (mounted) {
        setState(() {
          _feedPosts = feedPosts.isNotEmpty ? feedPosts : List.from(sampleFeedPosts);
          _trendingTopics = trendingTopics.isNotEmpty ? trendingTopics : sampleTrendingTopics;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading home feed: $e');
      
      if (mounted) {
        setState(() {
          // Fallback to sample data on error
          _feedPosts = List.from(sampleFeedPosts);
          _trendingTopics = sampleTrendingTopics;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || _hasReachedEnd) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final morePosts = await HomeFeedService.getHomeFeed(
        limit: 10,
        offset: _feedPosts.length,
      );

      if (mounted) {
        setState(() {
          if (morePosts.isEmpty) {
            _hasReachedEnd = true;
          } else {
            _feedPosts.addAll(morePosts);
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error loading more posts: $e');
      
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _feedPosts.clear();
      _hasReachedEnd = false;
    });
    
    await _loadInitialData();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleReactionSelected(int postIndex, ReactionType type) async {
    final post = _feedPosts[postIndex];
    final currentReaction = post.reactionSummary.userReaction;

    // Optimistic update - update UI immediately
    setState(() {
      final newCounts = Map<ReactionType, int>.from(post.reactionSummary.counts);

      // Remove old reaction if exists
      if (currentReaction != null) {
        newCounts[currentReaction] = (newCounts[currentReaction] ?? 1) - 1;
        if (newCounts[currentReaction]! <= 0) {
          newCounts.remove(currentReaction);
        }
      }

      // Add new reaction or toggle off if same
      ReactionType? newUserReaction;
      int newTotal = post.reactionSummary.totalCount;

      if (currentReaction == type) {
        // Toggling off the same reaction
        newUserReaction = null;
        newTotal--;
      } else {
        // Adding new reaction
        newUserReaction = type;
        newCounts[type] = (newCounts[type] ?? 0) + 1;
        if (currentReaction == null) {
          newTotal++; // Only increment total if user wasn't reacting before
        }
      }

      // Update the post with new reaction summary
      final newReactionSummary = ReactionSummary(
        counts: newCounts,
        reactions: post.reactionSummary.reactions,
        userReaction: newUserReaction,
        totalCount: newTotal,
      );

      _feedPosts[postIndex] = post.copyWith(reactionSummary: newReactionSummary);
    });

    // Try to sync with backend
    try {
      final success = await HomeFeedService.togglePostReaction(post.id.toString(), type);
      if (!success) {
        print('⚠️ Failed to sync reaction to backend, keeping optimistic update');
      }
    } catch (e) {
      print('❌ Error syncing reaction to backend: $e');
    }
  }

  Future<void> _handleRecommendSelected(int postIndex) async {
    final post = _feedPosts[postIndex];
    final isCurrentlyRecommended = post.isRecommended;

    // Optimistic update - update UI immediately
    setState(() {
      final newIsRecommended = !isCurrentlyRecommended;
      int newRecommendationCount = post.recommendations;
      
      if (newIsRecommended) {
        newRecommendationCount++; // Increment when recommending
      } else {
        newRecommendationCount = (newRecommendationCount - 1)
            .clamp(0, double.infinity)
            .toInt(); // Decrement when unrecommending, don't go below 0
      }

      _feedPosts[postIndex] = post.copyWith(
        isRecommended: newIsRecommended,
        recommendations: newRecommendationCount,
      );
    });

    // Try to sync with backend
    try {
      final success = await HomeFeedService.togglePostRecommendation(post.id.toString());
      if (!success) {
        // Revert on failure
        setState(() {
          _feedPosts[postIndex] = post.copyWith(
            isRecommended: isCurrentlyRecommended,
            recommendations: post.recommendations,
          );
        });
        print('❌ Failed to sync recommendation to backend, reverted');
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _feedPosts[postIndex] = post.copyWith(
          isRecommended: isCurrentlyRecommended,
          recommendations: post.recommendations,
        );
      });
      print('❌ Error syncing recommendation to backend: $e');
    }
  }

  Widget _buildCustomAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassMorphism,
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glassShadow,
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.purpleGradient.createShader(bounds),
                    child: Text(
                      'Fingle',
                      style: AppTextStyles.appBarTitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Navigate to notifications
                        },
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Trending Topics',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _trendingTopics.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: TrendingItem(
                      topic: _trendingTopics[index],
                      onTap: () {
                        // TODO: Navigate to trending topic
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoriesSection() {
    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 40.0,
        child: FadeInAnimation(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.background,
                  AppColors.background.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.purpleGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Flash',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${sampleStories.length} stories',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 110, // Optimized height for constrained story items
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: sampleStories.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          horizontalOffset: 30.0,
                          child: FadeInAnimation(
                            child: StoryItem(
                              story: sampleStories[index],
                              onTap: () {
                                // TODO: Open story viewer
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'For You',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _feedPosts.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: PostCard(
                      post: _feedPosts[index],
                      onLike: () {
                        // TODO: Handle like
                      },
                      onComment: () {
                        // TODO: Navigate to comments
                      },
                      onShare: () {
                        // TODO: Handle share
                      },
                      onBookmark: () {
                        // TODO: Handle bookmark
                      },
                      onRecommend: () {
                        _handleRecommendSelected(index);
                      },
                      onUserTap: () {
                        // TODO: Navigate to user profile
                      },
                      onReactionSelected: (ReactionType type) {
                        _handleReactionSelected(index, type);
                        debugPrint(
                            'Reaction selected: ${type.name} for post $index');
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading feed...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    // Responsive spacing based on screen size
    final appBarSpacing = (screenHeight > 800) ? 85.0 : 75.0;
    final sectionSpacing = (screenHeight > 800) ? 28.0 : 20.0;
    final appBarHeight = (screenHeight > 800) ? 85.0 : 75.0;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: _buildCustomAppBar(),
      ),
      body: _isLoading ? _buildLoadingState() : RefreshIndicator(
        onRefresh: _refreshFeed,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: appBarSpacing + statusBarHeight), // Dynamic spacing
              _buildStoriesSection(),
              SizedBox(height: sectionSpacing),
              _buildTrendingSection(),
              SizedBox(height: sectionSpacing),
              _buildMainFeed(),
              if (_isLoadingMore) _buildLoadingMoreIndicator(),
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  // TODO: Navigate to create post
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

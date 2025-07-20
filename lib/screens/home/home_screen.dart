import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/home_models.dart';
import '../../models/reaction_models.dart';
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
  late List<FeedPost> _feedPosts;

  @override
  void initState() {
    super.initState();
    _feedPosts = List.from(sampleFeedPosts); // Create mutable copy
    
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
  }

  @override
  void dispose() {
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleReactionSelected(int postIndex, ReactionType type) {
    setState(() {
      final post = _feedPosts[postIndex];
      final currentReaction = post.reactionSummary.userReaction;
      
      // Create new reaction counts
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
  }

  void _handleRecommendSelected(int postIndex) {
    setState(() {
      final post = _feedPosts[postIndex];
      final isCurrentlyRecommended = post.isRecommended;
      
      // Toggle the recommendation state
      final newIsRecommended = !isCurrentlyRecommended;
      
      // Update the recommendation count
      int newRecommendationCount = post.recommendations;
      if (newIsRecommended) {
        newRecommendationCount++; // Increment when recommending
      } else {
        newRecommendationCount = (newRecommendationCount - 1).clamp(0, double.infinity).toInt(); // Decrement when unrecommending, don't go below 0
      }
      
      // Update the post with new recommendation state
      _feedPosts[postIndex] = post.copyWith(
        isRecommended: newIsRecommended,
        recommendations: newRecommendationCount,
      );
    });
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
            itemCount: sampleTrendingTopics.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: TrendingItem(
                      topic: sampleTrendingTopics[index],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Flash',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        debugPrint('Reaction selected: ${type.name} for post $index');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: _buildCustomAppBar(),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 110), // Account for custom app bar
            _buildStoriesSection(),
            const SizedBox(height: 24),
            _buildTrendingSection(),
            const SizedBox(height: 24),
            _buildMainFeed(),
            const SizedBox(height: 100), // Bottom padding for FAB
          ],
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

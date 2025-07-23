import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/glass_badge.dart';

class TopicsResults extends StatelessWidget {
  const TopicsResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final topicResults = searchProvider.filteredResults;

        if (topicResults.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: topicResults.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final result = topicResults[index];
            if (result.topic != null) {
              return _TopicCard(
                topic: result.topic!,
                onFollowTap: () {
                  searchProvider.toggleTopicFollow(result.topic!.id);
                },
              );
            }
            return const SizedBox.shrink();
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
            Icons.topic_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No topics found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching for fitness topics',
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

class _TopicCard extends StatefulWidget {
  final SearchTopic topic;
  final VoidCallback onFollowTap;

  const _TopicCard({
    required this.topic,
    required this.onFollowTap,
  });

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard>
    with TickerProviderStateMixin {
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
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getActivityColor(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.veryActive:
        return AppColors.veryActiveGreen;
      case ActivityLevel.active:
        return AppColors.activeOrange;
      case ActivityLevel.moderate:
        return AppColors.moderateGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      hasHoverEffect: true,
      child: Column(
        children: [
          // Header with background image and badges
          _buildHeader(),
          
          // Content section
          _buildContent(),
          
          // Analytics section
          _buildAnalytics(),
          
          // Tags section
          if (widget.topic.tags.isNotEmpty)
            _buildTagsSection(),
          
          // Action section
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Background image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.topic.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Trending badge
        if (widget.topic.isTrending)
          Positioned(
            top: 12,
            left: 12,
            child: GlassBadge.trending(text: 'Trending'),
          ),
        
        // Activity level badge
        Positioned(
          top: 12,
          right: 12,
          child: GlassBadge(
            text: _getActivityLevelText(widget.topic.analytics.activityLevel),
            style: GlassBadgeStyle.activity,
            activityLevel: widget.topic.analytics.activityLevel,
          ),
        ),
        
        // Topic emoji and name overlay
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              // Emoji
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.topic.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Topic name
              Expanded(
                child: Text(
                  widget.topic.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            widget.topic.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Activity indicator with pulse animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getActivityColor(widget.topic.analytics.activityLevel),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getActivityColor(widget.topic.analytics.activityLevel)
                                .withOpacity(0.6 * _pulseAnimation.value),
                            blurRadius: 8 * _pulseAnimation.value,
                            spreadRadius: 2 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(width: 8),
                
                const Text(
                  'Analytics (24h)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Analytics metrics
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: _buildAnalyticMetric(
                    'Posts',
                    widget.topic.analytics.postsLast24h.toString(),
                    Icons.post_add,
                    AppColors.accent,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Flexible(
                  child: _buildAnalyticMetric(
                    'Users',
                    _formatNumber(widget.topic.analytics.activeUsers),
                    Icons.people,
                    AppColors.primary,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Flexible(
                  child: _buildAnalyticMetric(
                    'Talks',
                    widget.topic.analytics.totalDiscussions.toString(),
                    Icons.forum,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticMetric(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Related',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.topic.tags.map((tag) {
              return GlassBadge(
                text: tag,
                style: GlassBadgeStyle.secondary,
                customColor: AppColors.textSecondary,
                size: GlassBadgeSize.small,
              );
            }).toList().cast<Widget>(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Follow/Following button
          Expanded(
            child: GlassButton(
              text: widget.topic.isFollowing ? 'Following' : 'Follow Topic',
              style: widget.topic.isFollowing 
                  ? GlassButtonStyle.secondary 
                  : GlassButtonStyle.primary,
              prefixIcon: Icon(widget.topic.isFollowing ? Icons.check : Icons.add),
              onPressed: widget.onFollowTap,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Explore button
          GlassButton(
            text: 'Explore',
            style: GlassButtonStyle.accent,
            prefixIcon: Icon(Icons.explore),
            onPressed: () {
              // Navigate to topic exploration - would integrate with existing routing
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Exploring ${widget.topic.name} topic'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
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
}
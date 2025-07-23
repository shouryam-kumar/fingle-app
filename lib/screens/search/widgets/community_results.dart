import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/glass_badge.dart';

class CommunityResults extends StatelessWidget {
  const CommunityResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final communityResults = searchProvider.filteredResults;

        if (communityResults.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: communityResults.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final result = communityResults[index];
            if (result.community != null) {
              return _CommunityCard(
                community: result.community!,
                onJoinTap: () {
                  searchProvider.toggleCommunityMembership(result.community!.id);
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
            Icons.groups_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No communities found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching for fitness communities',
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

class _CommunityCard extends StatefulWidget {
  final SearchCommunity community;
  final VoidCallback onJoinTap;

  const _CommunityCard({
    required this.community,
    required this.onJoinTap,
  });

  @override
  State<_CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<_CommunityCard>
    with TickerProviderStateMixin {
  late AnimationController _activityController;
  late Animation<double> _activityAnimation;

  @override
  void initState() {
    super.initState();
    _activityController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _activityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _activityController,
      curve: Curves.easeInOutSine,
    ));

    _activityController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _activityController.dispose();
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
          // Header section
          _buildHeader(),
          
          // Content section
          _buildContent(),
          
          // Members preview section
          _buildMembersPreview(),
          
          // Activity stats
          _buildActivityStats(),
          
          // Tags section
          if (widget.community.tags.isNotEmpty)
            _buildTagsSection(),
          
          // Action buttons
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
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.community.imageUrl),
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
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Private badge
        if (widget.community.isPrivate)
          Positioned(
            top: 12,
            left: 12,
            child: GlassBadge(
              text: 'Private',
              style: GlassBadgeStyle.secondary,
              customColor: AppColors.warning,
              // customBackgroundColor not supported in current API
              prefixIcon: Icon(Icons.lock, size: 12),
              size: GlassBadgeSize.medium,
            ),
          ),
        
        // Activity level badge
        Positioned(
          top: 12,
          right: 12,
          child: GlassBadge(
            text: _getActivityLevelText(widget.community.activityLevel),
            style: GlassBadgeStyle.activity,
            activityLevel: widget.community.activityLevel,
          ),
        ),
        
        // Member status
        if (widget.community.isMember)
          Positioned(
            bottom: 12,
            right: 12,
            child: GlassBadge(
              text: 'Member',
              style: GlassBadgeStyle.secondary,
              customColor: AppColors.success,
              // customBackgroundColor not supported in current API
              prefixIcon: Icon(Icons.check_circle, size: 12),
              size: GlassBadgeSize.medium,
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
          // Community name
          Text(
            widget.community.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Member count
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatNumber(widget.community.memberCount)} members',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Text(
            widget.community.description,
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

  Widget _buildMembersPreview() {
    if (widget.community.recentMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Members',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          SizedBox(
            height: 32,
            child: Stack(
              children: [
                // Member avatars stack with proper positioning
                ...widget.community.recentMembers.take(4).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  
                  return Positioned(
                    left: index * 24.0, // 8px overlap: 32 - 8 = 24
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          member.profilePic,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }),
                
                // More members indicator
                if (widget.community.memberCount > 4)
                  Positioned(
                    left: widget.community.recentMembers.take(4).length * 24.0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.glassBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '+${widget.community.memberCount - widget.community.recentMembers.take(4).length}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
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

  Widget _buildActivityStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.glassBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Activity indicator
            AnimatedBuilder(
              animation: _activityAnimation,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getActivityColor(widget.community.activityLevel),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getActivityColor(widget.community.activityLevel)
                            .withOpacity(0.6 * _activityAnimation.value),
                        blurRadius: 8 * _activityAnimation.value,
                        spreadRadius: 2 * _activityAnimation.value,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(width: 8),
            
            Text(
              '${widget.community.postsToday} posts today',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            const Spacer(),
            
            // Activity level text
            Text(
              _getActivityLevelText(widget.community.activityLevel),
              style: TextStyle(
                fontSize: 12,
                color: _getActivityColor(widget.community.activityLevel),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Topics',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 6),
          
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.community.tags.take(4).map((tag) {
              return GlassBadge(
                text: tag,
                style: GlassBadgeStyle.secondary,
                customColor: AppColors.textSecondary,
                // customBackgroundColor not supported in current API
                size: GlassBadgeSize.small,
                // padding not supported in current API
              );
            }).toList().cast<Widget>(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          // Join/Leave button
          Expanded(
            child: GlassButton(
              text: widget.community.isMember 
                  ? 'Leave' 
                  : (widget.community.isPrivate ? 'Request to Join' : 'Join'),
              style: widget.community.isMember 
                  ? GlassButtonStyle.secondary 
                  : GlassButtonStyle.success,
              prefixIcon: Icon(widget.community.isMember 
                  ? Icons.exit_to_app 
                  : (widget.community.isPrivate ? Icons.lock : Icons.add)),
              onPressed: widget.onJoinTap,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Explore button
          GlassButton(
            text: 'Explore',
            style: GlassButtonStyle.accent,
            prefixIcon: Icon(Icons.explore),
            onPressed: () {
              // Navigate to community exploration - would integrate with existing routing
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Exploring ${widget.community.name}'),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
          ),
        ],
      ),
    );
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
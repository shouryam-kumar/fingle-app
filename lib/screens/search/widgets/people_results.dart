import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/search_models.dart';
import '../../../models/user_model.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_button.dart';
import '../../../widgets/common/glass_badge.dart';

class PeopleResults extends StatelessWidget {
  const PeopleResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final peopleResults = searchProvider.filteredResults;

        if (peopleResults.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: peopleResults.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final result = peopleResults[index];
            if (result.user != null) {
              return _PersonCard(
                user: result.user!,
                onFollowTap: () {
                  searchProvider.toggleUserFollow(result.user!.id);
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
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'No people found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search terms',
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

class _PersonCard extends StatefulWidget {
  final User user;
  final VoidCallback onFollowTap;

  const _PersonCard({
    required this.user,
    required this.onFollowTap,
  });

  @override
  State<_PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -200.0,
      end: 200.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      hasHoverEffect: true,
      intensity: GlassIntensity.medium,
      elevation: GlassElevation.medium,
      child: Column(
        children: [
          // Header with cover image
          _buildHeader(),
          
          // Profile content
          _buildProfileContent(),
          
          // Interests section
          if (widget.user.interests.isNotEmpty)
            _buildInterestsSection(),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Cover image
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
                image: NetworkImage(widget.user.coverImage),
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
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Open to Mingle badge
        if (widget.user.openToMingle)
          Positioned(
            top: 12,
            right: 12,
            child: GlassBadge.mingle(),
          ),
        
        // Profile picture
        Positioned(
          bottom: -30,
          left: 20,
          child: _buildProfileAvatar(),
        ),
        
        // Verified badge
        if (widget.user.isVerified)
          Positioned(
            bottom: -10,
            left: 70,
            child: GlassBadge(
              text: '✓',
              style: GlassBadgeStyle.success,
              size: GlassBadgeSize.small,
              hasGlow: true,
            ),
          ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        // Shimmer effect container
        AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glassShadowPrimary,
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    // Profile image
                    Image.network(
                      widget.user.profilePic,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    
                    // Shimmer overlay
                    Positioned(
                      left: _shimmerAnimation.value,
                      child: Container(
                        width: 30,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and age
                    Text(
                      '${widget.user.name}, ${widget.user.age}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Stats
                    _buildStats(),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Bio
          Text(
            widget.user.bio,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: _buildStat('Posts', widget.user.stats.totalPosts.toString())),
        const SizedBox(width: 12),
        Flexible(child: _buildStat('Followers', _formatNumber(widget.user.followers))),
        const SizedBox(width: 12),
        Flexible(child: _buildStat('Following', _formatNumber(widget.user.following))),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interests',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.user.interests.take(5).map((interest) {
              return GlassBadge(
                text: interest,
                style: GlassBadgeStyle.secondary,
                size: GlassBadgeSize.small,
                customColor: AppColors.textSecondary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          // Follow/Following button
          Expanded(
            child: GlassButton(
              text: widget.user.isFollowing ? 'Following' : 'Follow',
              style: widget.user.isFollowing 
                  ? GlassButtonStyle.secondary
                  : GlassButtonStyle.primary,
              prefixIcon: Icon(
                widget.user.isFollowing ? Icons.check : Icons.add,
                size: 16,
                color: Colors.white,
              ),
              onPressed: widget.onFollowTap,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Mingle button (if user is open to mingle)
          if (widget.user.openToMingle)
            Expanded(
              child: GlassButton(
                text: 'Mingle',
                style: GlassButtonStyle.mingle,
                prefixIcon: const Icon(
                  Icons.favorite,
                  size: 16,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Navigate to Mingle screen - would integrate with existing routing
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening Mingle with ${widget.user.name}'),
                      backgroundColor: AppColors.minglePink,
                    ),
                  );
                },
              ),
            ),
          
          // Message button
          if (!widget.user.openToMingle)
            GlassButton(
              text: '',
              style: GlassButtonStyle.secondary,
              isOutlined: true,
              prefixIcon: const Icon(
                Icons.message,
                size: 16,
              ),
              width: 44,
              onPressed: () {
                // Navigate to chat - would integrate with existing routing
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
}
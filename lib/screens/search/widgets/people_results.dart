import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/search_provider.dart';
import '../../../models/user_model.dart';
import '../../../widgets/common/glass_container.dart';
import '../../../widgets/common/glass_badge.dart';

class PeopleResults extends StatelessWidget {
  const PeopleResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final peopleResults = searchProvider.filteredResults;

        if (peopleResults.isEmpty) {
          return _buildEmptyState(context);
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No people found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if this is a narrow screen
        final isNarrow = constraints.maxWidth < 350;
        final isVeryNarrow = constraints.maxWidth < 320;
        
        // Responsive padding
        final cardPadding = isVeryNarrow ? 12.0 : (isNarrow ? 14.0 : 16.0);
        final verticalSpacing = isNarrow ? 12.0 : 16.0;
        
        return GlassContainer(
          borderRadius: 16,
          padding: EdgeInsets.all(cardPadding),
          hasHoverEffect: true,
          intensity: GlassIntensity.medium,
          elevation: GlassElevation.medium,
          customGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.15),
            ],
          ),
          child: Column(
            children: [
              // Main content row
              _buildMainContent(constraints),

              SizedBox(height: verticalSpacing),

              // Interests section
              if (widget.user.interests.isNotEmpty) 
                _buildInterestsSection(constraints),

              SizedBox(height: verticalSpacing),

              // Action buttons
              _buildActionButtons(constraints),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 350;
    final isVeryNarrow = constraints.maxWidth < 320;
    final horizontalSpacing = isVeryNarrow ? 12.0 : (isNarrow ? 14.0 : 16.0);
    final verticalSpacing = isNarrow ? 6.0 : 8.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Avatar
        _buildModernProfileAvatar(),
        
        SizedBox(width: horizontalSpacing),
        
        // Content Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name, Age and Badges Row
              _buildNameRow(constraints),
              
              SizedBox(height: verticalSpacing),
              
              // Bio
              _buildBio(constraints),
              
              SizedBox(height: isNarrow ? 8.0 : 12.0),
              
              // Stats
              _buildCompactStats(constraints),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernProfileAvatar() {
    return Stack(
      children: [
        // Main avatar container
        AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.secondary.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: Stack(
                    children: [
                      // Profile image
                      Image.network(
                        widget.user.profilePic,
                        width: 74,
                        height: 74,
                        fit: BoxFit.cover,
                      ),

                      // Shimmer overlay
                      Positioned(
                        left: _shimmerAnimation.value,
                        child: Container(
                          width: 30,
                          height: 74,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Verified badge
        if (widget.user.isVerified)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNameRow(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 350;
    final isVeryNarrow = constraints.maxWidth < 320;
    final fontSize = isVeryNarrow ? 15.0 : (isNarrow ? 16.0 : 18.0);
    
    return Row(
      children: [
        Expanded(
          child: Text(
            '${widget.user.name}, ${widget.user.age}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        
        SizedBox(width: isNarrow ? 6.0 : 8.0),
        
        // Mingle badge - hide on very narrow screens
        if (widget.user.openToMingle && !isVeryNarrow)
          GlassBadge.mingle(),
      ],
    );
  }

  Widget _buildBio(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 350;
    final isVeryNarrow = constraints.maxWidth < 320;
    final fontSize = isVeryNarrow ? 12.0 : (isNarrow ? 13.0 : 14.0);
    final maxLines = isVeryNarrow ? 1 : 2;
    
    return Text(
      widget.user.bio,
      style: TextStyle(
        fontSize: fontSize,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCompactStats(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 350;
    final isVeryNarrow = constraints.maxWidth < 320;
    final spacing = isVeryNarrow ? 6.0 : (isNarrow ? 8.0 : 12.0);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 1,
          child: _buildStatChip('${widget.user.stats.totalPosts}', 'Posts', constraints),
        ),
        SizedBox(width: spacing),
        Flexible(
          flex: 1,
          child: _buildStatChip(_formatNumber(widget.user.followers), 'Followers', constraints),
        ),
        SizedBox(width: spacing),
        Flexible(
          flex: 1,
          child: _buildStatChip(_formatNumber(widget.user.following), 'Following', constraints),
        ),
      ],
    );
  }

  Widget _buildStatChip(String value, String label, BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 350;
    final isVeryNarrow = constraints.maxWidth < 320;
    
    final horizontalPadding = isVeryNarrow ? 4.0 : (isNarrow ? 6.0 : 8.0);
    final verticalPadding = isVeryNarrow ? 3.0 : 4.0;
    final valueFontSize = isVeryNarrow ? 10.0 : (isNarrow ? 11.0 : 12.0);
    final labelFontSize = isVeryNarrow ? 9.0 : (isNarrow ? 10.0 : 11.0);
    
    // Truncate label on very narrow screens
    final displayLabel = isVeryNarrow ? _abbreviateLabel(label) : label;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: RichText(
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        text: TextSpan(
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(
              text: ' $displayLabel',
              style: TextStyle(
                fontSize: labelFontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _abbreviateLabel(String label) {
    switch (label.toLowerCase()) {
      case 'posts':
        return 'P';
      case 'followers':
        return 'F';
      case 'following':
        return 'Fg';
      default:
        return label.substring(0, 1);
    }
  }


  Widget _buildInterestsSection(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 350;
    final isVeryNarrow = constraints.maxWidth < 320;
    
    final headerFontSize = isVeryNarrow ? 12.0 : (isNarrow ? 13.0 : 14.0);
    final interestFontSize = isVeryNarrow ? 10.0 : (isNarrow ? 11.0 : 12.0);
    final horizontalPadding = isVeryNarrow ? 6.0 : (isNarrow ? 8.0 : 10.0);
    final verticalPadding = isVeryNarrow ? 4.0 : (isNarrow ? 5.0 : 6.0);
    final spacing = isVeryNarrow ? 4.0 : 6.0;
    
    // Limit interests shown based on screen width
    final maxInterests = isVeryNarrow ? 2 : (isNarrow ? 3 : 4);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: TextStyle(
            fontSize: headerFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: isNarrow ? 6.0 : 8.0),
        LayoutBuilder(
          builder: (context, wrapConstraints) {
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: widget.user.interests.take(maxInterests).map((interest) {
                // Truncate long interest names
                final displayInterest = interest.length > (isVeryNarrow ? 8 : 12) ? 
                  '${interest.substring(0, isVeryNarrow ? 8 : 12)}...' : interest;
                
                return Container(
                  constraints: BoxConstraints(
                    maxWidth: wrapConstraints.maxWidth * (isVeryNarrow ? 0.45 : 0.48),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.2),
                        AppColors.primary.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    displayInterest,
                    style: TextStyle(
                      fontSize: interestFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BoxConstraints constraints) {
    final isNarrow = constraints.maxWidth < 350;
    final isVeryNarrow = constraints.maxWidth < 320;
    
    final buttonHeight = isVeryNarrow ? 36.0 : (isNarrow ? 40.0 : 44.0);
    final buttonSpacing = isVeryNarrow ? 8.0 : 12.0;
    final iconSize = isVeryNarrow ? 14.0 : (isNarrow ? 15.0 : 16.0);
    final fontSize = isVeryNarrow ? 12.0 : (isNarrow ? 13.0 : 14.0);
    final iconTextSpacing = isVeryNarrow ? 4.0 : 6.0;
    
    return Row(
      children: [
        // Follow/Following button
        Expanded(
          child: Container(
            height: buttonHeight,
            decoration: BoxDecoration(
              gradient: widget.user.isFollowing
                  ? LinearGradient(
                      colors: [
                        AppColors.textSecondary.withOpacity(0.8),
                        AppColors.textSecondary,
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (widget.user.isFollowing 
                      ? AppColors.textSecondary 
                      : AppColors.primary).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: widget.onFollowTap,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.user.isFollowing ? Icons.check : Icons.person_add,
                        size: iconSize,
                        color: Colors.white,
                      ),
                      if (!isVeryNarrow) ...[
                        SizedBox(width: iconTextSpacing),
                        Flexible(
                          child: Text(
                            widget.user.isFollowing ? 'Following' : 'Follow',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: buttonSpacing),

        // Message/Mingle button
        Container(
          width: buttonHeight,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: widget.user.openToMingle 
                ? AppColors.accent.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.user.openToMingle 
                  ? AppColors.accent.withOpacity(0.5)
                  : AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (widget.user.openToMingle) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening Mingle with ${widget.user.name}'),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                }
                // Navigate to chat/mingle
              },
              child: Center(
                child: Icon(
                  widget.user.openToMingle ? Icons.favorite : Icons.message,
                  size: isVeryNarrow ? 16.0 : 20.0,
                  color: widget.user.openToMingle 
                      ? AppColors.accent 
                      : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

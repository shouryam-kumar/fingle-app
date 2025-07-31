import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/home_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class StoryItem extends StatefulWidget {
  final Story story;
  final VoidCallback? onTap;

  const StoryItem({
    super.key,
    required this.story,
    this.onTap,
  });

  @override
  State<StoryItem> createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    // Brief scale animation on tap
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap?.call();
  }

  Widget _buildGradientRing() {
    final double storySize = (MediaQuery.of(context).size.width * 0.18).clamp(0.0, 65.0);

    if (widget.story.isOwn) {
      // Add icon for own story
      return Container(
        width: storySize,
        height: storySize,
        decoration: BoxDecoration(
          gradient: AppColors.purpleGradient,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }

    if (widget.story.viewed) {
      // Gray ring for viewed stories
      return Container(
        width: storySize,
        height: storySize,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(2),
        child: _buildAvatar(),
      );
    }

    // Gradient ring for unviewed stories (no rotation)
    return Container(
      width: storySize,
      height: storySize,
      decoration: BoxDecoration(
        gradient: AppColors.oceanGradient,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(2),
        child: _buildAvatar(),
      ),
    );
  }

  Widget _buildAvatar() {
    final double avatarSize = ((MediaQuery.of(context).size.width * 0.18).clamp(0.0, 65.0)) * 0.89; // Slightly smaller than story size

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: widget.story.avatar,
        width: avatarSize,
        height: avatarSize,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: AppColors.primary,
            size: 32,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Constrain story width to prevent overflow on larger screens
    final storyWidth = (screenWidth * 0.18).clamp(0.0, 65.0);
    
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              // Add explicit constraints to prevent overflow
              constraints: BoxConstraints(
                maxWidth: storyWidth,
                maxHeight: 100, // Constrained to prevent overflow
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Story ring with constrained size
                  SizedBox(
                    width: storyWidth,
                    height: storyWidth,
                    child: _buildGradientRing(),
                  ),
                  
                  const SizedBox(height: 5), // Reduced spacing
                  
                  // Text with better constraints
                  SizedBox(
                    height: 25, // Reduced height for text area
                    child: Container(
                      width: storyWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Center(
                        child: Text(
                          widget.story.isOwn ? 'Your Story' : widget.story.name,
                          style: AppTextStyles.storyName.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 11, // Slightly smaller to prevent overflow
                            fontWeight: widget.story.viewed
                                ? FontWeight.w400
                                : FontWeight.w600,
                            height: 1.1, // Tighter line height
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2, // Allow 2 lines for longer names
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

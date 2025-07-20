// lib/screens/fingle/widgets/enhanced_video_interactions.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/video_models.dart';

class EnhancedVideoInteractions extends StatefulWidget {
  final VideoPost video;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;

  const EnhancedVideoInteractions({
    super.key,
    required this.video,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
  });

  @override
  State<EnhancedVideoInteractions> createState() =>
      _EnhancedVideoInteractionsState();
}

class _EnhancedVideoInteractionsState extends State<EnhancedVideoInteractions>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late AnimationController _followAnimationController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _followBounceAnimation;

  @override
  void initState() {
    super.initState();

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _followAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _likeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.elasticOut,
    ));

    _followBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _followAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _followAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    HapticFeedback.lightImpact();
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    widget.onLike();
  }

  void _handleFollow() {
    HapticFeedback.mediumImpact();
    _followAnimationController.forward().then((_) {
      _followAnimationController.reverse();
    });
    widget.onFollow();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator Avatar with Follow Button
        _buildCreatorAvatar(),

        const SizedBox(height: 24),

        // Like Button
        _buildLikeButton(),

        const SizedBox(height: 24),

        // Comment Button
        _buildCommentButton(),

        const SizedBox(height: 24),

        // Share Button
        _buildShareButton(),

        const SizedBox(height: 24),

        // More Options Button
        _buildMoreOptionsButton(),
      ],
    );
  }

  Widget _buildCreatorAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Avatar
        GestureDetector(
          onTap: () => _showUserProfile(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                widget.video.creator.profilePic,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primary,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Follow Button (if not following)
        if (!widget.video.isFollowing)
          Positioned(
            bottom: -6,
            child: AnimatedBuilder(
              animation: _followBounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _followBounceAnimation.value,
                  child: GestureDetector(
                    onTap: _handleFollow,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
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

  Widget _buildLikeButton() {
    return AnimatedBuilder(
      animation: _likeScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _likeScaleAnimation.value,
          child: GestureDetector(
            onTap: _handleLike,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.video.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.video.isLiked ? Colors.red : Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCount(widget.video.likes),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentButton() {
    return GestureDetector(
      onTap: widget.onComment,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              _formatCount(widget.video.comments),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: widget.onShare,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.share,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              _formatCount(widget.video.shares),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptionsButton() {
    return GestureDetector(
      onTap: _showMoreOptions,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.more_horiz,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _showUserProfile() {
    // TODO: Navigate to user profile
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View ${widget.video.creator.name}\'s profile'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(
              icon: Icons.flag_outlined,
              title: 'Report',
              onTap: () => Navigator.pop(context),
            ),
            _buildOptionTile(
              icon: Icons.block_outlined,
              title: 'Not Interested',
              onTap: () => Navigator.pop(context),
            ),
            _buildOptionTile(
              icon: Icons.copy_outlined,
              title: 'Copy Link',
              onTap: () => Navigator.pop(context),
            ),
            _buildOptionTile(
              icon: Icons.download_outlined,
              title: 'Save Video',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

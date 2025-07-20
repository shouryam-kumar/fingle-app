import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import 'widgets/zoomable_image.dart';
import 'widgets/post_interactions.dart';
import 'widgets/post_details.dart';
import '../fingle/widgets/share_bottom_sheet.dart';
import '../../models/video_models.dart';
import '../../models/reaction_models.dart';

class PostViewerScreen extends StatefulWidget {
  final List<Post> posts;
  final int initialIndex;
  final User user;
  final bool useAppTheme; // Add this parameter

  const PostViewerScreen({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.user,
    this.useAppTheme = false, // Add this with default value
  });

  @override
  State<PostViewerScreen> createState() => _PostViewerScreenState();
}

class _PostViewerScreenState extends State<PostViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showDetails = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onLike() {
    setState(() {
      // Toggle like (in real app, this would update backend)
      // For demo, we'll just show a snackbar
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post liked! ❤️'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
      ),
    );
  }

  void _onComment() {
    _showCommentsBottomSheet();
  }

  void _onShare() {
    // Create a mock VideoPost for the share sheet
    final currentPost = widget.posts[_currentIndex];
    final mockVideo = VideoPost(
      id: currentPost.id,
      videoUrl: '', // Not needed for share sheet
      thumbnailUrl: currentPost.imageUrl,
      creator: widget.user,
      title: currentPost.title,
      description: currentPost.description,
      tags: currentPost.tags,
      workoutType: 'Fitness',
      difficulty: 'Intermediate',
      duration: 300,
      views: currentPost.views,
      shares: currentPost.shares,
      comments: currentPost.comments,
      createdAt: currentPost.createdAt,
      isFollowing: false,
      reactionSummary: const ReactionSummary(
        counts: {},
        reactions: {},
        userReaction: null,
        totalCount: 0,
      ),
      recommendations: const [],
      isRecommended: false,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ShareBottomSheet(
        video: mockVideo,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showCommentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: widget.useAppTheme ? Colors.white : const Color(0xFF1C1C1E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Comments header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Comments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      widget.useAppTheme ? AppColors.textPrimary : Colors.white,
                ),
              ),
            ),

            // Comments list (placeholder)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5, // Demo comments
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            'U${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'user${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: widget.useAppTheme
                                          ? AppColors.textPrimary
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${index + 1}h',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Great workout! This really motivates me to push harder 💪',
                                style: TextStyle(
                                  color: widget.useAppTheme
                                      ? AppColors.textSecondary
                                      : Colors.grey[300],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Comment input (placeholder)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(widget.user.profilePic),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: widget.useAppTheme
                            ? Colors.grey[100]
                            : Colors.grey[800],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      style: TextStyle(
                        color: widget.useAppTheme
                            ? AppColors.textPrimary
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      // Handle comment submission
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Comment posted! 💬'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.send,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme preference
    final backgroundColor =
        widget.useAppTheme ? AppColors.background : Colors.black;
    final textColor = widget.useAppTheme ? AppColors.textPrimary : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Main content - Vertical scrolling posts
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical, // Changed to vertical
            onPageChanged: _onPageChanged,
            itemCount: widget.posts.length,
            itemBuilder: (context, index) {
              final post = widget.posts[index];
              return GestureDetector(
                onTap: _toggleDetails,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    ZoomableImage(
                      imageUrl: post.imageUrl,
                      heroTag: 'post_${post.id}',
                    ),

                    // Gradient overlays only for black theme
                    if (!widget.useAppTheme) ...[
                      // Top gradient
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          // UI Overlays
          AnimatedOpacity(
            opacity: _showDetails ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Stack(
              children: [
                // Top Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: textColor,
                              size: 24,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: widget.useAppTheme
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  '${_currentIndex + 1} / ${widget.posts.length}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _onShare,
                                icon: Icon(
                                  Icons.share,
                                  color: textColor,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Right side actions
                Positioned(
                  right: 16,
                  bottom: 120,
                  child: Column(
                    children: [
                      // Like button
                      GestureDetector(
                        onTap: _onLike,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                color: textColor,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.posts[_currentIndex].likes}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Comment button
                      GestureDetector(
                        onTap: _onComment,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: textColor,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '127',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Share button
                      GestureDetector(
                        onTap: _onShare,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.share_outlined,
                            color: textColor,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom content
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 80, // Leave space for action buttons
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // User info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    NetworkImage(widget.user.profilePic),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget.user.name,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (widget.user.isVerified) ...[
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.verified,
                                            color: Colors.blue,
                                            size: 16,
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      _getTimeAgo(widget
                                          .posts[_currentIndex].createdAt),
                                      style: TextStyle(
                                        color: widget.useAppTheme
                                            ? AppColors.textLight
                                            : Colors.grey[300],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isFollowing = !_isFollowing;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_isFollowing
                                          ? 'Following ${widget.user.name}!'
                                          : 'Unfollowed ${widget.user.name}'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFollowing
                                      ? Colors.grey[700]
                                      : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                child: Text(
                                  _isFollowing ? 'Following' : 'Follow',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Post content
                          Text(
                            widget.posts[_currentIndex].title,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Tags
                          if (widget.posts[_currentIndex].tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: widget.posts[_currentIndex].tags
                                  .take(3)
                                  .map((tag) {
                                return Text(
                                  '#$tag',
                                  style: TextStyle(
                                    color: Colors.blue[300],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Page indicators (dots)
          if (widget.posts.length > 1)
            Positioned(
              left: 16,
              top: MediaQuery.of(context).size.height / 2 -
                  (widget.posts.length * 6),
              child: AnimatedOpacity(
                opacity: _showDetails ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: List.generate(
                    widget.posts.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      width: 4,
                      height: index == _currentIndex ? 20 : 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: index == _currentIndex
                            ? AppColors.primary
                            : (widget.useAppTheme
                                ? AppColors.textLight.withOpacity(0.5)
                                : Colors.white.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}

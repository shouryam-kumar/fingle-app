import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/video_feed_provider.dart';
import 'widgets/video_player_widget.dart';
import 'package:fingle_app/models/video_models.dart';

class FingleScreen extends StatefulWidget {
  const FingleScreen({super.key});

  @override
  State<FingleScreen> createState() => _FingleScreenState();
}

class _FingleScreenState extends State<FingleScreen> {
  late PageController _pageController;
  late VideoFeedProvider _videoProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 1.0, // FIXED: Ensure only one video is visible
      keepPage: false, // FIXED: Don't keep pages in memory unnecessarily
    );
    
    // Initialize video provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideoFeed();
    });
  }

  Future<void> _initializeVideoFeed() async {
    _videoProvider = Provider.of<VideoFeedProvider>(context, listen: false);
    await _videoProvider.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _videoProvider.setCurrentIndex(index);
    
    // Load more videos when approaching end
    if (_videoProvider.shouldLoadMore) {
      _videoProvider.loadMoreVideos();
    }
  }

  void _onVideoTap() {
    _videoProvider.togglePlayPause();
  }

  void _onVideoDoubleTap() {
    final currentVideo = _videoProvider.currentVideo;
    if (currentVideo != null) {
      _videoProvider.toggleLike(currentVideo.id);
      _showLikeAnimation();
    }
  }

  void _showLikeAnimation() {
    // Add haptic feedback
    HapticFeedback.mediumImpact();
    
    // Create floating heart animation
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: MediaQuery.of(context).size.width / 2 - 30,
        top: MediaQuery.of(context).size.height / 2 - 30,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1.0 + (value * 0.5),
              child: Opacity(
                opacity: 1.0 - value,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 60,
                ),
              ),
            );
          },
          onEnd: () => overlayEntry?.remove(),
        ),
      ),
    );
    
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<VideoFeedProvider>(
        builder: (context, provider, child) {
          if (!_isInitialized || provider.isLoading && provider.videos.isEmpty) {
            return _buildLoadingScreen();
          }

          if (provider.videos.isEmpty) {
            return _buildEmptyScreen();
          }

          return Stack(
            children: [
              // FIXED: Ensure black background covers everything
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
              ),
              
              // Main video feed
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: _onPageChanged,
                itemCount: provider.videos.length,
                itemBuilder: (context, index) {
                  final video = provider.videos[index];
                  final controller = provider.getController(video.id);
                  final isActive = index == provider.currentIndex;

                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black, // FIXED: Ensure each page has black background
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // FIXED: Black background for each video
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black,
                        ),
                        
                        // Video player - ONLY show if this is the active video
                        if (isActive) ...[
                          VideoPlayerWidget(
                            video: video,
                            controller: controller,
                            isActive: isActive,
                            onTap: _onVideoTap,
                            onDoubleTap: _onVideoDoubleTap,
                          ),
                          
                          // Video overlays - ONLY show on active video
                          _buildVideoOverlays(video, provider),
                        ] else ...[
                          // For non-active videos, just show thumbnail
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.black,
                            child: Image.network(
                              video.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.black,
                                  child: const Center(
                                    child: Icon(
                                      Icons.video_library,
                                      color: Colors.white54,
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              
              // Loading indicator for loading more videos
              if (provider.isLoading && provider.videos.isNotEmpty)
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVideoOverlays(VideoPost video, VideoFeedProvider provider) {
    return Stack(
      children: [
        // Top gradient and header
        _buildTopOverlay(),
        
        // Right side actions
        Positioned(
          right: 12,
          bottom: 180,
          child: _buildRightActions(video, provider),
        ),
        
        // Bottom gradient and info
        Positioned(
          bottom: 0,
          left: 0,
          right: 100,
          child: _buildBottomInfo(video, provider),
        ),
      ],
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fingle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera feature coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightActions(VideoPost video, VideoFeedProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator avatar
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('View ${video.creator.name}\'s profile'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                video.creator.profilePic,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primary,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Like button
        GestureDetector(
          onTap: () => provider.toggleLike(video.id),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  video.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: video.isLiked ? Colors.red : Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCount(video.likes),
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
        
        const SizedBox(height: 24),
        
        // Comment button
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Comments feature coming soon!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
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
                  _formatCount(video.comments),
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
        
        const SizedBox(height: 24),
        
        // Share button
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share feature coming soon!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
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
                  _formatCount(video.shares),
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
      ],
    );
  }

  Widget _buildBottomInfo(VideoPost video, VideoFeedProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Creator name and follow button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '@${video.creator.name.toLowerCase().replaceAll(' ', '')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (video.creator.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ],
                  const SizedBox(width: 12),
                  if (!video.isFollowing)
                    GestureDetector(
                      onTap: () => provider.toggleFollow(video.creator.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Follow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Video title
              Text(
                video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Tags
              if (video.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: video.tags.take(3).map((tag) {
                    return Text(
                      '#$tag',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Loading videos...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library_outlined,
            color: Colors.white54,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No videos available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pull to refresh',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Provider.of<VideoFeedProvider>(context, listen: false).refreshFeed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh'),
          ),
        ],
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
}
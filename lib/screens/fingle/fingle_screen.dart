// lib/screens/fingle/fingle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/tab_visibility_detector.dart';
import '../../providers/video_feed_provider.dart';
import '../../providers/app_provider.dart';
import 'widgets/video_player_widget.dart';
import 'package:fingle_app/models/video_models.dart';

class FingleScreen extends StatefulWidget {
  const FingleScreen({super.key});

  @override
  State<FingleScreen> createState() => _FingleScreenState();
}

class _FingleScreenState extends State<FingleScreen> 
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late PageController _pageController;
  late VideoFeedProvider _videoProvider;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);
    
    _pageController = PageController(
      viewportFraction: 1.0,
      keepPage: false,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideoFeed();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (!_isInitialized) return;
    
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 App resumed');
        // Tab visibility will handle video playback
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        debugPrint('📱 App paused/inactive - pausing video');
        _videoProvider.pauseCurrentVideo();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  /// FIXED: Called when the Fingle tab becomes visible
  void _onTabVisible() {
    // 🐛 SIMPLE DEBUG: Just check app provider
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final currentTab = appProvider.currentIndex;
    
    print('🟢 Fingle._onTabVisible() called - App tab: $currentTab');
    
    // ✅ SAFETY CHECK: Only proceed if we're actually on Fingle tab
    if (currentTab != 2) {
      print('🚫 BLOCKED: App says we\'re on tab $currentTab, not Fingle (2)');
      return; // DON'T set visibility if we're not on Fingle tab
    }
    
    print('✅ ALLOWED: Setting Fingle visibility to true');
    _videoProvider.setTabVisibility(true);
    
    // FIXED: Update provider's tab visibility state
    _videoProvider.setTabVisibility(true);
    
    // FIXED: Initialize and play first video if not done yet
    if (_isInitialized && _videoProvider.videos.isNotEmpty) {
      // Ensure we're on the first video if this is first time becoming visible
      if (_videoProvider.currentIndex == 0) {
        debugPrint('🎬 First time visible - setting up first video');
        // FIXED: Explicitly play the current video after setting index
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _videoProvider.setCurrentIndex(0);
          await _videoProvider.playCurrentVideo();
        });
      } else {
        // FIXED: For other videos, just play the current one
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _videoProvider.playCurrentVideo();
        });
      }
    }
  }

  /// FIXED: Called when the Fingle tab becomes invisible
  void _onTabInvisible() {
    debugPrint('🔴 FingleScreen._onTabInvisible() called');
    debugPrint('  📊 App current index: ${Provider.of<AppProvider>(context, listen: false).currentIndex}');
    debugPrint('  📊 Current route: ${ModalRoute.of(context)?.settings.name}');
    
    // FIXED: Update provider's tab visibility state
    _videoProvider.setTabVisibility(false);
  }

  Future<void> _initializeVideoFeed() async {
    debugPrint('=== 🚀 INITIALIZING VIDEO FEED ===');
    
    _videoProvider = Provider.of<VideoFeedProvider>(context, listen: false);
    await _videoProvider.initialize();
    
    setState(() {
      _isInitialized = true;
    });
    
    debugPrint('✅ Initialized: $_isInitialized, Videos: ${_videoProvider.videos.length}');
    
    // FIXED: Set up first video but don't play yet (wait for tab visibility)
    if (_videoProvider.videos.isNotEmpty) {
      await _videoProvider.setCurrentIndex(0);
      debugPrint('📹 Set current index to 0');
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeInOut,
        );
      }
    }
    
    debugPrint('=== ✅ VIDEO FEED INITIALIZATION COMPLETE ===');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // FIXED: Check if this tab is currently visible
        final isFingleTabVisible = appProvider.currentIndex == 2; // Fingle is at index 2

        // 🐛 DEBUG: Log every build
        debugPrint('🏗️ FingleScreen.build() called');
        debugPrint('  📊 App index: ${appProvider.currentIndex}');
        debugPrint('  📊 Is Fingle tab visible: $isFingleTabVisible');
        debugPrint('  📊 Provider tab visibility: ${_isInitialized ? _videoProvider.isTabVisible : 'not initialized'}');
        
        // FIXED: Update tab visibility based on AppProvider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isInitialized) {
            if (isFingleTabVisible && !_videoProvider.isTabVisible) {
              debugPrint('🟢 Fingle tab became visible via AppProvider');
              _onTabVisible();
            } else if (!isFingleTabVisible && _videoProvider.isTabVisible) {
              debugPrint('🔴 Fingle tab became invisible via AppProvider');
              _onTabInvisible();
            }
          }
        });
        
        return TabVisibilityDetector(
          tabName: 'Fingle',
          onTabVisible: _onTabVisible,
          onTabInvisible: _onTabInvisible,
          enableDebugLogs: true,
          child: Scaffold(
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
                    // Black background
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
                          color: Colors.black,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Black background for each video
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.black,
                              ),
                              
                              // FIXED: Always show VideoPlayerWidget for active video
                              if (isActive) ...[
                                VideoPlayerWidget(
                                  video: video,
                                  controller: controller,
                                  isActive: isActive,
                                  isTabVisible: provider.isTabVisible, // ADDED: Pass tab visibility
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
          ),
        );
      },
    );
  }

  void _onPageChanged(int index) async {
    debugPrint('📄 Page changed to index: $index');
    await _videoProvider.setCurrentIndex(index);
    
    // Load more videos when approaching end
    if (_videoProvider.shouldLoadMore) {
      debugPrint('📥 Loading more videos...');
      _videoProvider.loadMoreVideos();
    }
  }

  void _onVideoTap() {
    debugPrint('👆 Video tapped - toggling play/pause');
    _videoProvider.togglePlayPause();
  }

  void _onVideoDoubleTap() {
    debugPrint('👆👆 Video double-tapped - toggling like');
    final currentVideo = _videoProvider.currentVideo;
    if (currentVideo != null) {
      _videoProvider.toggleLike(currentVideo.id);
      _showLikeAnimation();
    }
  }

  void _showLikeAnimation() {
    HapticFeedback.mediumImpact();
    
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
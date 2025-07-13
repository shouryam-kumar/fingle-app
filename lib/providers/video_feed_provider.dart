import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_models.dart';

class VideoFeedProvider extends ChangeNotifier {
  // Core state
  List<VideoPost> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _hasReachedEnd = false;
  bool _isTabVisible = false; // ADDED: Track tab visibility
  
  // Video controllers management
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, bool> _controllersInitialized = {};
  
  // Getters
  List<VideoPost> get videos => _videos;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get hasReachedEnd => _hasReachedEnd;
  bool get isTabVisible => _isTabVisible; // ADDED: Expose tab visibility
  VideoPost? get currentVideo => _videos.isNotEmpty ? _videos[_currentIndex] : null;
  
  // Get video controller for specific video
  VideoPlayerController? getController(String videoId) {
    return _controllers[videoId];
  }
  
  bool isControllerInitialized(String videoId) {
    return _controllersInitialized[videoId] ?? false;
  }

  // ADDED: Set tab visibility from UI
  void setTabVisibility(bool isVisible) {
    if (_isTabVisible != isVisible) {
      debugPrint('📱 Provider: Tab visibility changed to $isVisible');
      _isTabVisible = isVisible;
      
      if (isVisible && _videos.isNotEmpty) {
        // Play current video when tab becomes visible
        playCurrentVideo();
      } else if (!isVisible) {
        // Pause current video when tab becomes invisible
        pauseCurrentVideo();
      }
      
      notifyListeners();
    }
  }

  // Initialize with mock data
  Future<void> initialize() async {
    if (_videos.isNotEmpty) return;
    
    _isLoading = true;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _videos = List.from(mockLifestyleVideos);
    _isLoading = false;
    notifyListeners();
    
    // Preload first few videos
    if (_videos.isNotEmpty) {
      await _preloadVideos(0);
    }
  }

  // Load more videos (for infinite scroll)
  Future<void> loadMoreVideos() async {
    if (_isLoading || _hasReachedEnd) return;
    
    _isLoading = true;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // For demo, we'll cycle through the same videos
    final moreVideos = mockLifestyleVideos.map((video) {
      return video.copyWith(
        id: '${video.id}_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now().subtract(Duration(hours: _videos.length)),
      );
    }).toList();
    
    _videos.addAll(moreVideos);
    _isLoading = false;
    
    // Mark as reached end after loading 30 videos (for demo)
    if (_videos.length >= 30) {
      _hasReachedEnd = true;
    }
    
    notifyListeners();
  }

  // FIXED: Navigate to specific video index without auto-playing
  Future<void> setCurrentIndex(int index) async {
    if (index < 0 || index >= _videos.length) return;
    
    final oldIndex = _currentIndex;
    _currentIndex = index;
    notifyListeners();
    
    // Pause previous video
    if (oldIndex != index && oldIndex < _videos.length) {
      final oldVideo = _videos[oldIndex];
      final oldController = _controllers[oldVideo.id];
      if (oldController != null && oldController.value.isPlaying) {
        await oldController.pause();
        debugPrint('⏸️ Paused previous video: ${oldVideo.id}');
      }
    }
    
    // FIXED: Only play if tab is visible
    if (_isTabVisible) {
      await playCurrentVideo();
    } else {
      debugPrint('📱 Not playing video - tab not visible (index: $index)');
    }
    
    // Preload surrounding videos
    await _preloadVideos(index);
    
    // Clean up distant controllers to save memory
    _cleanupDistantControllers(index);
  }

  // FIXED: Play current video only if tab is visible
  Future<void> playCurrentVideo() async {
    if (_videos.isEmpty) return;
    
    final video = _videos[_currentIndex];
    debugPrint('🎬 Attempting to play video: ${video.id} at index: $_currentIndex (tab visible: $_isTabVisible)');
    
    // FIXED: Check tab visibility before playing
    if (!_isTabVisible) {
      debugPrint('⏸️ Not playing - tab not visible');
      return;
    }
    
    VideoPlayerController? controller = _controllers[video.id];
    
    if (controller == null) {
      debugPrint('🔄 Controller is null, creating new one for ${video.id}');
      await _createController(video);
      controller = _controllers[video.id];
    }
    
    if (controller != null && _controllersInitialized[video.id] == true) {
      debugPrint('▶️ Playing video: ${video.id}');
      if (!controller.value.isPlaying) {
        await controller.play();
      }
    } else {
      debugPrint('⚠️ Controller not ready for video: ${video.id}');
    }
  }

  // Pause current video
  Future<void> pauseCurrentVideo() async {
    if (_videos.isEmpty) return;
    
    final video = _videos[_currentIndex];
    final controller = _controllers[video.id];
    
    if (controller != null && controller.value.isPlaying) {
      debugPrint('⏸️ Pausing video: ${video.id}');
      await controller.pause();
    }
  }

  // FIXED: Toggle play/pause respects tab visibility
  Future<void> togglePlayPause() async {
    if (_videos.isEmpty || !_isTabVisible) return;
    
    final video = _videos[_currentIndex];
    final controller = _controllers[video.id];
    
    if (controller != null && _controllersInitialized[video.id] == true) {
      if (controller.value.isPlaying) {
        await controller.pause();
        debugPrint('⏸️ Toggled to pause: ${video.id}');
      } else {
        await controller.play();
        debugPrint('▶️ Toggled to play: ${video.id}');
      }
      notifyListeners();
    }
  }

  // Create video controller
  Future<void> _createController(VideoPost video) async {
    if (_controllers.containsKey(video.id)) return;
    
    try {
      debugPrint('🔄 Creating controller for ${video.id}');
      final controller = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
      _controllers[video.id] = controller;
      _controllersInitialized[video.id] = false;
      
      await controller.initialize();
      
      // Set to loop
      await controller.setLooping(true);
      
      _controllersInitialized[video.id] = true;
      debugPrint('✅ Controller ready for ${video.id}');
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ Error creating video controller for ${video.id}: $e');
      _controllersInitialized[video.id] = false;
    }
  }

  // Preload videos around current index
  Future<void> _preloadVideos(int centerIndex) async {
    final indicesToPreload = <int>[];
    
    // Preload current + next 2 + previous 1
    for (int i = centerIndex - 1; i <= centerIndex + 2; i++) {
      if (i >= 0 && i < _videos.length) {
        indicesToPreload.add(i);
      }
    }
    
    for (final index in indicesToPreload) {
      final video = _videos[index];
      if (!_controllers.containsKey(video.id)) {
        await _createController(video);
      }
    }
  }

  // Clean up controllers that are far from current index
  void _cleanupDistantControllers(int currentIndex) {
    final controllersToRemove = <String>[];
    
    _controllers.forEach((videoId, controller) {
      final videoIndex = _videos.indexWhere((v) => v.id == videoId);
      if (videoIndex != -1) {
        final distance = (videoIndex - currentIndex).abs();
        if (distance > 3) { // Keep controllers within 3 positions
          controllersToRemove.add(videoId);
        }
      }
    });
    
    for (final videoId in controllersToRemove) {
      final controller = _controllers[videoId];
      controller?.dispose();
      _controllers.remove(videoId);
      _controllersInitialized.remove(videoId);
      debugPrint('🗑️ Cleaned up controller for $videoId');
    }
  }

  // Like/unlike video
  Future<void> toggleLike(String videoId) async {
    final videoIndex = _videos.indexWhere((v) => v.id == videoId);
    if (videoIndex == -1) return;
    
    final video = _videos[videoIndex];
    final newLikeCount = video.isLiked ? video.likes - 1 : video.likes + 1;
    
    _videos[videoIndex] = video.copyWith(
      isLiked: !video.isLiked,
      likes: newLikeCount,
    );
    
    notifyListeners();
    
    // TODO: Send API request to backend
    // await _videoService.toggleLike(videoId);
  }

  // Follow/unfollow user
  Future<void> toggleFollow(String userId) async {
    for (int i = 0; i < _videos.length; i++) {
      if (_videos[i].creator.id == userId) {
        _videos[i] = _videos[i].copyWith(
          isFollowing: !_videos[i].isFollowing,
        );
      }
    }
    
    notifyListeners();
    
    // TODO: Send API request to backend
    // await _userService.toggleFollow(userId);
  }

  // Refresh feed
  Future<void> refreshFeed() async {
    _isLoading = true;
    _hasReachedEnd = false;
    notifyListeners();
    
    // Clear existing data
    await _disposeAllControllers();
    _videos.clear();
    _currentIndex = 0;
    
    // Reload
    await initialize();
  }

  // Dispose all controllers
  Future<void> _disposeAllControllers() async {
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
    _controllersInitialized.clear();
  }

  @override
  void dispose() {
    _disposeAllControllers();
    super.dispose();
  }

  // Get next video for swipe prediction
  VideoPost? getNextVideo() {
    if (_currentIndex + 1 < _videos.length) {
      return _videos[_currentIndex + 1];
    }
    return null;
  }

  // Get previous video
  VideoPost? getPreviousVideo() {
    if (_currentIndex - 1 >= 0) {
      return _videos[_currentIndex - 1];
    }
    return null;
  }

  // Check if we're near the end (for infinite scroll)
  bool get shouldLoadMore {
    return !_isLoading && !_hasReachedEnd && (_currentIndex >= _videos.length - 3);
  }
}
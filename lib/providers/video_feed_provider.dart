import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_models.dart';

class VideoFeedProvider extends ChangeNotifier {
  // Core state
  List<VideoPost> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _hasReachedEnd = false;
  
  // Video controllers management
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, bool> _controllersInitialized = {};
  
  // Getters
  List<VideoPost> get videos => _videos;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get hasReachedEnd => _hasReachedEnd;
  VideoPost? get currentVideo => _videos.isNotEmpty ? _videos[_currentIndex] : null;
  
  // Get video controller for specific video
  VideoPlayerController? getController(String videoId) {
    return _controllers[videoId];
  }
  
  bool isControllerInitialized(String videoId) {
    return _controllersInitialized[videoId] ?? false;
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

  // Navigate to specific video index
  Future<void> setCurrentIndex(int index) async {
    if (index < 0 || index >= _videos.length) return;
    
    final oldIndex = _currentIndex;
    _currentIndex = index;
    notifyListeners();
    
    // Pause previous video
    final oldVideo = _videos[oldIndex];
    final oldController = _controllers[oldVideo.id];
    if (oldController != null && oldController.value.isPlaying) {
      await oldController.pause();
    }
    
    // Play current video
    await _playCurrentVideo();
    
    // Preload surrounding videos
    await _preloadVideos(index);
    
    // Clean up distant controllers to save memory
    _cleanupDistantControllers(index);
  }

  // Play current video
  Future<void> _playCurrentVideo() async {
    if (_videos.isEmpty) return;
    
    final video = _videos[_currentIndex];
    VideoPlayerController? controller = _controllers[video.id];
    
    if (controller == null) {
      await _createController(video);
      controller = _controllers[video.id];
    }
    
    if (controller != null && _controllersInitialized[video.id] == true) {
      if (!controller.value.isPlaying) {
        await controller.play();
      }
    }
  }

  // Pause current video
  Future<void> pauseCurrentVideo() async {
    if (_videos.isEmpty) return;
    
    final video = _videos[_currentIndex];
    final controller = _controllers[video.id];
    
    if (controller != null && controller.value.isPlaying) {
      await controller.pause();
    }
  }

  // Toggle play/pause for current video
  Future<void> togglePlayPause() async {
    if (_videos.isEmpty) return;
    
    final video = _videos[_currentIndex];
    final controller = _controllers[video.id];
    
    if (controller != null && _controllersInitialized[video.id] == true) {
      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        await controller.play();
      }
      notifyListeners();
    }
  }

  // Create video controller
  Future<void> _createController(VideoPost video) async {
    if (_controllers.containsKey(video.id)) return;
    
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
      _controllers[video.id] = controller;
      _controllersInitialized[video.id] = false;
      
      await controller.initialize();
      
      // Set to loop
      await controller.setLooping(true);
      
      _controllersInitialized[video.id] = true;
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error creating video controller for ${video.id}: $e');
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
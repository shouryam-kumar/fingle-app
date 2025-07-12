// lib/core/utils/tab_visibility_detector.dart
import 'package:flutter/material.dart';

/// A utility widget that detects when its child tab becomes visible or invisible.
/// Useful for managing video playback, network requests, or other resources
/// that should only be active when the tab is visible to the user.
/// 
/// Example usage:
/// ```dart
/// TabVisibilityDetector(
///   tabName: 'VideoFeed',
///   onTabVisible: () => startVideoPlayback(),
///   onTabInvisible: () => pauseVideoPlayback(),
///   child: YourTabContent(),
/// )
/// ```
class TabVisibilityDetector extends StatefulWidget {
  /// The child widget to wrap
  final Widget child;
  
  /// Callback fired when the tab becomes visible
  final VoidCallback? onTabVisible;
  
  /// Callback fired when the tab becomes invisible
  final VoidCallback? onTabInvisible;
  
  /// Name of the tab for debugging purposes
  final String tabName;
  
  /// Whether to enable debug logging
  final bool enableDebugLogs;

  const TabVisibilityDetector({
    super.key,
    required this.child,
    this.onTabVisible,
    this.onTabInvisible,
    required this.tabName,
    this.enableDebugLogs = false,
  });

  @override
  State<TabVisibilityDetector> createState() => _TabVisibilityDetectorState();
}

class _TabVisibilityDetectorState extends State<TabVisibilityDetector>
    with WidgetsBindingObserver {
  bool _isVisible = false;
  bool _isAppInForeground = true;
  bool _hasCheckedInitialVisibility = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // FIXED: Check visibility more aggressively on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
    
    // FIXED: Also check after a short delay to catch tab switches
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _checkVisibility();
    });
    
    // FIXED: Check multiple times to ensure we catch the initial state
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _checkVisibility();
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _checkVisibility();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // FIXED: Check visibility every time dependencies change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
    
    // FIXED: Also check after a short delay to catch tab switches
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _checkVisibility();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasInForeground = _isAppInForeground;
    _isAppInForeground = state == AppLifecycleState.resumed;
    
    if (widget.enableDebugLogs) {
      debugPrint('${widget.tabName}: App lifecycle changed to $state');
    }
    
    // Only update visibility if app foreground state changed
    if (wasInForeground != _isAppInForeground) {
      _updateVisibility();
    }
  }

  void _checkVisibility() {
    if (!mounted) return;
    
    final ModalRoute? route = ModalRoute.of(context);
    final bool isCurrentRoute = route?.isCurrent ?? false;
    final bool shouldBeVisible = isCurrentRoute && _isAppInForeground;
    
    if (widget.enableDebugLogs) {
      debugPrint('${widget.tabName}: Checking visibility - '
                'Route: $isCurrentRoute, '
                'App: $_isAppInForeground, '
                'Should be visible: $shouldBeVisible, '
                'Current state: $_isVisible');
    }
    
    if (shouldBeVisible != _isVisible) {
      setState(() {
        _isVisible = shouldBeVisible;
      });
      _updateVisibility();
    }
    
    // FIXED: Mark that we've checked initial visibility
    if (!_hasCheckedInitialVisibility) {
      _hasCheckedInitialVisibility = true;
      // FIXED: Schedule another check to catch delayed tab switches
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _checkVisibility();
      });
    }
  }

  void _updateVisibility() {
    if (widget.enableDebugLogs) {
      debugPrint('${widget.tabName}: 🔄 Visibility changed to $_isVisible');
    }
    
    // FIXED: Use post frame callback to ensure proper timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      if (_isVisible) {
        widget.onTabVisible?.call();
      } else {
        widget.onTabInvisible?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
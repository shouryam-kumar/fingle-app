import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';

class ScreenTimeoutService {
  static const Duration _timeoutDuration = Duration(minutes: 3);
  static const Duration _dimDuration =
      Duration(seconds: 10); // Dim for 10 seconds before locking
  static const double _dimBrightness = 0.1; // 10% brightness when dimmed

  static Timer? _timeoutTimer;
  static Timer? _dimTimer;
  static bool _isWakeLockEnabled = false;
  static bool _shouldMaintainWakelock = false;
  static bool _isDimmed = false;
  static double? _originalBrightness;

  /// Enable wakelock and start 3-minute timer
  static Future<void> enableExtendedTimeout() async {
    try {
      _shouldMaintainWakelock = true;

      if (!_isWakeLockEnabled) {
        await WakelockPlus.enable();
        _isWakeLockEnabled = true;
        debugPrint('🔋 Screen timeout: Wakelock enabled');
      }

      // Reset brightness to normal if it was dimmed
      if (_isDimmed) {
        await _resetBrightness();
        _isDimmed = false;
      }

      // Reset the timer
      _resetTimer();
    } catch (e) {
      debugPrint('❌ Error enabling wakelock: $e');
    }
  }

  /// Disable wakelock and cancel all timers
  static Future<void> disableExtendedTimeout() async {
    try {
      _shouldMaintainWakelock = false;
      _timeoutTimer?.cancel();
      _dimTimer?.cancel();

      // Reset brightness if it was dimmed
      if (_isDimmed) {
        await _resetBrightness();
        _isDimmed = false;
      }

      if (_isWakeLockEnabled) {
        await WakelockPlus.disable();
        _isWakeLockEnabled = false;
        debugPrint('🔋 Screen timeout: Wakelock disabled');
      }
    } catch (e) {
      debugPrint('❌ Error disabling wakelock: $e');
    }
  }

  /// Reset the 3-minute timer (call this on user interactions)
  static void resetTimer() {
    if (_isWakeLockEnabled && _shouldMaintainWakelock) {
      // Reset brightness to normal if it was dimmed
      if (_isDimmed) {
        _resetBrightness();
        _isDimmed = false;
      }

      _resetTimer();
    }
  }

  /// Re-enable wakelock if it should be maintained (call when app becomes active)
  static Future<void> onAppResumed() async {
    debugPrint('🔋 Screen timeout: App resumed');

    // If we should maintain wakelock, re-enable it
    if (_shouldMaintainWakelock) {
      debugPrint('🔋 Screen timeout: Re-enabling wakelock after app resume');
      await enableExtendedTimeout();
    }
  }

  /// Handle app going to background
  static Future<void> onAppPaused() async {
    debugPrint('🔋 Screen timeout: App paused');

    // Cancel timers when app goes to background
    _timeoutTimer?.cancel();
    _dimTimer?.cancel();

    // Reset brightness if it was dimmed
    if (_isDimmed) {
      await _resetBrightness();
      _isDimmed = false;
    }
  }

  static void _resetTimer() {
    _timeoutTimer?.cancel();
    _dimTimer?.cancel();

    _timeoutTimer = Timer(_timeoutDuration, () {
      debugPrint('🔋 Screen timeout: 3 minutes reached, starting dim sequence');
      _startDimSequence();
    });

    debugPrint('🔋 Screen timeout: Timer reset to 3 minutes');
  }

  static void _startDimSequence() {
    debugPrint('🔋 Screen timeout: Starting dim sequence');

    // Dim the screen
    _dimScreen();

    // Start timer for final timeout
    _dimTimer = Timer(_dimDuration, () {
      debugPrint('🔋 Screen timeout: Dim period ended, disabling wakelock');
      disableExtendedTimeout();
    });
  }

  static Future<void> _dimScreen() async {
    try {
      _isDimmed = true;

      // Save original brightness before dimming
      if (_originalBrightness == null) {
        _originalBrightness = await ScreenBrightness().current;
        debugPrint(
            '🔋 Screen timeout: Saved original brightness: $_originalBrightness');
      }

      // Dim the screen to 10% brightness
      await ScreenBrightness().setScreenBrightness(_dimBrightness);

      debugPrint(
          '🔋 Screen timeout: Screen dimmed to ${(_dimBrightness * 100).toInt()}%');

      // Optional: Add a subtle animation or notification
      // You could show a small toast or overlay here
    } catch (e) {
      debugPrint('❌ Error dimming screen: $e');

      // Fallback to system UI changes if brightness control fails
      await _fallbackDimScreen();
    }
  }

  static Future<void> _resetBrightness() async {
    try {
      if (_originalBrightness != null) {
        await ScreenBrightness().setScreenBrightness(_originalBrightness!);
        debugPrint(
            '🔋 Screen timeout: Brightness reset to $_originalBrightness');
      } else {
        // Reset to system brightness if we don't have original value
        await ScreenBrightness().resetScreenBrightness();
        debugPrint('🔋 Screen timeout: Brightness reset to system default');
      }
    } catch (e) {
      debugPrint('❌ Error resetting brightness: $e');

      // Fallback to system UI reset
      await _fallbackResetBrightness();
    }
  }

  // Fallback methods for devices that don't support brightness control
  static Future<void> _fallbackDimScreen() async {
    try {
      // Use system UI mode changes as fallback
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersive,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );

      debugPrint('🔋 Screen timeout: Fallback dim applied');
    } catch (e) {
      debugPrint('❌ Error in fallback dim: $e');
    }
  }

  static Future<void> _fallbackResetBrightness() async {
    try {
      // Reset system UI mode
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );

      debugPrint('🔋 Screen timeout: Fallback brightness reset');
    } catch (e) {
      debugPrint('❌ Error in fallback brightness reset: $e');
    }
  }

  /// Get current screen brightness
  static Future<double?> getCurrentBrightness() async {
    try {
      return await ScreenBrightness().current;
    } catch (e) {
      debugPrint('❌ Error getting current brightness: $e');
      return null;
    }
  }

  /// Check if wakelock is currently enabled
  static bool get isEnabled => _isWakeLockEnabled;

  /// Check if we should maintain wakelock
  static bool get shouldMaintainWakelock => _shouldMaintainWakelock;

  /// Check if screen is currently dimmed
  static bool get isDimmed => _isDimmed;

  /// Get original brightness level
  static double? get originalBrightness => _originalBrightness;

  /// Get current dimmed brightness level
  static double get dimBrightness => _dimBrightness;

  /// Get current wakelock status from the system
  static Future<bool> isWakeLockEnabled() async {
    try {
      return await WakelockPlus.enabled;
    } catch (e) {
      debugPrint('❌ Error checking wakelock status: $e');
      return false;
    }
  }

  /// Dispose all resources
  static Future<void> dispose() async {
    _timeoutTimer?.cancel();
    _dimTimer?.cancel();

    if (_isDimmed) {
      await _resetBrightness();
      _isDimmed = false;
    }

    if (_isWakeLockEnabled) {
      await WakelockPlus.disable();
      _isWakeLockEnabled = false;
    }

    _shouldMaintainWakelock = false;
    _originalBrightness = null;
  }
}

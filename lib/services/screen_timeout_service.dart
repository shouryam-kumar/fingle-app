import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ScreenTimeoutService {
  static const Duration _timeoutDuration = Duration(minutes: 3);
  static Timer? _timeoutTimer;
  static bool _isWakeLockEnabled = false;

  /// Enable wakelock and start 3-minute timer
  static Future<void> enableExtendedTimeout() async {
    try {
      if (!_isWakeLockEnabled) {
        await WakelockPlus.enable();
        _isWakeLockEnabled = true;
        debugPrint('🔋 Screen timeout: Wakelock enabled');
      }
      
      // Reset the timer
      _resetTimer();
    } catch (e) {
      debugPrint('❌ Error enabling wakelock: $e');
    }
  }

  /// Disable wakelock and cancel timer
  static Future<void> disableExtendedTimeout() async {
    try {
      _timeoutTimer?.cancel();
      
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
    if (_isWakeLockEnabled) {
      _resetTimer();
    }
  }

  static void _resetTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(_timeoutDuration, () {
      debugPrint('🔋 Screen timeout: 3 minutes reached, disabling wakelock');
      disableExtendedTimeout();
    });
    debugPrint('🔋 Screen timeout: Timer reset to 3 minutes');
  }

  /// Check if wakelock is currently enabled
  static bool get isEnabled => _isWakeLockEnabled;

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
    if (_isWakeLockEnabled) {
      await WakelockPlus.disable();
      _isWakeLockEnabled = false;
    }
  }
}
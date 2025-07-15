// lib/providers/app_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  int _currentIndex = 0;
  
  ThemeMode get themeMode => _themeMode;
  int get currentIndex => _currentIndex;
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveThemeMode();
  }
  
  void setCurrentIndex(int index) {
    final oldIndex = _currentIndex; // ✅ Store old value first
    _currentIndex = index;
    
    // 🐛 DEBUG: Track tab changes
    debugPrint('🔄 AppProvider: Tab changed from $oldIndex to $index');
    debugPrint('🔄 AppProvider: Tab names - Old: ${_getTabName(oldIndex)}, New: ${_getTabName(index)}');
    
    notifyListeners();
  }
  
  // Helper method to get tab names
  String _getTabName(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Search';
      case 2: return 'Fingle';
      case 3: return 'Activity';
      case 4: return 'Profile';
      default: return 'Unknown';
    }
  }
  
  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance(); // ✅ Fixed typo
    await prefs.setInt('theme_mode', _themeMode.index);
  }
  
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance(); // ✅ Fixed typo
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }
}
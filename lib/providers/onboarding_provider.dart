import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_models.dart';
import '../services/supabase/onboarding_service.dart';
import '../core/config/supabase_config.dart';

class OnboardingProvider with ChangeNotifier {
  OnboardingData _data = OnboardingData();
  bool _isLoading = false;
  String? _errorMessage;
  List<InterestCategory> _availableInterests = InterestCategory.getDefaultCategories();

  // Getters
  OnboardingData get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<InterestCategory> get availableInterests => _availableInterests;
  int get totalSteps => OnboardingStep.values.length;
  int get currentStepIndex => _data.currentStep.stepIndex;
  double get progress => (_data.currentStep.stepIndex + 1) / totalSteps;
  bool get canGoNext => _canProgressToNextStep();
  bool get canGoBack => _data.currentStep.stepIndex > 0;

  // Initialize onboarding
  Future<void> initializeOnboarding() async {
    _setLoading(true);
    
    try {
      // Check if user has existing onboarding data
      final savedData = await _loadSavedProgress();
      if (savedData != null) {
        _data = savedData;
      } else {
        // Start fresh onboarding
        _data = OnboardingData(
          startedAt: DateTime.now(),
          currentStep: OnboardingStep.welcome,
        );
      }
      
      // Load available interests from backend
      await _loadAvailableInterests();
      
      await _saveProgress();
      
    } catch (e) {
      _setError('Failed to initialize onboarding: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Step navigation
  Future<void> nextStep() async {
    if (!_canProgressToNextStep()) return;
    
    final nextStepIndex = _data.currentStep.stepIndex + 1;
    if (nextStepIndex < OnboardingStep.values.length) {
      _data = _data.copyWith(
        currentStep: OnboardingStep.fromIndex(nextStepIndex),
      );
      
      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> previousStep() async {
    if (_data.currentStep.stepIndex > 0) {
      _data = _data.copyWith(
        currentStep: OnboardingStep.fromIndex(_data.currentStep.stepIndex - 1),
      );
      
      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> goToStep(OnboardingStep step) async {
    _data = _data.copyWith(currentStep: step);
    await _saveProgress();
    notifyListeners();
  }

  Future<void> skipStep() async {
    await nextStep();
  }

  // Profile Setup Methods
  Future<void> updateProfileData({
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    int? age,
  }) async {
    _data = _data.copyWith(
      fullName: fullName ?? _data.fullName,
      username: username ?? _data.username,
      bio: bio ?? _data.bio,
      avatarUrl: avatarUrl ?? _data.avatarUrl,
      age: age ?? _data.age,
    );
    
    await _saveProgress();
    notifyListeners();
  }

  Future<bool> checkUsernameAvailability(String username) async {
    try {
      return await OnboardingService.checkUsernameAvailability(username);
    } catch (e) {
      _setError('Failed to check username availability');
      return false;
    }
  }

  Future<String?> uploadAvatar(String imagePath) async {
    _setLoading(true);
    
    try {
      final avatarUrl = await OnboardingService.uploadAvatar(imagePath);
      if (avatarUrl != null) {
        await updateProfileData(avatarUrl: avatarUrl);
      }
      return avatarUrl;
    } catch (e) {
      _setError('Failed to upload avatar: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Interest Selection Methods
  void toggleInterest(String interestId) {
    final interests = List<String>.from(_data.selectedInterests);
    
    if (interests.contains(interestId)) {
      interests.remove(interestId);
    } else {
      interests.add(interestId);
    }
    
    _data = _data.copyWith(selectedInterests: interests);
    
    // Update available interests selection state
    _availableInterests = _availableInterests.map((interest) {
      if (interest.id == interestId) {
        return interest.copyWith(isSelected: !interest.isSelected);
      }
      return interest;
    }).toList();
    
    _saveProgress();
    notifyListeners();
  }

  void selectInterests(List<String> interestIds) {
    _data = _data.copyWith(selectedInterests: interestIds);
    
    // Update available interests selection state
    _availableInterests = _availableInterests.map((interest) {
      return interest.copyWith(isSelected: interestIds.contains(interest.id));
    }).toList();
    
    _saveProgress();
    notifyListeners();
  }

  // Activity Level Methods
  void setActivityLevel(ActivityLevel level) {
    _data = _data.copyWith(activityLevel: level);
    _saveProgress();
    notifyListeners();
  }

  // Permissions Methods
  void updatePermission(String permissionName, bool isGranted) {
    final permissions = Map<String, bool>.from(_data.permissions);
    permissions[permissionName] = isGranted;
    
    _data = _data.copyWith(permissions: permissions);
    _saveProgress();
    notifyListeners();
  }

  // Complete Onboarding
  Future<bool> completeOnboarding() async {
    _setLoading(true);
    
    try {
      // Mark onboarding as completed
      _data = _data.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      
      // Sync all data with backend
      final success = await OnboardingService.completeOnboarding(_data);
      
      if (success) {
        await _saveProgress();
        await _clearSavedProgress(); // Clear temporary data
        return true;
      } else {
        _setError('Failed to complete onboarding');
        return false;
      }
      
    } catch (e) {
      _setError('Failed to complete onboarding: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Skip Entire Onboarding
  Future<bool> skipOnboarding() async {
    _setLoading(true);
    
    try {
      // Set minimal required data
      final currentUser = SupabaseConfig.currentUser;
      if (currentUser != null) {
        _data = _data.copyWith(
          fullName: currentUser.userMetadata?['full_name'] ?? 'User',
          username: currentUser.userMetadata?['username'] ?? 'user_${currentUser.id.substring(0, 8)}',
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        
        final success = await OnboardingService.completeOnboarding(_data);
        
        if (success) {
          await _clearSavedProgress();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      _setError('Failed to skip onboarding: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper Methods
  bool _canProgressToNextStep() {
    switch (_data.currentStep) {
      case OnboardingStep.welcome:
        return true; // Welcome can always progress
      case OnboardingStep.profileSetup:
        return _data.isProfileSetupComplete;
      case OnboardingStep.interests:
        return true; // Interests are optional
      case OnboardingStep.activityLevel:
        return _data.activityLevel != null;
      case OnboardingStep.permissions:
        return true; // Permissions are optional
    }
  }

  Future<void> _loadAvailableInterests() async {
    try {
      // Try to load from backend trending topics
      final backendInterests = await OnboardingService.getAvailableInterests();
      if (backendInterests.isNotEmpty) {
        _availableInterests = backendInterests;
      }
      // Otherwise use default categories
    } catch (e) {
      // Use default categories if backend fails
      print('Failed to load backend interests, using defaults: $e');
    }
  }

  Future<OnboardingData?> _loadSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('onboarding_progress');
      if (jsonString != null) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          Uri.splitQueryString(jsonString),
        );
        return OnboardingData.fromJson(json);
      }
    } catch (e) {
      print('Failed to load saved progress: $e');
    }
    return null;
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = _data.toJson().toString();
      await prefs.setString('onboarding_progress', jsonString);
    } catch (e) {
      print('Failed to save progress: $e');
    }
  }

  Future<void> _clearSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_progress');
    } catch (e) {
      print('Failed to clear saved progress: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset onboarding data
  void reset() {
    _data = OnboardingData();
    _isLoading = false;
    _errorMessage = null;
    _availableInterests = InterestCategory.getDefaultCategories();
    notifyListeners();
  }

}
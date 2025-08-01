import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../../lib/models/onboarding_models.dart';

void main() {
  group('ActivityLevel', () {
    test('should have correct enum values with properties', () {
      expect(ActivityLevel.beginner.title, 'Beginner');
      expect(ActivityLevel.beginner.description, 'Getting started with fitness');
      expect(ActivityLevel.beginner.emoji, '🌱');

      expect(ActivityLevel.intermediate.title, 'Intermediate');
      expect(ActivityLevel.intermediate.description, 'Regular exercise routine');
      expect(ActivityLevel.intermediate.emoji, '💪');

      expect(ActivityLevel.advanced.title, 'Advanced');
      expect(ActivityLevel.advanced.description, 'Serious fitness enthusiast');
      expect(ActivityLevel.advanced.emoji, '🔥');

      expect(ActivityLevel.professional.title, 'Professional');
      expect(ActivityLevel.professional.description, 'Athlete or trainer level');
      expect(ActivityLevel.professional.emoji, '🏆');
    });

    test('should have all required values in enum', () {
      expect(ActivityLevel.values.length, 4);
      expect(ActivityLevel.values, contains(ActivityLevel.beginner));
      expect(ActivityLevel.values, contains(ActivityLevel.intermediate));
      expect(ActivityLevel.values, contains(ActivityLevel.advanced));
      expect(ActivityLevel.values, contains(ActivityLevel.professional));
    });

    test('should maintain consistent property types', () {
      for (final level in ActivityLevel.values) {
        expect(level.title, isA<String>());
        expect(level.description, isA<String>());
        expect(level.emoji, isA<String>());
        expect(level.title.isNotEmpty, isTrue);
        expect(level.description.isNotEmpty, isTrue);
        expect(level.emoji.isNotEmpty, isTrue);
      }
    });

    test('should support enum name access', () {
      expect(ActivityLevel.beginner.name, 'beginner');
      expect(ActivityLevel.intermediate.name, 'intermediate');
      expect(ActivityLevel.advanced.name, 'advanced');
      expect(ActivityLevel.professional.name, 'professional');
    });
  });

  group('OnboardingStep', () {
    test('should have correct enum values with properties', () {
      expect(OnboardingStep.welcome.stepIndex, 0);
      expect(OnboardingStep.welcome.title, 'Welcome');

      expect(OnboardingStep.profileSetup.stepIndex, 1);
      expect(OnboardingStep.profileSetup.title, 'Profile Setup');

      expect(OnboardingStep.interests.stepIndex, 2);
      expect(OnboardingStep.interests.title, 'Your Interests');

      expect(OnboardingStep.activityLevel.stepIndex, 3);
      expect(OnboardingStep.activityLevel.title, 'Activity Level');

      expect(OnboardingStep.permissions.stepIndex, 4);
      expect(OnboardingStep.permissions.title, 'Permissions');
    });

    test('should have sequential step indices', () {
      final steps = OnboardingStep.values;
      for (int i = 0; i < steps.length; i++) {
        expect(steps[i].stepIndex, i);
      }
    });

    test('fromIndex should return correct step for valid indices', () {
      expect(OnboardingStep.fromIndex(0), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(1), OnboardingStep.profileSetup);
      expect(OnboardingStep.fromIndex(2), OnboardingStep.interests);
      expect(OnboardingStep.fromIndex(3), OnboardingStep.activityLevel);
      expect(OnboardingStep.fromIndex(4), OnboardingStep.permissions);
    });

    test('fromIndex should return welcome step for invalid indices', () {
      expect(OnboardingStep.fromIndex(-1), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(5), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(100), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(-100), OnboardingStep.welcome);
    });

    test('should have all required values in enum', () {
      expect(OnboardingStep.values.length, 5);
    });

    test('fromIndex should handle extreme values', () {
      expect(OnboardingStep.fromIndex(double.maxFinite.toInt()), OnboardingStep.welcome);
      expect(OnboardingStep.fromIndex(-double.maxFinite.toInt()), OnboardingStep.welcome);
    });
  });

  group('InterestCategory', () {
    test('should create instance with required parameters', () {
      final category = InterestCategory(
        id: 'test',
        name: 'Test Category',
        emoji: '🧪',
        description: 'Test description',
      );

      expect(category.id, 'test');
      expect(category.name, 'Test Category');
      expect(category.emoji, '🧪');
      expect(category.description, 'Test description');
      expect(category.isSelected, false);
    });

    test('should create instance with optional isSelected parameter', () {
      final category = InterestCategory(
        id: 'test',
        name: 'Test Category',
        emoji: '🧪',
        description: 'Test description',
        isSelected: true,
      );

      expect(category.isSelected, true);
    });

    test('copyWith should update only specified fields', () {
      final original = InterestCategory(
        id: 'original',
        name: 'Original Name',
        emoji: '🔄',
        description: 'Original description',
        isSelected: false,
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        isSelected: true,
      );

      expect(updated.id, 'original');
      expect(updated.name, 'Updated Name');
      expect(updated.emoji, '🔄');
      expect(updated.description, 'Original description');
      expect(updated.isSelected, true);
    });

    test('copyWith should preserve original values when no parameters provided', () {
      final original = InterestCategory(
        id: 'test',
        name: 'Test Name',
        emoji: '🧪',
        description: 'Test description',
        isSelected: true,
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.emoji, original.emoji);
      expect(copy.description, original.description);
      expect(copy.isSelected, original.isSelected);
    });

    test('copyWith should handle null values correctly', () {
      final original = InterestCategory(
        id: 'test',
        name: 'Test Name',
        emoji: '🧪',
        description: 'Test description',
        isSelected: true,
      );

      final updated = original.copyWith(
        id: null,
        name: null,
        emoji: null,
        description: null,
        isSelected: null,
      );

      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.emoji, original.emoji);
      expect(updated.description, original.description);
      expect(updated.isSelected, original.isSelected);
    });

    test('copyWith should handle individual field updates', () {
      final original = InterestCategory(
        id: 'test',
        name: 'Test Name',
        emoji: '🧪',
        description: 'Test description',
        isSelected: false,
      );

      // Test individual field updates
      final updatedId = original.copyWith(id: 'new_id');
      expect(updatedId.id, 'new_id');
      expect(updatedId.name, 'Test Name');

      final updatedName = original.copyWith(name: 'New Name');
      expect(updatedName.name, 'New Name');
      expect(updatedName.id, 'test');

      final updatedEmoji = original.copyWith(emoji: '🆕');
      expect(updatedEmoji.emoji, '🆕');
      expect(updatedEmoji.name, 'Test Name');

      final updatedDescription = original.copyWith(description: 'New description');
      expect(updatedDescription.description, 'New description');
      expect(updatedDescription.emoji, '🧪');

      final updatedSelection = original.copyWith(isSelected: true);
      expect(updatedSelection.isSelected, true);
      expect(updatedSelection.description, 'Test description');
    });

    test('getDefaultCategories should return predefined categories', () {
      final categories = InterestCategory.getDefaultCategories();

      expect(categories.length, 12);
      expect(categories.every((category) => category.isSelected == false), true);

      // Verify specific categories exist
      final fitnessCategory = categories.firstWhere((cat) => cat.id == 'fitness');
      expect(fitnessCategory.name, 'Fitness');
      expect(fitnessCategory.emoji, '💪');
      expect(fitnessCategory.description, 'General fitness and workouts');

      final runningCategory = categories.firstWhere((cat) => cat.id == 'running');
      expect(runningCategory.name, 'Running');
      expect(runningCategory.emoji, '🏃');

      final yogaCategory = categories.firstWhere((cat) => cat.id == 'yoga');
      expect(yogaCategory.name, 'Yoga');
      expect(yogaCategory.emoji, '🧘');
    });

    test('getDefaultCategories should have unique IDs', () {
      final categories = InterestCategory.getDefaultCategories();
      final ids = categories.map((cat) => cat.id).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, uniqueIds.length);
    });

    test('getDefaultCategories should have consistent data structure', () {
      final categories = InterestCategory.getDefaultCategories();

      for (final category in categories) {
        expect(category.id.isNotEmpty, true);
        expect(category.name.isNotEmpty, true);
        expect(category.emoji.isNotEmpty, true);
        expect(category.description.isNotEmpty, true);
        expect(category.isSelected, false);
      }
    });

    test('getDefaultCategories should include expected category IDs', () {
      final categories = InterestCategory.getDefaultCategories();
      final expectedIds = [
        'fitness', 'running', 'yoga', 'cycling', 'strength', 'swimming',
        'dance', 'martial_arts', 'hiking', 'sports', 'nutrition', 'wellness'
      ];

      final actualIds = categories.map((cat) => cat.id).toList();
      expect(actualIds, containsAll(expectedIds));
    });

    test('getDefaultCategories should return new instances each time', () {
      final categories1 = InterestCategory.getDefaultCategories();
      final categories2 = InterestCategory.getDefaultCategories();

      expect(identical(categories1, categories2), false);
      expect(categories1.length, categories2.length);
      
      // Verify that modifying one doesn't affect the other
      final modifiedCategory = categories1[0].copyWith(isSelected: true);
      expect(modifiedCategory.isSelected, true);
      expect(categories2[0].isSelected, false);
    });

    test('should handle empty string parameters', () {
      final category = InterestCategory(
        id: '',
        name: '',
        emoji: '',
        description: '',
      );

      expect(category.id, '');
      expect(category.name, '');
      expect(category.emoji, '');
      expect(category.description, '');
    });

    test('should handle special characters in parameters', () {
      final category = InterestCategory(
        id: 'test-id_123',
        name: 'Test & Category (Special)',
        emoji: '🏃‍♂️',
        description: 'Description with special chars: @#$%^&*()',
      );

      expect(category.id, 'test-id_123');
      expect(category.name, 'Test & Category (Special)');
      expect(category.emoji, '🏃‍♂️');
      expect(category.description, 'Description with special chars: @#$%^&*()');
    });
  });

  group('PermissionInfo', () {
    test('should create instance with required parameters', () {
      final permission = PermissionInfo(
        name: 'camera',
        title: 'Camera Access',
        description: 'Access to camera for photos',
        benefit: 'Take profile pictures',
        icon: Icons.camera_alt,
      );

      expect(permission.name, 'camera');
      expect(permission.title, 'Camera Access');
      expect(permission.description, 'Access to camera for photos');
      expect(permission.benefit, 'Take profile pictures');
      expect(permission.icon, Icons.camera_alt);
      expect(permission.isRequired, false);
      expect(permission.isGranted, false);
    });

    test('should create instance with optional parameters', () {
      final permission = PermissionInfo(
        name: 'location',
        title: 'Location Access',
        description: 'Access to device location',
        benefit: 'Find nearby gyms',
        icon: Icons.location_on,
        isRequired: true,
        isGranted: true,
      );

      expect(permission.isRequired, true);
      expect(permission.isGranted, true);
    });

    test('copyWith should update only specified fields', () {
      final original = PermissionInfo(
        name: 'notifications',
        title: 'Push Notifications',
        description: 'Send workout reminders',
        benefit: 'Stay motivated',
        icon: Icons.notifications,
        isRequired: false,
        isGranted: false,
      );

      final updated = original.copyWith(
        title: 'Updated Notifications',
        isGranted: true,
      );

      expect(updated.name, 'notifications');
      expect(updated.title, 'Updated Notifications');
      expect(updated.description, 'Send workout reminders');
      expect(updated.benefit, 'Stay motivated');
      expect(updated.icon, Icons.notifications);
      expect(updated.isRequired, false);
      expect(updated.isGranted, true);
    });

    test('copyWith should preserve original values when no parameters provided', () {
      final original = PermissionInfo(
        name: 'storage',
        title: 'Storage Access',
        description: 'Save workout data',
        benefit: 'Offline access',
        icon: Icons.storage,
        isRequired: true,
        isGranted: true,
      );

      final copy = original.copyWith();

      expect(copy.name, original.name);
      expect(copy.title, original.title);
      expect(copy.description, original.description);
      expect(copy.benefit, original.benefit);
      expect(copy.icon, original.icon);
      expect(copy.isRequired, original.isRequired);
      expect(copy.isGranted, original.isGranted);
    });

    test('copyWith should handle null values correctly', () {
      final original = PermissionInfo(
        name: 'test',
        title: 'Test Permission',
        description: 'Test description',
        benefit: 'Test benefit',
        icon: Icons.accessibility,
        isRequired: true,
        isGranted: true,
      );

      final updated = original.copyWith(
        name: null,
        title: null,
        description: null,
        benefit: null,
        icon: null,
        isRequired: null,
        isGranted: null,
      );

      expect(updated.name, original.name);
      expect(updated.title, original.title);
      expect(updated.description, original.description);
      expect(updated.benefit, original.benefit);
      expect(updated.icon, original.icon);
      expect(updated.isRequired, original.isRequired);
      expect(updated.isGranted, original.isGranted);
    });

    test('copyWith should handle individual field updates', () {
      final original = PermissionInfo(
        name: 'test',
        title: 'Test Permission',
        description: 'Test description',
        benefit: 'Test benefit',
        icon: Icons.accessibility,
        isRequired: false,
        isGranted: false,
      );

      // Test individual field updates
      final updatedName = original.copyWith(name: 'new_permission');
      expect(updatedName.name, 'new_permission');
      expect(updatedName.title, 'Test Permission');

      final updatedTitle = original.copyWith(title: 'New Title');
      expect(updatedTitle.title, 'New Title');
      expect(updatedTitle.name, 'test');

      final updatedDescription = original.copyWith(description: 'New description');
      expect(updatedDescription.description, 'New description');
      expect(updatedDescription.benefit, 'Test benefit');

      final updatedBenefit = original.copyWith(benefit: 'New benefit');
      expect(updatedBenefit.benefit, 'New benefit');
      expect(updatedBenefit.description, 'Test description');

      final updatedIcon = original.copyWith(icon: Icons.new_releases);
      expect(updatedIcon.icon, Icons.new_releases);
      expect(updatedIcon.benefit, 'Test benefit');

      final updatedRequired = original.copyWith(isRequired: true);
      expect(updatedRequired.isRequired, true);
      expect(updatedRequired.isGranted, false);

      final updatedGranted = original.copyWith(isGranted: true);
      expect(updatedGranted.isGranted, true);
      expect(updatedGranted.isRequired, false);
    });

    test('should handle empty string parameters', () {
      final permission = PermissionInfo(
        name: '',
        title: '',
        description: '',
        benefit: '',
        icon: Icons.help,
      );

      expect(permission.name, '');
      expect(permission.title, '');
      expect(permission.description, '');
      expect(permission.benefit, '');
    });

    test('should handle special characters in parameters', () {
      final permission = PermissionInfo(
        name: 'test_permission-123',
        title: 'Test & Permission (Special)',
        description: 'Permission with special chars: @#$%',
        benefit: 'Benefit with emojis: 💪🔥',
        icon: Icons.security,
      );

      expect(permission.name, 'test_permission-123');
      expect(permission.title, 'Test & Permission (Special)');
      expect(permission.description, 'Permission with special chars: @#$%');
      expect(permission.benefit, 'Benefit with emojis: 💪🔥');
    });
  });

  group('OnboardingData', () {
    test('should create instance with default values', () {
      final data = OnboardingData();

      expect(data.fullName, null);
      expect(data.username, null);
      expect(data.bio, null);
      expect(data.avatarUrl, null);
      expect(data.age, null);
      expect(data.selectedInterests, []);
      expect(data.activityLevel, null);
      expect(data.permissions, {});
      expect(data.currentStep, OnboardingStep.welcome);
      expect(data.isCompleted, false);
      expect(data.startedAt, null);
      expect(data.completedAt, null);
    });

    test('should create instance with provided values', () {
      final startTime = DateTime.now();
      final data = OnboardingData(
        fullName: 'John Doe',
        username: 'johndoe',
        bio: 'Fitness enthusiast',
        avatarUrl: 'https://example.com/avatar.jpg',
        age: 25,
        selectedInterests: ['fitness', 'running'],
        activityLevel: ActivityLevel.intermediate,
        permissions: {'camera': true, 'location': false},
        currentStep: OnboardingStep.profileSetup,
        isCompleted: true,
        startedAt: startTime,
      );

      expect(data.fullName, 'John Doe');
      expect(data.username, 'johndoe');
      expect(data.bio, 'Fitness enthusiast');
      expect(data.avatarUrl, 'https://example.com/avatar.jpg');
      expect(data.age, 25);
      expect(data.selectedInterests, ['fitness', 'running']);
      expect(data.activityLevel, ActivityLevel.intermediate);
      expect(data.permissions, {'camera': true, 'location': false});
      expect(data.currentStep, OnboardingStep.profileSetup);
      expect(data.isCompleted, true);
      expect(data.startedAt, startTime);
    });

    test('copyWith should update only specified fields', () {
      final original = OnboardingData(
        fullName: 'Original Name',
        username: 'original',
        selectedInterests: ['fitness'],
        activityLevel: ActivityLevel.beginner,
      );

      final updated = original.copyWith(
        fullName: 'Updated Name',
        selectedInterests: ['fitness', 'yoga'],
      );

      expect(updated.fullName, 'Updated Name');
      expect(updated.username, 'original');
      expect(updated.selectedInterests, ['fitness', 'yoga']);
      expect(updated.activityLevel, ActivityLevel.beginner);
    });

    test('copyWith should preserve original values when no parameters provided', () {
      final original = OnboardingData(
        fullName: 'Test User',
        username: 'testuser',
        selectedInterests: ['running'],
        activityLevel: ActivityLevel.advanced,
        isCompleted: true,
      );

      final copy = original.copyWith();

      expect(copy.fullName, original.fullName);
      expect(copy.username, original.username);
      expect(copy.selectedInterests, original.selectedInterests);
      expect(copy.activityLevel, original.activityLevel);
      expect(copy.isCompleted, original.isCompleted);
    });

    test('isProfileSetupComplete should validate required profile fields', () {
      // Incomplete profile - no name or username
      final incompleteData1 = OnboardingData();
      expect(incompleteData1.isProfileSetupComplete, false);

      // Incomplete profile - empty name
      final incompleteData2 = OnboardingData(fullName: '', username: 'test');
      expect(incompleteData2.isProfileSetupComplete, false);

      // Incomplete profile - empty username
      final incompleteData3 = OnboardingData(fullName: 'Test', username: '');
      expect(incompleteData3.isProfileSetupComplete, false);

      // Incomplete profile - null username
      final incompleteData4 = OnboardingData(fullName: 'Test');
      expect(incompleteData4.isProfileSetupComplete, false);

      // Complete profile
      final completeData = OnboardingData(fullName: 'Test User', username: 'testuser');
      expect(completeData.isProfileSetupComplete, true);
    });

    test('hasMinimumInterests should require at least 3 interests', () {
      final noInterests = OnboardingData();
      expect(noInterests.hasMinimumInterests, false);

      final oneInterest = OnboardingData(selectedInterests: ['fitness']);
      expect(oneInterest.hasMinimumInterests, false);

      final twoInterests = OnboardingData(selectedInterests: ['fitness', 'yoga']);
      expect(twoInterests.hasMinimumInterests, false);

      final threeInterests = OnboardingData(selectedInterests: ['fitness', 'yoga', 'running']);
      expect(threeInterests.hasMinimumInterests, true);

      final moreInterests = OnboardingData(selectedInterests: ['fitness', 'yoga', 'running', 'cycling']);
      expect(moreInterests.hasMinimumInterests, true);
    });

    test('isReadyToComplete should validate profile and activity level', () {
      final incompleteProfile = OnboardingData(activityLevel: ActivityLevel.beginner);
      expect(incompleteProfile.isReadyToComplete, false);

      final noActivityLevel = OnboardingData(fullName: 'Test', username: 'test');
      expect(noActivityLevel.isReadyToComplete, false);

      final readyToComplete = OnboardingData(
        fullName: 'Test User',
        username: 'testuser',
        activityLevel: ActivityLevel.intermediate,
      );
      expect(readyToComplete.isReadyToComplete, true);
    });

    test('completionProgress should calculate progress correctly', () {
      // Base progress (welcome step)
      final baseData = OnboardingData();
      expect(baseData.completionProgress, 0.2);

      // With profile setup
      final withProfile = OnboardingData(fullName: 'Test', username: 'test');
      expect(withProfile.completionProgress, 0.4);

      // With interests
      final withInterests = OnboardingData(
        fullName: 'Test',
        username: 'test',
        selectedInterests: ['fitness'],
      );
      expect(withInterests.completionProgress, 0.6);

      // With activity level
      final withActivityLevel = OnboardingData(
        fullName: 'Test',
        username: 'test',
        selectedInterests: ['fitness'],
        activityLevel: ActivityLevel.beginner,
      );
      expect(withActivityLevel.completionProgress, 0.8);

      // With permissions
      final withPermissions = OnboardingData(
        fullName: 'Test',
        username: 'test',
        selectedInterests: ['fitness'],
        activityLevel: ActivityLevel.beginner,
        permissions: {'camera': true},
      );
      expect(withPermissions.completionProgress, 1.0);
    });

    test('completionProgress should be clamped between 0.0 and 1.0', () {
      final data = OnboardingData(
        fullName: 'Test',
        username: 'test',
        selectedInterests: ['fitness', 'yoga', 'running'],
        activityLevel: ActivityLevel.advanced,
        permissions: {'camera': true, 'location': true, 'notifications': true},
      );

      final progress = data.completionProgress;
      expect(progress, greaterThanOrEqualTo(0.0));
      expect(progress, lessThanOrEqualTo(1.0));
    });

    test('toJson should serialize all fields correctly', () {
      final startTime = DateTime.parse('2023-01-01T10:00:00.000Z');
      final completedTime = DateTime.parse('2023-01-01T11:00:00.000Z');

      final data = OnboardingData(
        fullName: 'Test User',
        username: 'testuser',
        bio: 'Test bio',
        avatarUrl: 'https://example.com/avatar.jpg',
        age: 30,
        selectedInterests: ['fitness', 'yoga'],
        activityLevel: ActivityLevel.intermediate,
        permissions: {'camera': true, 'location': false},
        currentStep: OnboardingStep.activityLevel,
        isCompleted: true,
        startedAt: startTime,
        completedAt: completedTime,
      );

      final json = data.toJson();

      expect(json['fullName'], 'Test User');
      expect(json['username'], 'testuser');
      expect(json['bio'], 'Test bio');
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
      expect(json['age'], 30);
      expect(json['selectedInterests'], ['fitness', 'yoga']);
      expect(json['activityLevel'], 'intermediate');
      expect(json['permissions'], {'camera': true, 'location': false});
      expect(json['currentStep'], 3);
      expect(json['isCompleted'], true);
      expect(json['startedAt'], '2023-01-01T10:00:00.000Z');
      expect(json['completedAt'], '2023-01-01T11:00:00.000Z');
    });

    test('toJson should handle null values correctly', () {
      final data = OnboardingData();
      final json = data.toJson();

      expect(json['fullName'], null);
      expect(json['username'], null);
      expect(json['bio'], null);
      expect(json['avatarUrl'], null);
      expect(json['age'], null);
      expect(json['selectedInterests'], []);
      expect(json['activityLevel'], null);
      expect(json['permissions'], {});
      expect(json['currentStep'], 0);
      expect(json['isCompleted'], false);
      expect(json['startedAt'], null);
      expect(json['completedAt'], null);
    });

    test('fromJson should deserialize all fields correctly', () {
      final json = {
        'fullName': 'Test User',
        'username': 'testuser',
        'bio': 'Test bio',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'age': 30,
        'selectedInterests': ['fitness', 'yoga'],
        'activityLevel': 'intermediate',
        'permissions': {'camera': true, 'location': false},
        'currentStep': 3,
        'isCompleted': true,
        'startedAt': '2023-01-01T10:00:00.000Z',
        'completedAt': '2023-01-01T11:00:00.000Z',
      };

      final data = OnboardingData.fromJson(json);

      expect(data.fullName, 'Test User');
      expect(data.username, 'testuser');
      expect(data.bio, 'Test bio');
      expect(data.avatarUrl, 'https://example.com/avatar.jpg');
      expect(data.age, 30);
      expect(data.selectedInterests, ['fitness', 'yoga']);
      expect(data.activityLevel, ActivityLevel.intermediate);
      expect(data.permissions, {'camera': true, 'location': false});
      expect(data.currentStep, OnboardingStep.activityLevel);
      expect(data.isCompleted, true);
      expect(data.startedAt, DateTime.parse('2023-01-01T10:00:00.000Z'));
      expect(data.completedAt, DateTime.parse('2023-01-01T11:00:00.000Z'));
    });

    test('fromJson should handle missing fields with defaults', () {
      final json = <String, dynamic>{};
      final data = OnboardingData.fromJson(json);

      expect(data.fullName, null);
      expect(data.username, null);
      expect(data.bio, null);
      expect(data.avatarUrl, null);
      expect(data.age, null);
      expect(data.selectedInterests, []);
      expect(data.activityLevel, null);
      expect(data.permissions, {});
      expect(data.currentStep, OnboardingStep.welcome);
      expect(data.isCompleted, false);
      expect(data.startedAt, null);
      expect(data.completedAt, null);
    });

    test('fromJson should handle invalid activity level gracefully', () {
      final json = {
        'activityLevel': 'invalid_level',
      };

      final data = OnboardingData.fromJson(json);
      expect(data.activityLevel, ActivityLevel.beginner);
    });

    test('fromJson should handle invalid currentStep gracefully', () {
      final json = {
        'currentStep': 999,
      };

      final data = OnboardingData.fromJson(json);
      expect(data.currentStep, OnboardingStep.welcome);
    });

    test('fromJson should handle invalid date strings gracefully', () {
      final json = {
        'startedAt': 'invalid-date',
        'completedAt': 'invalid-date',
      };

      expect(() => OnboardingData.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('serialization round-trip should preserve data', () {
      final originalData = OnboardingData(
        fullName: 'Round Trip Test',
        username: 'roundtrip',
        bio: 'Testing serialization',
        age: 25,
        selectedInterests: ['fitness', 'yoga', 'running'],
        activityLevel: ActivityLevel.advanced,
        permissions: {'camera': true, 'location': true},
        currentStep: OnboardingStep.permissions,
        isCompleted: false,
        startedAt: DateTime.now(),
      );

      final json = originalData.toJson();
      final deserializedData = OnboardingData.fromJson(json);

      expect(deserializedData.fullName, originalData.fullName);
      expect(deserializedData.username, originalData.username);
      expect(deserializedData.bio, originalData.bio);
      expect(deserializedData.age, originalData.age);
      expect(deserializedData.selectedInterests, originalData.selectedInterests);
      expect(deserializedData.activityLevel, originalData.activityLevel);
      expect(deserializedData.permissions, originalData.permissions);
      expect(deserializedData.currentStep, originalData.currentStep);
      expect(deserializedData.isCompleted, originalData.isCompleted);
      expect(deserializedData.startedAt, originalData.startedAt);
    });

    test('should handle edge cases for age validation', () {
      final negativeAge = OnboardingData(age: -1);
      expect(negativeAge.age, -1); // Model doesn't validate age, just stores it

      final zeroAge = OnboardingData(age: 0);
      expect(zeroAge.age, 0);

      final largeAge = OnboardingData(age: 150);
      expect(largeAge.age, 150);
    });

    test('should handle empty and whitespace strings in profile validation', () {
      final whitespaceData = OnboardingData(fullName: '   ', username: '   ');
      expect(whitespaceData.isProfileSetupComplete, false);

      final tabData = OnboardingData(fullName: '\t\n', username: '\t\n');
      expect(tabData.isProfileSetupComplete, false);
    });

    test('should handle large collections in selectedInterests', () {
      final largeInterestsList = List.generate(100, (index) => 'interest_$index');
      final data = OnboardingData(selectedInterests: largeInterestsList);
      
      expect(data.selectedInterests.length, 100);
      expect(data.hasMinimumInterests, true);
    });

    test('should handle large permissions map', () {
      final largePermissionsMap = Map.fromEntries(
        List.generate(50, (index) => MapEntry('permission_$index', index % 2 == 0))
      );
      final data = OnboardingData(permissions: largePermissionsMap);
      
      expect(data.permissions.length, 50);
      expect(data.completionProgress, 1.0); // Should include permissions progress
    });

    test('fromJson should handle null values in JSON', () {
      final json = {
        'fullName': null,
        'username': null,
        'bio': null,
        'avatarUrl': null,
        'age': null,
        'selectedInterests': null,
        'activityLevel': null,
        'permissions': null,
        'currentStep': null,
        'isCompleted': null,
        'startedAt': null,
        'completedAt': null,
      };

      final data = OnboardingData.fromJson(json);

      expect(data.fullName, null);
      expect(data.username, null);
      expect(data.bio, null);
      expect(data.avatarUrl, null);
      expect(data.age, null);
      expect(data.selectedInterests, []);
      expect(data.activityLevel, null);
      expect(data.permissions, {});
      expect(data.currentStep, OnboardingStep.welcome);
      expect(data.isCompleted, false);
      expect(data.startedAt, null);
      expect(data.completedAt, null);
    });

    test('fromJson should handle mixed data types gracefully', () {
      final json = {
        'age': '25', // String instead of int
        'isCompleted': 'true', // String instead of bool
        'currentStep': '2', // String instead of int
      };

      // These should not cause crashes, but may not parse correctly
      expect(() => OnboardingData.fromJson(json), isNot(throwsA(anything)));
    });

    test('completionProgress edge cases', () {
      // Test partial profile completion
      final partialProfile1 = OnboardingData(fullName: 'Test');
      expect(partialProfile1.completionProgress, 0.2); // Only welcome step

      final partialProfile2 = OnboardingData(username: 'test');
      expect(partialProfile2.completionProgress, 0.2); // Only welcome step

      // Test empty but non-null interests
      final emptyInterests = OnboardingData(
        fullName: 'Test',
        username: 'test',
        selectedInterests: [],
      );
      expect(emptyInterests.completionProgress, 0.4); // Profile but no interests

      // Test empty permissions map
      final emptyPermissions = OnboardingData(
        fullName: 'Test',
        username: 'test',
        permissions: {},
      );
      expect(emptyPermissions.completionProgress, 0.4); // Profile only
    });

    test('copyWith should handle DateTime fields', () {
      final startTime = DateTime.now();
      final completedTime = DateTime.now().add(Duration(hours: 1));

      final original = OnboardingData(startedAt: startTime);
      final updated = original.copyWith(completedAt: completedTime);

      expect(updated.startedAt, startTime);
      expect(updated.completedAt, completedTime);
    });

    test('should handle special characters in text fields', () {
      final data = OnboardingData(
        fullName: 'José María García-López',
        username: 'user_123-test',
        bio: 'Fitness enthusiast 💪 with emojis & special chars @#$%',
        avatarUrl: 'https://example.com/avatars/josé-maría.jpg?size=large&format=webp',
      );

      expect(data.fullName, 'José María García-López');
      expect(data.username, 'user_123-test');
      expect(data.bio, 'Fitness enthusiast 💪 with emojis & special chars @#$%');
      expect(data.avatarUrl, 'https://example.com/avatars/josé-maría.jpg?size=large&format=webp');

      // Test serialization preserves special characters
      final json = data.toJson();
      final deserialized = OnboardingData.fromJson(json);
      
      expect(deserialized.fullName, data.fullName);
      expect(deserialized.username, data.username);
      expect(deserialized.bio, data.bio);
      expect(deserialized.avatarUrl, data.avatarUrl);
    });
  });
}
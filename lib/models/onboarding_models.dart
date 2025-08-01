import 'package:flutter/material.dart';

enum ActivityLevel {
  beginner('Beginner', 'Getting started with fitness', '🌱'),
  intermediate('Intermediate', 'Regular exercise routine', '💪'),
  advanced('Advanced', 'Serious fitness enthusiast', '🔥'),
  professional('Professional', 'Athlete or trainer level', '🏆');

  const ActivityLevel(this.title, this.description, this.emoji);
  
  final String title;
  final String description;
  final String emoji;
}

enum OnboardingStep {
  welcome(0, 'Welcome'),
  profileSetup(1, 'Profile Setup'),
  interests(2, 'Your Interests'), 
  activityLevel(3, 'Activity Level'),
  permissions(4, 'Permissions');

  const OnboardingStep(this.stepIndex, this.title);
  
  final int stepIndex;
  final String title;
  
  static OnboardingStep fromIndex(int stepIndex) {
    return OnboardingStep.values.firstWhere(
      (step) => step.stepIndex == stepIndex,
      orElse: () => OnboardingStep.welcome,
    );
  }
}

class InterestCategory {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final bool isSelected;

  InterestCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    this.isSelected = false,
  });

  InterestCategory copyWith({
    String? id,
    String? name,
    String? emoji,
    String? description,
    bool? isSelected,
  }) {
    return InterestCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  static List<InterestCategory> getDefaultCategories() {
    return [
      InterestCategory(
        id: 'fitness',
        name: 'Fitness',
        emoji: '💪',
        description: 'General fitness and workouts',
      ),
      InterestCategory(
        id: 'running',
        name: 'Running',
        emoji: '🏃',
        description: 'Running, jogging, and cardio',
      ),
      InterestCategory(
        id: 'yoga',
        name: 'Yoga',
        emoji: '🧘',
        description: 'Yoga, meditation, and mindfulness',
      ),
      InterestCategory(
        id: 'cycling',
        name: 'Cycling',
        emoji: '🚴',
        description: 'Cycling, biking, and spinning',
      ),
      InterestCategory(
        id: 'strength',
        name: 'Strength Training',
        emoji: '🏋️',
        description: 'Weight lifting and strength building',
      ),
      InterestCategory(
        id: 'swimming',
        name: 'Swimming',
        emoji: '🏊',
        description: 'Swimming and water sports',
      ),
      InterestCategory(
        id: 'dance',
        name: 'Dance',
        emoji: '💃',
        description: 'Dance fitness and choreography',
      ),
      InterestCategory(
        id: 'martial_arts',
        name: 'Martial Arts',
        emoji: '🥋',
        description: 'Martial arts and combat sports',
      ),
      InterestCategory(
        id: 'hiking',
        name: 'Hiking',
        emoji: '🥾',
        description: 'Hiking, trekking, and outdoor activities',
      ),
      InterestCategory(
        id: 'sports',
        name: 'Team Sports',
        emoji: '⚽',
        description: 'Football, basketball, and team games',
      ),
      InterestCategory(
        id: 'nutrition',
        name: 'Nutrition',
        emoji: '🥗',
        description: 'Healthy eating and nutrition tips',
      ),
      InterestCategory(
        id: 'wellness',
        name: 'Wellness',
        emoji: '🌿',
        description: 'Mental health and overall wellness',
      ),
    ];
  }
}

class PermissionInfo {
  final String name;
  final String title;
  final String description;
  final String benefit;
  final IconData icon;
  final bool isRequired;
  final bool isGranted;

  PermissionInfo({
    required this.name,
    required this.title,
    required this.description,
    required this.benefit,
    required this.icon,
    this.isRequired = false,
    this.isGranted = false,
  });

  PermissionInfo copyWith({
    String? name,
    String? title,
    String? description,
    String? benefit,
    IconData? icon,
    bool? isRequired,
    bool? isGranted,
  }) {
    return PermissionInfo(
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      benefit: benefit ?? this.benefit,
      icon: icon ?? this.icon,
      isRequired: isRequired ?? this.isRequired,
      isGranted: isGranted ?? this.isGranted,
    );
  }
}

class OnboardingData {
  // Profile Setup Data
  String? fullName;
  String? username;
  String? bio;
  String? avatarUrl;
  int? age;
  
  // Interests Data
  List<String> selectedInterests;
  
  // Activity Level Data
  ActivityLevel? activityLevel;
  
  // Permissions Data
  Map<String, bool> permissions;
  
  // Progress Tracking
  OnboardingStep currentStep;
  bool isCompleted;
  DateTime? startedAt;
  DateTime? completedAt;

  OnboardingData({
    this.fullName,
    this.username,
    this.bio,
    this.avatarUrl,
    this.age,
    this.selectedInterests = const [],
    this.activityLevel,
    this.permissions = const {},
    this.currentStep = OnboardingStep.welcome,
    this.isCompleted = false,
    this.startedAt,
    this.completedAt,
  });

  OnboardingData copyWith({
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    int? age,
    List<String>? selectedInterests,
    ActivityLevel? activityLevel,
    Map<String, bool>? permissions,
    OnboardingStep? currentStep,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return OnboardingData(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      activityLevel: activityLevel ?? this.activityLevel,
      permissions: permissions ?? this.permissions,
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'username': username,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'age': age,
      'selectedInterests': selectedInterests,
      'activityLevel': activityLevel?.name,
      'permissions': permissions,
      'currentStep': currentStep.stepIndex,
      'isCompleted': isCompleted,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      fullName: json['fullName'],
      username: json['username'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      age: json['age'],
      selectedInterests: List<String>.from(json['selectedInterests'] ?? []),
      activityLevel: json['activityLevel'] != null 
          ? ActivityLevel.values.firstWhere(
              (level) => level.name == json['activityLevel'],
              orElse: () => ActivityLevel.beginner,
            )
          : null,
      permissions: Map<String, bool>.from(json['permissions'] ?? {}),
      currentStep: OnboardingStep.fromIndex(json['currentStep'] ?? 0),
      isCompleted: json['isCompleted'] ?? false,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  // Validation methods
  bool get isProfileSetupComplete {
    return fullName != null && 
           fullName!.isNotEmpty && 
           username != null && 
           username!.isNotEmpty;
  }

  bool get hasMinimumInterests {
    return selectedInterests.length >= 3;
  }

  bool get isReadyToComplete {
    return isProfileSetupComplete && activityLevel != null;
  }

  double get completionProgress {
    double progress = 0.0;
    
    // Welcome step is always complete when we start
    progress += 0.2;
    
    // Profile setup completion
    if (isProfileSetupComplete) progress += 0.2;
    
    // Interests completion (optional but recommended)
    if (selectedInterests.isNotEmpty) progress += 0.2;
    
    // Activity level completion
    if (activityLevel != null) progress += 0.2;
    
    // Permissions completion (optional)
    if (permissions.isNotEmpty) progress += 0.2;
    
    return progress.clamp(0.0, 1.0);
  }
}
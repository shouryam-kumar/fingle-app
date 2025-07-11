class Post {
  final String id;
  final String imageUrl;
  final String category;
  final String title;
  final int likes;
  final int views;
  final DateTime createdAt;
  final List<String> tags;

  Post({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.title,
    this.likes = 0,
    this.views = 0,
    required this.createdAt,
    this.tags = const [],
  });
}

class UserStats {
  final int totalPosts;
  final int followers;
  final int following;
  final int totalViews;

  UserStats({
    required this.totalPosts,
    required this.followers,
    required this.following,
    required this.totalViews,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final DateTime unlockedAt;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.unlockedAt,
    required this.isUnlocked,
  });
}

class User {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String profilePic;
  final String coverImage;
  final List<Post> posts;
  final UserStats stats;
  final List<Achievement> achievements;
  final bool isVerified;
  final DateTime joinedAt;
  final List<String> interests;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.profilePic,
    required this.coverImage,
    required this.posts,
    required this.stats,
    required this.achievements,
    this.isVerified = false,
    required this.joinedAt,
    required this.interests,
  });
}

// Sample data for testing
final User sampleUser = User(
  id: '1',
  name: 'Alex Johnson',
  age: 28,
  bio: 'Fitness junkie | Love hiking | Looking for someone to spot me 💪🏽\nTransforming lives through fitness 🔥',
  profilePic: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=300&h=300&fit=crop&crop=face',
  coverImage: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
  isVerified: true,
  joinedAt: DateTime(2023, 6, 15),
  interests: ['Strength Training', 'Cardio', 'Yoga', 'Nutrition', 'HIIT'],
  stats: UserStats(
    totalPosts: 12,
    followers: 12500,
    following: 890,
    totalViews: 45600,
  ),
  achievements: [
    Achievement(
      id: '1',
      title: '100 Workouts',
      description: 'Completed 100 workouts',
      iconUrl: '🏆',
      unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
      isUnlocked: true,
    ),
    Achievement(
      id: '2',
      title: 'Early Bird',
      description: '30 morning workouts',
      iconUrl: '🌅',
      unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
      isUnlocked: true,
    ),
    Achievement(
      id: '3',
      title: 'Consistency King',
      description: '7 day workout streak',
      iconUrl: '🔥',
      unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
      isUnlocked: true,
    ),
  ],
  posts: [
    Post(
      id: '1',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=300&h=300&fit=crop',
      category: 'Gym',
      title: 'Chest Day Pump',
      likes: 124,
      views: 890,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['chest', 'strength', 'motivation', 'gains'],
    ),
    Post(
      id: '2',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop',
      category: 'Gym',
      title: 'Deadlift PR',
      likes: 256,
      views: 1200,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['deadlift', 'pr', 'strength', 'motivation', 'gains'],
    ),
    Post(
      id: '3',
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=300&h=300&fit=crop',
      category: 'Gym',
      title: 'Leg Day Beast Mode',
      likes: 189,
      views: 756,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
       tags: ['legs', 'squats', 'beast', 'pump'],
    ),
    Post(
      id: '4',
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=300&h=300&fit=crop',
      category: 'Gym',
      title: 'Back and Biceps',
      likes: 167,
      views: 623,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      tags: ['back', 'biceps', 'pull', 'muscle'],
    ),
    Post(
      id: '5',
      imageUrl: 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=300&h=300&fit=crop',
      category: 'Gym',
      title: 'Shoulder Shred',
      likes: 203,
      views: 845,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['shoulders', 'shred', 'definition'],
    ),
    Post(
      id: '6',
      imageUrl: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=300&h=300&fit=crop',
      category: 'Sports',
      title: 'Soccer Training',
      likes: 145,
      views: 567,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      tags: ['soccer', 'training', 'skills', 'football'],
    ),
    Post(
      id: '7',
      imageUrl: 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=300&h=300&fit=crop',
      category: 'Sports',
      title: 'Tennis Practice',
      likes: 98,
      views: 456,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['tennis', 'practice', 'skills', 'football'],
    ),
    Post(
      id: '8',
      imageUrl: 'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=300&h=300&fit=crop',
      category: 'Sports',
      title: 'Football Skills',
      likes: 156,
      views: 678,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      tags: ['football', 'skills', 'practice', 'football'],
    ),
    Post(
      id: '9',
      imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=300&h=300&fit=crop',
      category: 'Sports',
      title: 'Basketball Drills',
      likes: 134,
      views: 589,
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      tags: ['basketball', 'skills', 'practice', 'basketball'],
    ),
    Post(
      id: '10',
      imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=300&h=300&fit=crop',
      category: 'Adventure',
      title: 'Mountain Hiking',
      likes: 267,
      views: 1123,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      tags: ['hiking', 'mountain', 'adventure', 'hiking'],
    ),
    Post(
      id: '11',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop',
      category: 'Adventure',
      title: 'Peak Adventure',
      likes: 234,
      views: 987,
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
      tags: ['peak', 'adventure', 'hiking'],
    ),
    Post(
      id: '12',
      imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300&h=300&fit=crop',
      category: 'Adventure',
      title: 'Kayaking Fun',
      likes: 178,
      views: 734,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      tags: ['kayaking', 'fun', 'adventure'],
    ),
  ],
);
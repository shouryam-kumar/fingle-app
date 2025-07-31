class Post {
  final String id;
  final String imageUrl;
  final String category;
  final String title;
  final String description;
  final int likes;
  final int views;
  final int comments;
  final int shares;
  final DateTime createdAt;
  final List<String> tags;

  Post({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.description,
    this.likes = 0,
    this.views = 0,
    this.comments = 0,
    this.shares = 0,
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
  final String username;
  final String name; // This is full_name from backend
  final int age;
  final String bio;
  final String profilePic;
  final String coverImage;
  final List<Post> posts;
  final UserStats stats;
  final List<Achievement> achievements;
  final bool isVerified;
  final bool isFollowing;
  final bool openToMingle;
  final DateTime joinedAt;
  final List<String> interests;
  final int followers;
  final int following;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.age,
    required this.bio,
    required this.profilePic,
    required this.coverImage,
    required this.posts,
    required this.stats,
    required this.achievements,
    this.isVerified = false,
    this.isFollowing = false,
    this.openToMingle = false,
    required this.joinedAt,
    required this.interests,
    required this.followers,
    required this.following,
  });

  // Factory constructor for Supabase JSON response
  factory User.fromSupabaseJson(Map<String, dynamic> json) {
    // Parse the main user data
    final userData = json['user'] ?? json;
    
    // Parse stats
    UserStats? stats;
    if (json['stats'] != null) {
      stats = UserStats(
        totalPosts: json['stats']['posts_count'] ?? 0,
        followers: json['stats']['followers_count'] ?? 0,
        following: json['stats']['following_count'] ?? 0,
        totalViews: json['stats']['total_views'] ?? 0,
      );
    } else {
      stats = UserStats(
        totalPosts: 0,
        followers: userData['followersCount'] ?? 0,
        following: userData['followingCount'] ?? 0,
        totalViews: 0,
      );
    }
    
    // Parse achievements
    List<Achievement> achievements = [];
    if (json['achievements'] != null) {
      achievements = (json['achievements'] as List)
          .map((a) => Achievement(
                id: a['id'],
                title: a['title'],
                description: a['description'],
                iconUrl: a['icon_url'] ?? '🏆',
                unlockedAt: DateTime.parse(a['unlocked_at']),
                isUnlocked: true,
              ))
          .toList();
    }
    
    // Parse profile posts
    List<Post> posts = [];
    if (json['profilePosts'] != null) {
      posts = (json['profilePosts'] as List)
          .map((p) => Post(
                id: p['id'],
                imageUrl: p['imageUrl'] ?? '',
                category: p['category'] ?? 'General',
                title: p['title'] ?? '',
                description: p['content'] ?? '',
                likes: p['likes'] ?? 0,
                views: p['views'] ?? 0,
                comments: p['comments'] ?? 0,
                shares: p['shares'] ?? 0,
                createdAt: DateTime.parse(p['createdAt']),
                tags: List<String>.from(p['tags'] ?? []),
              ))
          .toList();
    }
    
    return User(
      id: userData['id'],
      username: userData['username'],
      name: userData['fullName'] ?? userData['full_name'] ?? '',
      age: userData['age'] ?? 0,
      bio: userData['bio'] ?? '',
      profilePic: userData['avatarUrl'] ?? userData['avatar_url'] ?? '',
      coverImage: userData['coverImage'] ?? userData['cover_image'] ?? '',
      posts: posts,
      stats: stats,
      achievements: achievements,
      isVerified: userData['isVerified'] ?? userData['is_verified'] ?? false,
      isFollowing: userData['isFollowing'] ?? false,
      openToMingle: userData['openToMingle'] ?? userData['open_to_mingle'] ?? false,
      joinedAt: DateTime.parse(userData['createdAt'] ?? userData['created_at']),
      interests: List<String>.from(userData['interests'] ?? []),
      followers: userData['followersCount'] ?? stats.followers,
      following: userData['followingCount'] ?? stats.following,
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? name,
    int? age,
    String? bio,
    String? profilePic,
    String? coverImage,
    List<Post>? posts,
    UserStats? stats,
    List<Achievement>? achievements,
    bool? isVerified,
    bool? isFollowing,
    bool? openToMingle,
    DateTime? joinedAt,
    List<String>? interests,
    int? followers,
    int? following,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      profilePic: profilePic ?? this.profilePic,
      coverImage: coverImage ?? this.coverImage,
      posts: posts ?? this.posts,
      stats: stats ?? this.stats,
      achievements: achievements ?? this.achievements,
      isVerified: isVerified ?? this.isVerified,
      isFollowing: isFollowing ?? this.isFollowing,
      openToMingle: openToMingle ?? this.openToMingle,
      joinedAt: joinedAt ?? this.joinedAt,
      interests: interests ?? this.interests,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}

// Sample data for testing
final User sampleUser = User(
  id: '1',
  username: 'alexjohnson',
  name: 'Alex Johnson',
  age: 28,
  bio:
      'Fitness junkie | Love hiking | Looking for someone to spot me 💪🏽\nTransforming lives through fitness 🔥',
  profilePic:
      'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=300&h=300&fit=crop&crop=face',
  coverImage:
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
  isVerified: true,
  isFollowing: false,
  openToMingle: true,
  joinedAt: DateTime(2023, 6, 15),
  interests: ['Strength Training', 'Cardio', 'Yoga', 'Nutrition', 'HIIT'],
  followers: 12500,
  following: 890,
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
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=300&h=300&fit=crop',
      category: 'Gym',
      title: 'Chest day here it is',
      description: 'Intense chest workout with heavy weights. Feeling pumped!',
      likes: 124,
      views: 890,
      comments: 23,
      shares: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['chest', 'strength', 'motivation', 'gains'],
    ),
    Post(
      id: '2',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop',
      category: 'Gym',
      title: 'Deadlift PR',
      description: 'Hit a new personal record on deadlifts today! 💪',
      likes: 256,
      views: 1200,
      comments: 34,
      shares: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['deadlift', 'pr', 'strength', 'motivation', 'gains'],
    ),
    Post(
      id: '3',
      imageUrl:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=300&h=300&fit=crop',
      category: 'Gym',
      title: 'Leg Day Beast Mode',
      description: 'Squats and lunges had me feeling like a beast! 🦵',
      likes: 189,
      views: 756,
      comments: 19,
      shares: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      tags: ['legs', 'squats', 'beast', 'pump'],
    ),
    Post(
      id: '4',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=300&h=300&fit=crop',
      category: 'Gym',
      title: 'Back and Biceps',
      description: 'Pull day complete! Back and biceps are on fire 🔥',
      likes: 167,
      views: 623,
      comments: 12,
      shares: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      tags: ['back', 'biceps', 'pull', 'muscle'],
    ),
    Post(
      id: '5',
      imageUrl:
          'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=300&h=300&fit=crop',
      category: 'Gym',
      title: 'Shoulder Shred',
      description: 'Shoulder definition is getting better every day! 💪',
      likes: 203,
      views: 845,
      comments: 15,
      shares: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['shoulders', 'shred', 'definition'],
    ),
    Post(
      id: '6',
      imageUrl:
          'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=300&h=300&fit=crop',
      category: 'Sports',
      title: 'Soccer Training',
      description: 'Working on my footwork and ball control ⚽',
      likes: 145,
      views: 567,
      comments: 8,
      shares: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      tags: ['soccer', 'training', 'skills', 'football'],
    ),
    Post(
      id: '7',
      imageUrl:
          'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=300&h=300&fit=crop',
      category: 'Sports',
      title: 'Tennis Practice',
      description: 'Perfecting my serve and backhand 🎾',
      likes: 98,
      views: 456,
      comments: 6,
      shares: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['tennis', 'practice', 'skills', 'racquet'],
    ),
    Post(
      id: '8',
      imageUrl:
          'https://images.unsplash.com/photo-1560272564-c83b66b1ad12?w=300&h=300&fit=crop',
      category: 'Sports',
      title: 'Football Skills',
      description: 'Touchdown practice and route running drills 🏈',
      likes: 156,
      views: 678,
      comments: 11,
      shares: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      tags: ['football', 'skills', 'practice', 'touchdown'],
    ),
    Post(
      id: '9',
      imageUrl:
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=300&h=300&fit=crop',
      category: 'Sports',
      title: 'Basketball Drills',
      description: 'Shooting hoops and working on my crossover 🏀',
      likes: 134,
      views: 589,
      comments: 9,
      shares: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      tags: ['basketball', 'skills', 'practice', 'hoops'],
    ),
    Post(
      id: '10',
      imageUrl:
          'https://images.unsplash.com/photo-1551632811-561732d1e306?w=300&h=300&fit=crop',
      category: 'Adventure',
      title: 'Mountain Hiking',
      description: 'Reached the summit after 3 hours of hiking! 🏔️',
      likes: 267,
      views: 1123,
      comments: 28,
      shares: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      tags: ['hiking', 'mountain', 'adventure', 'summit'],
    ),
    Post(
      id: '11',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop',
      category: 'Adventure',
      title: 'Peak Adventure',
      description: 'Another mountain conquered! The view was breathtaking 🌅',
      likes: 234,
      views: 987,
      comments: 21,
      shares: 7,
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
      tags: ['peak', 'adventure', 'hiking'],
    ),
    Post(
      id: '12',
      imageUrl:
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300&h=300&fit=crop',
      category: 'Adventure',
      title: 'Kayaking Fun',
      description:
          'Peaceful morning on the water. Nature therapy at its best! 🚣',
      likes: 178,
      views: 734,
      comments: 14,
      shares: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      tags: ['kayaking', 'fun', 'adventure'],
    ),
  ],
);

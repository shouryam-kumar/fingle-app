import '../models/user_model.dart';

class VideoPost {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final User creator;
  final String title;
  final String description;
  final List<String> tags;
  final int duration; // in seconds
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final DateTime createdAt;
  final bool isLiked;
  final bool isFollowing;

  VideoPost({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.creator,
    required this.title,
    required this.description,
    required this.tags,
    required this.duration,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    required this.createdAt,
    this.isLiked = false,
    this.isFollowing = false,
  });

  VideoPost copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    User? creator,
    String? title,
    String? description,
    List<String>? tags,
    int? duration,
    int? likes,
    int? comments,
    int? shares,
    int? views,
    DateTime? createdAt,
    bool? isLiked,
    bool? isFollowing,
  }) {
    return VideoPost(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      creator: creator ?? this.creator,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      duration: duration ?? this.duration,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}

// Mock lifestyle video data with WORKING video URLs
final List<VideoPost> mockLifestyleVideos = [
  VideoPost(
    id: '1',
    // Using a known working video URL from Big Buck Bunny
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    thumbnailUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=600&fit=crop&auto=format&q=75',
    creator: User(
      id: 'alex_lifestyle',
      name: 'Alex Johnson',
      age: 28,
      bio: 'Living life to the fullest 🌟 Fitness | Travel | Adventure',
      profilePic: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=150&h=150&fit=crop&crop=face&auto=format&q=75',
      coverImage: '',
      isVerified: true,
      joinedAt: DateTime.now().subtract(const Duration(days: 365)),
      interests: ['Fitness', 'Travel', 'Adventure'],
      posts: [],
      stats: UserStats(totalPosts: 45, followers: 15000, following: 200, totalViews: 500000),
      achievements: [],
    ),
    title: 'Morning workout energy! 💪🔥',
    description: 'Starting the day right with some quick exercises. Who else is working out this morning?',
    tags: ['morning', 'workout', 'fitness', 'energy', 'motivation'],
    duration: 42,
    likes: 1247,
    comments: 89,
    shares: 45,
    views: 12450,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  
  VideoPost(
    id: '2',
    // Another working sample video
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    thumbnailUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=600&fit=crop&auto=format&q=75',
    creator: User(
      id: 'sarah_adventures',
      name: 'Sarah Explorer',
      age: 25,
      bio: 'Adventure seeker ✈️ Sharing my journey around the world',
      profilePic: 'https://images.unsplash.com/photo-1494790108755-2616b612b77c?w=150&h=150&fit=crop&crop=face&auto=format&q=75',
      coverImage: '',
      isVerified: false,
      joinedAt: DateTime.now().subtract(const Duration(days: 500)),
      interests: ['Travel', 'Photography', 'Hiking'],
      posts: [],
      stats: UserStats(totalPosts: 67, followers: 8500, following: 150, totalViews: 200000),
      achievements: [],
    ),
    title: 'Hiking to this amazing viewpoint! 🏔️',
    description: 'The climb was tough but the view was totally worth it! Nature therapy at its finest 🌿',
    tags: ['hiking', 'nature', 'mountains', 'adventure', 'travel'],
    duration: 38,
    likes: 2156,
    comments: 134,
    shares: 78,
    views: 18900,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),

  VideoPost(
    id: '3',
    // Sintel sample video
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    thumbnailUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=600&fit=crop&auto=format&q=75',
    creator: User(
      id: 'mike_rider',
      name: 'Mike Rider',
      age: 30,
      bio: 'Two wheels, endless roads 🏍️ Motorcycle enthusiast',
      profilePic: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face&auto=format&q=75',
      coverImage: '',
      isVerified: false,
      joinedAt: DateTime.now().subtract(const Duration(days: 200)),
      interests: ['Motorcycles', 'Travel', 'Adventure'],
      posts: [],
      stats: UserStats(totalPosts: 89, followers: 12300, following: 300, totalViews: 350000),
      achievements: [],
    ),
    title: 'Perfect riding weather today! 🏍️☀️',
    description: 'Nothing beats the feeling of freedom on the open road. Weekend vibes! 🌈',
    tags: ['motorcycle', 'riding', 'freedom', 'weekend', 'adventure'],
    duration: 29,
    likes: 856,
    comments: 67,
    shares: 23,
    views: 7890,
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),

  VideoPost(
    id: '4',
    // ForBiggerBlazes sample video
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    thumbnailUrl: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&h=600&fit=crop&auto=format&q=75',
    creator: User(
      id: 'lisa_foodie',
      name: 'Lisa Healthy',
      age: 27,
      bio: 'Healthy food lover 🥗 Sharing nutritious & delicious recipes',
      profilePic: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face&auto=format&q=75',
      coverImage: '',
      isVerified: true,
      joinedAt: DateTime.now().subtract(const Duration(days: 300)),
      interests: ['Cooking', 'Nutrition', 'Health'],
      posts: [],
      stats: UserStats(totalPosts: 123, followers: 25600, following: 180, totalViews: 600000),
      achievements: [],
    ),
    title: 'Quick healthy breakfast bowl 🥗✨',
    description: 'Fuel your body right! This takes only 5 minutes to make and tastes amazing 😋',
    tags: ['healthy', 'breakfast', 'nutrition', 'quick', 'delicious'],
    duration: 33,
    likes: 1834,
    comments: 156,
    shares: 92,
    views: 15670,
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
  ),

  VideoPost(
    id: '5',
    // SubaruOutbackOnStreetAndDirt sample video
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    thumbnailUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&h=600&fit=crop&auto=format&q=75',
    creator: User(
      id: 'tom_explorer',
      name: 'Tom Adventures',
      age: 32,
      bio: 'Exploring the world one adventure at a time 🌍',
      profilePic: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face&auto=format&q=75',
      coverImage: '',
      isVerified: false,
      joinedAt: DateTime.now().subtract(const Duration(days: 150)),
      interests: ['Travel', 'Photography', 'Kayaking'],
      posts: [],
      stats: UserStats(totalPosts: 34, followers: 5600, following: 220, totalViews: 120000),
      achievements: [],
    ),
    title: 'Off-road adventure time! 🚗💨',
    description: 'Taking the scenic route through some amazing terrain. Adventure calls! 🏔️',
    tags: ['offroad', 'adventure', 'exploring', 'nature', 'freedom'],
    duration: 47,
    likes: 934,
    comments: 78,
    shares: 34,
    views: 9340,
    createdAt: DateTime.now().subtract(const Duration(hours: 18)),
  ),

  VideoPost(
    id: '6',
    // TearsOfSteel sample video
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    thumbnailUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=600&fit=crop&auto=format&q=75',
    creator: User(
      id: 'jenny_yoga',
      name: 'Jenny Zen',
      age: 26,
      bio: 'Yoga instructor 🧘‍♀️ Finding peace in movement',
      profilePic: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face&auto=format&q=75',
      coverImage: '',
      isVerified: true,
      joinedAt: DateTime.now().subtract(const Duration(days: 400)),
      interests: ['Yoga', 'Meditation', 'Wellness'],
      posts: [],
      stats: UserStats(totalPosts: 78, followers: 18900, following: 120, totalViews: 450000),
      achievements: [],
    ),
    title: 'Sunrise yoga on the beach 🧘‍♀️🌅',
    description: 'Starting the day with gratitude and movement. The sound of waves makes it even more peaceful 🌊',
    tags: ['yoga', 'sunrise', 'beach', 'peaceful', 'meditation'],
    duration: 55,
    likes: 2245,
    comments: 198,
    shares: 156,
    views: 22450,
    createdAt: DateTime.now().subtract(const Duration(hours: 24)),
  ),
];
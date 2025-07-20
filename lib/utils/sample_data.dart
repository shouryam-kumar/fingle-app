import 'package:flutter/material.dart';
import '../models/home_models.dart';
import '../models/reaction_models.dart';
import '../core/theme/app_colors.dart';

// Sample Trending Topics
final List<TrendingTopic> sampleTrendingTopics = [
  TrendingTopic(
    id: 1,
    name: 'Fitness',
    emoji: '💪',
    gradient: AppColors.purpleGradient,
    postCount: 12400,
  ),
  TrendingTopic(
    id: 2,
    name: 'Yoga',
    emoji: '🧘‍♀️',
    gradient: AppColors.mintGradient,
    postCount: 8900,
  ),
  TrendingTopic(
    id: 3,
    name: 'Running',
    emoji: '🏃‍♂️',
    gradient: AppColors.sunsetGradient,
    postCount: 15600,
  ),
  TrendingTopic(
    id: 4,
    name: 'Nutrition',
    emoji: '🥗',
    gradient: AppColors.oceanGradient,
    postCount: 6700,
  ),
  TrendingTopic(
    id: 5,
    name: 'HIIT',
    emoji: '🔥',
    gradient: AppColors.purpleGradient,
    postCount: 4200,
  ),
  TrendingTopic(
    id: 6,
    name: 'Mindful',
    emoji: '🌸',
    gradient: AppColors.mintGradient,
    postCount: 3100,
  ),
];

// Sample Stories
final List<Story> sampleStories = [
  Story(
    id: 0,
    name: 'Your Story',
    avatar:
        'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=300&h=300&fit=crop&crop=face',
    viewed: false,
    isOwn: true,
    timestamp: DateTime.now(),
  ),
  Story(
    id: 1,
    name: 'Emma',
    avatar:
        'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=300&h=300&fit=crop&crop=face',
    viewed: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  Story(
    id: 2,
    name: 'James',
    avatar:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
    viewed: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  Story(
    id: 3,
    name: 'Sofia',
    avatar:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop&crop=face',
    viewed: false,
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  Story(
    id: 4,
    name: 'Marcus',
    avatar:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=300&fit=crop&crop=face',
    viewed: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  Story(
    id: 5,
    name: 'Lily',
    avatar:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300&h=300&fit=crop&crop=face',
    viewed: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
  ),
  Story(
    id: 6,
    name: 'David',
    avatar:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=300&fit=crop&crop=face',
    viewed: true,
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
  ),
];

// Sample Feed Posts - Diverse Content Types
final List<FeedPost> sampleFeedPosts = [
  // Canvas Post 1 - Motivational Quote
  FeedPost(
    id: 1,
    userId: 'user_1',
    userName: 'Alex Rivera',
    userAvatar:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: false,
    content: '',
    timeAgo: '1h ago',
    category: 'Motivation',
    likes: 89,
    comments: 12,
    shares: 24,
    recommendations: 156,
    postType: PostType.canvas,
    canvasData: CanvasPost(
      text: 'Your only limit is\nyour mind.\n\nPush harder today! 💪',
      backgroundColor: '#8B7AB8',
      textColor: Colors.white,
      fontFamily: 'Poppins',
    ),
    tags: ['motivation', 'mindset', 'fitness'],
    reactionSummary: ReactionSummary(
      counts: {
        ReactionType.fire: 42,
        ReactionType.strong: 31,
        ReactionType.like: 16,
      },
      reactions: {},
      userReaction: ReactionType.fire,
      totalCount: 89,
    ),
  ),

  // Video Post 1 - Regular size
  FeedPost(
    id: 2,
    userId: 'user_2',
    userName: 'Emma Wilson',
    userAvatar:
        'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: true,
    content:
        'Morning yoga flow to start the day right! 🧘‍♀️ This 15-minute sequence helps me center myself.',
    timeAgo: '2h ago',
    category: 'Yoga',
    likes: 234,
    comments: 45,
    shares: 18,
    recommendations: 298,
    isRecommended: true,
    postType: PostType.video,
    mediaItems: [
      MediaItem(
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        type: MediaType.video,
        aspectRatio: '16:9',
        thumbnail:
            'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=300&fit=crop',
        duration: 900, // 15 minutes
      ),
    ],
    tags: ['yoga', 'morning', 'mindfulness', 'flow'],
    reactionSummary: ReactionSummary(
      counts: {
        ReactionType.love: 156,
        ReactionType.like: 62,
        ReactionType.wow: 16,
      },
      reactions: {},
      userReaction: ReactionType.love,
      totalCount: 234,
    ),
  ),

  // Photo Carousel Post
  FeedPost(
    id: 3,
    userId: 'user_3',
    userName: 'Marcus Thompson',
    userAvatar:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=300&fit=crop&crop=face',
    userVerified: false,
    userOpenToMingle: true,
    content:
        'Chest day progression over 6 months! Consistency is everything 💪 Swipe to see the journey.',
    timeAgo: '3h ago',
    category: 'Strength',
    likes: 456,
    comments: 67,
    shares: 32,
    recommendations: 189,
    postType: PostType.carousel,
    mediaItems: [
      MediaItem(
          url:
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
          type: MediaType.image,
          aspectRatio: '1:1'),
      MediaItem(
          url:
              'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&h=400&fit=crop',
          type: MediaType.image,
          aspectRatio: '1:1'),
      MediaItem(
          url:
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=400&fit=crop',
          type: MediaType.image,
          aspectRatio: '1:1'),
    ],
    tags: ['transformation', 'chest', 'strength', 'progress'],
    reactionSummary: ReactionSummary(
      counts: {
        ReactionType.strong: 245,
        ReactionType.fire: 134,
        ReactionType.like: 77,
      },
      reactions: {},
      userReaction: null, // User hasn't reacted yet
      totalCount: 456,
    ),
  ),

  // Canvas Post 2 - Recipe Card
  FeedPost(
    id: 4,
    userId: 'user_4',
    userName: 'Sofia Chen',
    userAvatar:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: true,
    content: '',
    timeAgo: '4h ago',
    category: 'Nutrition',
    likes: 167,
    comments: 28,
    shares: 45,
    recommendations: 234,
    postType: PostType.canvas,
    canvasData: CanvasPost(
      text:
          'Post-Workout Smoothie 🥤\n\n• 1 banana\n• 1 cup spinach\n• 1 scoop protein powder\n• 1 tbsp almond butter\n• 1 cup almond milk\n\nBlend & enjoy!',
      backgroundColor: '#87B79F',
      textColor: Colors.white,
    ),
    tags: ['nutrition', 'smoothie', 'recipe', 'protein'],
    reactionSummary: ReactionSummary(
      counts: {
        ReactionType.like: 89,
        ReactionType.love: 54,
        ReactionType.laugh: 24,
      },
      reactions: {},
      userReaction: ReactionType.like,
      totalCount: 167,
    ),
  ),

  // Video Reel - Vertical format
  FeedPost(
    id: 5,
    userId: 'user_5',
    userName: 'Jordan Kim',
    userAvatar:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=300&fit=crop&crop=face',
    userVerified: false,
    userOpenToMingle: false,
    content:
        'Quick HIIT session that\'ll get your heart pumping! 🔥 No equipment needed.',
    timeAgo: '5h ago',
    category: 'HIIT',
    likes: 678,
    comments: 89,
    shares: 156,
    recommendations: 445,
    postType: PostType.videoReel,
    mediaItems: [
      MediaItem(
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        type: MediaType.video,
        aspectRatio: '9:16',
        thumbnail:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=533&fit=crop',
        duration: 60,
      ),
    ],
    tags: ['hiit', 'workout', 'cardio', 'noequipment'],
    reactionSummary: ReactionSummary(
      counts: {
        ReactionType.fire: 312,
        ReactionType.strong: 198,
        ReactionType.wow: 98,
        ReactionType.like: 70,
      },
      reactions: {},
      userReaction: ReactionType.fire,
      totalCount: 678,
    ),
  ),

  // Single Photo Post
  FeedPost(
    id: 6,
    userId: 'user_6',
    userName: 'Lily Park',
    userAvatar:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: false,
    content:
        'Recovery day hiking through nature 🌲 Sometimes the best workout is just walking and breathing fresh air.',
    timeAgo: '6h ago',
    category: 'Recovery',
    likes: 289,
    comments: 34,
    shares: 12,
    recommendations: 178,
    postType: PostType.photo,
    imageUrl:
        'https://images.unsplash.com/photo-1551632811-561732d1e306?w=400&h=300&fit=crop',
    tags: ['recovery', 'hiking', 'nature', 'wellness'],
  ),

  // Canvas Post 3 - Workout Tip
  FeedPost(
    id: 7,
    userId: 'user_7',
    userName: 'David Rodriguez',
    userAvatar:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=300&fit=crop&crop=face',
    userVerified: false,
    userOpenToMingle: true,
    content: '',
    timeAgo: '8h ago',
    category: 'Tips',
    likes: 145,
    comments: 23,
    shares: 67,
    recommendations: 198,
    postType: PostType.canvas,
    canvasData: CanvasPost(
      text:
          'PRO TIP 💡\n\nForm > Weight\n\nPerfect your technique\nbefore adding more plates.\n\nQuality reps = Better gains',
      backgroundColor: '#D4A5A5',
      textColor: Colors.white,
    ),
    tags: ['tips', 'form', 'strength', 'technique'],
  ),

  // Video Post 2 - Workout demo
  FeedPost(
    id: 8,
    userId: 'user_8',
    userName: 'Ashley Brown',
    userAvatar:
        'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: false,
    content:
        'Perfect deadlift form breakdown 📹 Save this for reference! Proper hip hinge is everything.',
    timeAgo: '10h ago',
    category: 'Technique',
    likes: 567,
    comments: 78,
    shares: 234,
    recommendations: 389,
    postType: PostType.video,
    mediaItems: [
      MediaItem(
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        type: MediaType.video,
        aspectRatio: '16:9',
        thumbnail:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
        duration: 120,
      ),
    ],
    tags: ['deadlift', 'form', 'technique', 'tutorial'],
  ),

  // Photo Carousel - Meal prep
  FeedPost(
    id: 9,
    userId: 'user_4',
    userName: 'Sofia Chen',
    userAvatar:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: true,
    content:
        'Sunday meal prep complete! 🥗 This week: chicken bowls, overnight oats, and energy balls.',
    timeAgo: '12h ago',
    category: 'Nutrition',
    likes: 234,
    comments: 45,
    shares: 89,
    recommendations: 156,
    postType: PostType.carousel,
    mediaItems: [
      MediaItem(
          url:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=400&fit=crop',
          type: MediaType.image,
          aspectRatio: '1:1'),
      MediaItem(
          url:
              'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=400&fit=crop',
          type: MediaType.image,
          aspectRatio: '1:1'),
      MediaItem(
          url:
              'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=400&h=400&fit=crop',
          type: MediaType.image,
          aspectRatio: '1:1'),
    ],
    tags: ['mealprep', 'nutrition', 'healthy', 'planning'],
  ),

  // Single Photo - Yoga pose
  FeedPost(
    id: 10,
    userId: 'user_9',
    userName: 'Maya Patel',
    userAvatar:
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&h=300&fit=crop&crop=face',
    userVerified: false,
    userOpenToMingle: false,
    content:
        'Finding balance in warrior III 🧘‍♀️ Took months to hold this for 30 seconds!',
    timeAgo: '14h ago',
    category: 'Yoga',
    likes: 178,
    comments: 29,
    shares: 15,
    recommendations: 89,
    postType: PostType.photo,
    imageUrl:
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
    tags: ['yoga', 'balance', 'warrior3', 'practice'],
  ),

  // Video Reel - Quick workout
  FeedPost(
    id: 11,
    userId: 'user_10',
    userName: 'Ryan Foster',
    userAvatar:
        'https://images.unsplash.com/photo-1559548331-f72f5417dca0?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: true,
    content: '30-second abs burner! 🔥 Try this between meetings.',
    timeAgo: '16h ago',
    category: 'Abs',
    likes: 445,
    comments: 67,
    shares: 123,
    recommendations: 278,
    postType: PostType.videoReel,
    mediaItems: [
      MediaItem(
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        type: MediaType.video,
        aspectRatio: '9:16',
        thumbnail:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=533&fit=crop',
        duration: 30,
      ),
    ],
    tags: ['abs', 'quick', 'workout', 'office'],
  ),

  // Canvas Post 4 - Weekly Challenge
  FeedPost(
    id: 12,
    userId: 'user_11',
    userName: 'Coach Jamie',
    userAvatar:
        'https://images.unsplash.com/photo-1548142813-c348350df52b?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: false,
    content: '',
    timeAgo: '18h ago',
    category: 'Challenge',
    likes: 567,
    comments: 89,
    shares: 234,
    recommendations: 445,
    postType: PostType.canvas,
    canvasData: CanvasPost(
      text:
          'WEEK 3 CHALLENGE 🏆\n\n100 Squats Daily\nFor 7 Days\n\nWho\'s in?\nComment below! 👇',
      backgroundColor: '#F5C99B',
      textColor: const Color(0xFF2C3E50),
    ),
    tags: ['challenge', 'squats', 'community', 'fitness'],
  ),

  // Photo - Running achievement
  FeedPost(
    id: 13,
    userId: 'user_12',
    userName: 'Sarah Johnson',
    userAvatar:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&h=300&fit=crop&crop=face',
    userVerified: false,
    userOpenToMingle: true,
    content:
        'First 10K completed! 🏃‍♀️ 6 months ago I couldn\'t run 1K. Never give up on your goals!',
    timeAgo: '20h ago',
    category: 'Running',
    likes: 389,
    comments: 78,
    shares: 45,
    recommendations: 234,
    postType: PostType.photo,
    imageUrl:
        'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400&h=300&fit=crop',
    tags: ['10k', 'running', 'achievement', 'progress'],
  ),

  // Video - Stretching routine
  FeedPost(
    id: 14,
    userId: 'user_13',
    userName: 'Dr. Lisa Wong',
    userAvatar:
        'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: false,
    content:
        '10-minute evening stretch routine for better sleep 🌙 Do this before bed for optimal recovery.',
    timeAgo: '22h ago',
    category: 'Recovery',
    likes: 445,
    comments: 56,
    shares: 167,
    recommendations: 289,
    postType: PostType.video,
    mediaItems: [
      MediaItem(
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        type: MediaType.video,
        aspectRatio: '16:9',
        thumbnail:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
        duration: 600,
      ),
    ],
    tags: ['stretching', 'sleep', 'recovery', 'routine'],
  ),

  // Photo Carousel - Gym equipment guide
  FeedPost(
    id: 15,
    userId: 'user_14',
    userName: 'Mike Chen',
    userAvatar:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
    userVerified: false,
    userOpenToMingle: false,
    content:
        'Beginner\'s guide to gym equipment 💪 Swipe through to see proper setup for each machine.',
    timeAgo: '1d ago',
    category: 'Education',
    likes: 234,
    comments: 45,
    shares: 89,
    recommendations: 167,
    postType: PostType.carousel,
    mediaItems: [
      MediaItem(
          url:
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=400&fit=crop',
          type: MediaType.image,
          aspectRatio: '1:1'),
      MediaItem(
          url:
              'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&h=400&fit=crop',
          type: MediaType.image,
          aspectRatio: '1:1'),
      MediaItem(
          url:
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
          type: MediaType.image,
          aspectRatio: '1:1'),
      MediaItem(
          url:
              'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=400&h=400&fit=crop',
          type: MediaType.image,
          aspectRatio: '1:1'),
    ],
    tags: ['beginner', 'equipment', 'guide', 'gym'],
  ),

  // Canvas Post 5 - Hydration reminder
  FeedPost(
    id: 16,
    userId: 'user_15',
    userName: 'Wellness Coach',
    userAvatar:
        'https://images.unsplash.com/photo-1494790108755-2616b612b5bc?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: false,
    content: '',
    timeAgo: '1d ago',
    category: 'Wellness',
    likes: 123,
    comments: 34,
    shares: 56,
    recommendations: 89,
    postType: PostType.canvas,
    canvasData: CanvasPost(
      text:
          'HYDRATION CHECK 💧\n\nDrink water every hour\nAim for 8 glasses daily\n\nYour body will thank you!\n\n💦💦💦💦💦💦💦💦',
      backgroundColor: '#7FC8A9',
      textColor: Colors.white,
    ),
    tags: ['hydration', 'water', 'health', 'wellness'],
  ),

  // Video Reel - Dance workout
  FeedPost(
    id: 17,
    userId: 'user_16',
    userName: 'Dance Fit Ana',
    userAvatar:
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=300&h=300&fit=crop&crop=face',
    userVerified: true,
    userOpenToMingle: true,
    content: 'Cardio dance party! 💃 Who says workouts can\'t be fun?',
    timeAgo: '1d ago',
    category: 'Cardio',
    likes: 678,
    comments: 123,
    shares: 234,
    recommendations: 456,
    postType: PostType.videoReel,
    mediaItems: [
      MediaItem(
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
        type: MediaType.video,
        aspectRatio: '9:16',
        thumbnail:
            'https://images.unsplash.com/photo-1547153760-18fc86324498?w=300&h=533&fit=crop',
        duration: 45,
      ),
    ],
    tags: ['dance', 'cardio', 'fun', 'party'],
  ),
];

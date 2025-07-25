import '../models/search_models.dart';
import '../models/user_model.dart';
import '../models/home_models.dart';
import '../models/video_models.dart';
import '../models/reaction_models.dart';

class MockSearchData {
  // Sample users with enhanced data for search
  static final List<User> _sampleUsers = [
    User(
      id: '2',
      name: 'Maya Chen',
      age: 25,
      bio:
          'Yoga instructor 🧘‍♀️ | Mindfulness coach | Open to meaningful connections',
      profilePic:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&h=300&fit=crop&crop=face',
      coverImage:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop',
      isVerified: true,
      isFollowing: false,
      openToMingle: true,
      joinedAt: DateTime(2023, 3, 20),
      interests: ['Yoga', 'Meditation', 'Pilates', 'Wellness', 'Nutrition'],
      followers: 8500,
      following: 1200,
      posts: [],
      stats: UserStats(
          totalPosts: 25, followers: 8500, following: 1200, totalViews: 32000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Zen Master',
          description: 'Completed 200 meditation sessions',
          iconUrl: '🧘',
          unlockedAt: DateTime.now().subtract(const Duration(days: 45)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '3',
      name: 'Marcus Rodriguez',
      age: 32,
      bio:
          'CrossFit athlete 🏋️‍♂️ | Personal trainer | Let\'s sweat together!',
      profilePic:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
      coverImage:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
      isVerified: false,
      isFollowing: true,
      openToMingle: false,
      joinedAt: DateTime(2023, 1, 10),
      interests: [
        'CrossFit',
        'Strength Training',
        'HIIT',
        'Powerlifting',
        'Nutrition'
      ],
      followers: 15600,
      following: 650,
      posts: [],
      stats: UserStats(
          totalPosts: 87, followers: 15600, following: 650, totalViews: 89000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Beast Mode',
          description: 'Completed 500 workouts',
          iconUrl: '💪',
          unlockedAt: DateTime.now().subtract(const Duration(days: 20)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '4',
      name: 'Emma Thompson',
      age: 28,
      bio:
          'Marathon runner 🏃‍♀️ | Adventure seeker | Always up for new challenges',
      profilePic:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300&h=300&fit=crop&crop=face',
      coverImage:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop',
      isVerified: true,
      isFollowing: false,
      openToMingle: true,
      joinedAt: DateTime(2023, 5, 8),
      interests: ['Running', 'Marathon', 'Hiking', 'Adventure', 'Cardio'],
      followers: 12300,
      following: 890,
      posts: [],
      stats: UserStats(
          totalPosts: 45, followers: 12300, following: 890, totalViews: 56000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Marathon Finisher',
          description: 'Completed 10 marathons',
          iconUrl: '🏃‍♀️',
          unlockedAt: DateTime.now().subtract(const Duration(days: 12)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '5',
      name: 'David Kim',
      age: 30,
      bio:
          'Rock climbing enthusiast 🧗‍♂️ | Outdoor fitness | Looking for adventure partners',
      profilePic:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=300&fit=crop&crop=face',
      coverImage:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop',
      isVerified: false,
      isFollowing: false,
      openToMingle: true,
      joinedAt: DateTime(2023, 7, 15),
      interests: [
        'Rock Climbing',
        'Bouldering',
        'Hiking',
        'Adventure',
        'Outdoor'
      ],
      followers: 9800,
      following: 1100,
      posts: [],
      stats: UserStats(
          totalPosts: 34, followers: 9800, following: 1100, totalViews: 42000),
      achievements: [],
    ),
    User(
      id: '6',
      name: 'Sarah Johnson',
      age: 26,
      bio: 'Swimming coach 🏊‍♀️ | Former collegiate athlete | Water is my element',
      profilePic: 'https://images.unsplash.com/photo-1494790108755-2616c27a61e1?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=800&h=400&fit=crop',
      isVerified: true,
      isFollowing: false,
      openToMingle: true,
      joinedAt: DateTime(2023, 2, 14),
      interests: ['Swimming', 'Water Sports', 'Triathlon', 'Coaching', 'Technique'],
      followers: 7200,
      following: 890,
      posts: [],
      stats: UserStats(totalPosts: 42, followers: 7200, following: 890, totalViews: 38000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Swim Master',
          description: 'Completed 1000 laps',
          iconUrl: '🏊‍♀️',
          unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '7',
      name: 'Jake Martinez',
      age: 29,
      bio: 'Cyclist & bike mechanic 🚴‍♂️ | Road warrior | Always ready for long rides',
      profilePic: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800&h=400&fit=crop',
      isVerified: false,
      isFollowing: true,
      openToMingle: false,
      joinedAt: DateTime(2023, 4, 8),
      interests: ['Cycling', 'Road Biking', 'Mountain Biking', 'Bike Racing', 'Endurance'],
      followers: 11500,
      following: 1300,
      posts: [],
      stats: UserStats(totalPosts: 67, followers: 11500, following: 1300, totalViews: 78000),
      achievements: [],
    ),
    User(
      id: '8',
      name: 'Luna Rodriguez',
      age: 24,
      bio: 'Dance fitness instructor 💃 | Zumba certified | Movement is medicine',
      profilePic: 'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
      isVerified: true,
      isFollowing: false,
      openToMingle: true,
      joinedAt: DateTime(2023, 6, 12),
      interests: ['Dance', 'Zumba', 'Cardio Dance', 'Latin Dance', 'Choreography'],
      followers: 9400,
      following: 750,
      posts: [],
      stats: UserStats(totalPosts: 55, followers: 9400, following: 750, totalViews: 65000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Dance Master',
          description: 'Led 500 dance classes',
          iconUrl: '💃',
          unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '9',
      name: 'Alex Chen',
      age: 31,
      bio: 'Martial arts sensei 🥋 | Karate & Jiu-Jitsu | Discipline through practice',
      profilePic: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1555597673-b21d5c935865?w=800&h=400&fit=crop',
      isVerified: false,
      isFollowing: false,
      openToMingle: false,
      joinedAt: DateTime(2023, 1, 22),
      interests: ['Martial Arts', 'Karate', 'Jiu-Jitsu', 'Self Defense', 'Meditation'],
      followers: 6800,
      following: 450,
      posts: [],
      stats: UserStats(totalPosts: 38, followers: 6800, following: 450, totalViews: 45000),
      achievements: [],
    ),
    User(
      id: '10',
      name: 'Mia Thompson',
      age: 27,
      bio: 'Pilates instructor ✨ | Mind-body connection | Helping you find your center',
      profilePic: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&h=400&fit=crop',
      isVerified: true,
      isFollowing: true,
      openToMingle: true,
      joinedAt: DateTime(2023, 3, 18),
      interests: ['Pilates', 'Core Strength', 'Flexibility', 'Posture', 'Wellness'],
      followers: 8900,
      following: 680,
      posts: [],
      stats: UserStats(totalPosts: 47, followers: 8900, following: 680, totalViews: 52000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Core Champion',
          description: 'Completed 300 core workouts',
          iconUrl: '✨',
          unlockedAt: DateTime.now().subtract(const Duration(days: 22)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '11',
      name: 'Ryan Foster',
      age: 33,
      bio: 'Powerlifter & strength coach 💪 | Raw lifting enthusiast | Heavy is the way',
      profilePic: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&h=400&fit=crop',
      isVerified: false,
      isFollowing: false,
      openToMingle: false,
      joinedAt: DateTime(2023, 5, 3),
      interests: ['Powerlifting', 'Strength Coaching', 'Raw Lifting', 'Competition', 'Form'],
      followers: 13200,
      following: 320,
      posts: [],
      stats: UserStats(totalPosts: 72, followers: 13200, following: 320, totalViews: 95000),
      achievements: [],
    ),
    User(
      id: '12',
      name: 'Sophie Wilson',
      age: 25,
      bio: 'Tennis player & coach 🎾 | Former junior champion | Serve and volley style',
      profilePic: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800&h=400&fit=crop',
      isVerified: true,
      isFollowing: true,
      openToMingle: true,
      joinedAt: DateTime(2023, 7, 9),
      interests: ['Tennis', 'Racquet Sports', 'Coaching', 'Competition', 'Agility'],
      followers: 5600,
      following: 890,
      posts: [],
      stats: UserStats(totalPosts: 29, followers: 5600, following: 890, totalViews: 31000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Ace Master',
          description: 'Hit 100 aces in matches',
          iconUrl: '🎾',
          unlockedAt: DateTime.now().subtract(const Duration(days: 8)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '13',
      name: 'Carlos Mendez',
      age: 30,
      bio: 'Basketball trainer 🏀 | Former college player | Elevating your game',
      profilePic: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&h=400&fit=crop',
      isVerified: false,
      isFollowing: false,
      openToMingle: true,
      joinedAt: DateTime(2023, 8, 15),
      interests: ['Basketball', 'Sports Training', 'Vertical Jump', 'Conditioning', 'Team Sports'],
      followers: 10200,
      following: 1100,
      posts: [],
      stats: UserStats(totalPosts: 61, followers: 10200, following: 1100, totalViews: 73000),
      achievements: [],
    ),
    User(
      id: '14',
      name: 'Isabella Garcia',
      age: 26,
      bio: 'Nutritionist & meal prep expert 🥗 | Plant-based athlete | Food is fuel',
      profilePic: 'https://images.unsplash.com/photo-1494790108755-2616c27a61e1?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&h=400&fit=crop',
      isVerified: true,
      isFollowing: true,
      openToMingle: false,
      joinedAt: DateTime(2023, 4, 25),
      interests: ['Nutrition', 'Meal Prep', 'Plant-Based', 'Sports Nutrition', 'Wellness'],
      followers: 14500,
      following: 950,
      posts: [],
      stats: UserStats(totalPosts: 89, followers: 14500, following: 950, totalViews: 125000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Nutrition Guru',
          description: 'Helped 1000 people with meal plans',
          iconUrl: '🥗',
          unlockedAt: DateTime.now().subtract(const Duration(days: 35)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '15',
      name: 'Tyler Brooks',
      age: 28,
      bio: 'Track & field athlete 🏃‍♂️ | Sprinter | Speed is everything',
      profilePic: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800&h=400&fit=crop',
      isVerified: false,
      isFollowing: false,
      openToMingle: true,
      joinedAt: DateTime(2023, 6, 7),
      interests: ['Track', 'Sprinting', 'Speed Training', 'Athletics', 'Competition'],
      followers: 7800,
      following: 560,
      posts: [],
      stats: UserStats(totalPosts: 43, followers: 7800, following: 560, totalViews: 49000),
      achievements: [],
    ),
    User(
      id: '16',
      name: 'Rachel Kim',
      age: 32,
      bio: 'Fitness photographer 📸 | Capturing strength & beauty | Visual storyteller',
      profilePic: 'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
      isVerified: true,
      isFollowing: true,
      openToMingle: false,
      joinedAt: DateTime(2023, 2, 28),
      interests: ['Photography', 'Fitness Art', 'Visual Content', 'Social Media', 'Creativity'],
      followers: 18700,
      following: 2300,
      posts: [],
      stats: UserStats(totalPosts: 156, followers: 18700, following: 2300, totalViews: 245000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Visual Artist',
          description: 'Shared 1000 fitness photos',
          iconUrl: '📸',
          unlockedAt: DateTime.now().subtract(const Duration(days: 18)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '17',
      name: 'Jordan Lee',
      age: 24,
      bio: 'Calisthenics athlete 🤸‍♂️ | Bodyweight movement specialist | No gym needed',
      profilePic: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
      isVerified: false,
      isFollowing: false,
      openToMingle: true,
      joinedAt: DateTime(2023, 9, 12),
      interests: ['Calisthenics', 'Bodyweight', 'Street Workout', 'Flexibility', 'Flow'],
      followers: 9100,
      following: 780,
      posts: [],
      stats: UserStats(totalPosts: 52, followers: 9100, following: 780, totalViews: 68000),
      achievements: [],
    ),
    User(
      id: '18',
      name: 'Amanda Davis',
      age: 29,
      bio: 'Functional fitness trainer 💪 | Movement quality expert | Real world strength',
      profilePic: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
      isVerified: true,
      isFollowing: true,
      openToMingle: false,
      joinedAt: DateTime(2023, 1, 5),
      interests: ['Functional Training', 'Movement', 'Mobility', 'Corrective Exercise', 'Rehab'],
      followers: 12800,
      following: 890,
      posts: [],
      stats: UserStats(totalPosts: 78, followers: 12800, following: 890, totalViews: 98000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Movement Master',
          description: 'Improved 500 movement patterns',
          iconUrl: '💪',
          unlockedAt: DateTime.now().subtract(const Duration(days: 25)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '19',
      name: 'Kevin Park',
      age: 27,
      bio: 'Boxing coach & trainer 🥊 | Former amateur boxer | Sweet science enthusiast',
      profilePic: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?w=800&h=400&fit=crop',
      isVerified: false,
      isFollowing: false,
      openToMingle: true,
      joinedAt: DateTime(2023, 3, 30),
      interests: ['Boxing', 'Combat Sports', 'Conditioning', 'Technique', 'Mental Training'],
      followers: 8300,
      following: 650,
      posts: [],
      stats: UserStats(totalPosts: 45, followers: 8300, following: 650, totalViews: 54000),
      achievements: [],
    ),
    User(
      id: '20',
      name: 'Zoe Mitchell',
      age: 25,
      bio: 'Wellness coach & mindset mentor 🌟 | Holistic health approach | Mind-body balance',
      profilePic: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop',
      isVerified: true,
      isFollowing: true,
      openToMingle: true,
      joinedAt: DateTime(2023, 5, 16),
      interests: ['Wellness', 'Mindset', 'Holistic Health', 'Mental Health', 'Life Coaching'],
      followers: 16200,
      following: 1450,
      posts: [],
      stats: UserStats(totalPosts: 92, followers: 16200, following: 1450, totalViews: 168000),
      achievements: [
        Achievement(
          id: '1',
          title: 'Wellness Guru',
          description: 'Coached 200 people to better health',
          iconUrl: '🌟',
          unlockedAt: DateTime.now().subtract(const Duration(days: 12)),
          isUnlocked: true,
        ),
      ],
    ),
    User(
      id: '21',
      name: 'Marcus Williams',
      age: 34,
      bio: 'Triathlete & endurance coach 🏊‍♂️🚴‍♂️🏃‍♂️ | Iron distance finisher | Push your limits',
      profilePic: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
      coverImage: 'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=800&h=400&fit=crop',
      isVerified: false,
      isFollowing: false,
      openToMingle: false,
      joinedAt: DateTime(2023, 7, 22),
      interests: ['Triathlon', 'Swimming', 'Cycling', 'Running', 'Endurance'],
      followers: 11700,
      following: 890,
      posts: [],
      stats: UserStats(totalPosts: 68, followers: 11700, following: 890, totalViews: 87000),
      achievements: [],
    ),
  ];

  // Sample topics with analytics
  static final List<SearchTopic> _sampleTopics = [
    SearchTopic(
      id: 't1',
      name: 'HIIT Fitness Workouts',
      description:
          'High-intensity interval fitness training for maximum results',
      emoji: '🔥',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 127,
        activeUsers: 2341,
        totalDiscussions: 892,
        activityLevel: ActivityLevel.veryActive,
      ),
      tags: ['HIIT', 'Cardio', 'Intensity', 'Fat Burn'],
      isFollowing: false,
      isTrending: true,
    ),
    SearchTopic(
      id: 't2',
      name: 'Yoga & Mindfulness Fitness',
      description:
          'Find your inner peace through fitness movement and meditation',
      emoji: '🧘‍♀️',
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=200&fit=crop&crop=center',
      analytics: TopicAnalytics(
        postsLast24h: 89,
        activeUsers: 1876,
        totalDiscussions: 567,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Yoga', 'Meditation', 'Mindfulness', 'Flexibility'],
      isFollowing: true,
      isTrending: false,
    ),
    SearchTopic(
      id: 't3',
      name: 'Strength Fitness Training',
      description: 'Build muscle and increase power with fitness weightlifting',
      emoji: '💪',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 156,
        activeUsers: 3124,
        totalDiscussions: 1245,
        activityLevel: ActivityLevel.veryActive,
      ),
      tags: ['Strength', 'Weightlifting', 'Muscle', 'Power'],
      isFollowing: false,
      isTrending: true,
    ),
    SearchTopic(
      id: 't4',
      name: 'Running & Cardio Fitness',
      description: 'Improve endurance and cardiovascular fitness health',
      emoji: '🏃‍♂️',
      imageUrl:
          'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 73,
        activeUsers: 1567,
        totalDiscussions: 423,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Running', 'Cardio', 'Endurance', 'Marathon'],
      isFollowing: false,
      isTrending: false,
    ),
    SearchTopic(
      id: 't5',
      name: 'Fitness Nutrition & Diet',
      description:
          'Fuel your body with the right foods for optimal fitness performance',
      emoji: '🥗',
      imageUrl:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 45,
        activeUsers: 987,
        totalDiscussions: 234,
        activityLevel: ActivityLevel.moderate,
      ),
      tags: ['Nutrition', 'Diet', 'Healthy Eating', 'Meal Prep'],
      isFollowing: true,
      isTrending: false,
    ),
    SearchTopic(
      id: 't6',
      name: 'Swimming & Water Fitness',
      description: 'Dive into aquatic fitness and swimming techniques for full-body workout',
      emoji: '🏊‍♂️',
      imageUrl: 'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 67,
        activeUsers: 1234,
        totalDiscussions: 445,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Swimming', 'Water Sports', 'Aqua Fitness', 'Triathlon'],
      isFollowing: false,
      isTrending: false,
    ),
    SearchTopic(
      id: 't7',
      name: 'Cycling & Bike Fitness',
      description: 'Road cycling, mountain biking, and indoor cycling fitness adventures',
      emoji: '🚴‍♂️',
      imageUrl: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 91,
        activeUsers: 1789,
        totalDiscussions: 623,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Cycling', 'Road Biking', 'Mountain Biking', 'Endurance'],
      isFollowing: true,
      isTrending: true,
    ),
    SearchTopic(
      id: 't8',
      name: 'Dance Fitness & Movement',
      description: 'Express yourself through dance while getting fit and having fun',
      emoji: '💃',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 112,
        activeUsers: 2567,
        totalDiscussions: 778,
        activityLevel: ActivityLevel.veryActive,
      ),
      tags: ['Dance', 'Zumba', 'Cardio Dance', 'Movement'],
      isFollowing: false,
      isTrending: true,
    ),
    SearchTopic(
      id: 't9',
      name: 'Martial Arts & Combat Sports',
      description: 'Traditional and modern martial arts for fitness, discipline, and self-defense',
      emoji: '🥋',
      imageUrl: 'https://images.unsplash.com/photo-1555597673-b21d5c935865?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 58,
        activeUsers: 998,
        totalDiscussions: 367,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Martial Arts', 'Karate', 'Boxing', 'Self Defense'],
      isFollowing: false,
      isTrending: false,
    ),
    SearchTopic(
      id: 't10',
      name: 'Pilates & Core Fitness',
      description: 'Strengthen your core and improve posture with pilates fitness methods',
      emoji: '✨',
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 76,
        activeUsers: 1456,
        totalDiscussions: 498,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Pilates', 'Core', 'Posture', 'Flexibility'],
      isFollowing: true,
      isTrending: false,
    ),
    SearchTopic(
      id: 't11',
      name: 'Calisthenics & Bodyweight',
      description: 'Master your bodyweight with calisthenics and street workout movements',
      emoji: '🤸‍♂️',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 94,
        activeUsers: 1723,
        totalDiscussions: 612,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Calisthenics', 'Bodyweight', 'Street Workout', 'Pull-ups'],
      isFollowing: false,
      isTrending: true,
    ),
    SearchTopic(
      id: 't12',
      name: 'Mental Health & Mindfulness',
      description: 'Mental wellness, stress management, and mindfulness for fitness life balance',
      emoji: '🧠',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 134,
        activeUsers: 2890,
        totalDiscussions: 1045,
        activityLevel: ActivityLevel.veryActive,
      ),
      tags: ['Mental Health', 'Mindfulness', 'Stress Relief', 'Wellness'],
      isFollowing: true,
      isTrending: true,
    ),
    SearchTopic(
      id: 't13',
      name: 'Recovery & Injury Prevention',
      description: 'Optimize recovery, prevent injuries, and maintain long-term fitness health',
      emoji: '🩹',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 42,
        activeUsers: 876,
        totalDiscussions: 289,
        activityLevel: ActivityLevel.moderate,
      ),
      tags: ['Recovery', 'Injury Prevention', 'Rehab', 'Mobility'],
      isFollowing: false,
      isTrending: false,
    ),
    SearchTopic(
      id: 't14',
      name: 'Team Sports & Group Fitness',
      description: 'Basketball, soccer, volleyball and other team sports for fitness fun',
      emoji: '🏀',
      imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 83,
        activeUsers: 1654,
        totalDiscussions: 567,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Basketball', 'Soccer', 'Team Sports', 'Group Fitness'],
      isFollowing: false,
      isTrending: false,
    ),
    SearchTopic(
      id: 't15',
      name: 'Powerlifting & Heavy Lifting',
      description: 'Squat, bench, deadlift - the art and science of moving heavy weight',
      emoji: '🏋️‍♂️',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 71,
        activeUsers: 1345,
        totalDiscussions: 478,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Powerlifting', 'Heavy Lifting', 'Strength', 'Competition'],
      isFollowing: false,
      isTrending: false,
    ),
    SearchTopic(
      id: 't16',
      name: 'Flexibility & Stretching',
      description: 'Improve mobility, flexibility, and range of motion for better movement',
      emoji: '🤸‍♀️',
      imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 39,
        activeUsers: 734,
        totalDiscussions: 215,
        activityLevel: ActivityLevel.moderate,
      ),
      tags: ['Flexibility', 'Stretching', 'Mobility', 'Recovery'],
      isFollowing: true,
      isTrending: false,
    ),
    SearchTopic(
      id: 't17',
      name: 'Weight Loss & Fat Burn',
      description: 'Effective strategies for healthy weight loss and fat burning workouts',
      emoji: '🔥',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 156,
        activeUsers: 3456,
        totalDiscussions: 1234,
        activityLevel: ActivityLevel.veryActive,
      ),
      tags: ['Weight Loss', 'Fat Burn', 'Cardio', 'Diet'],
      isFollowing: false,
      isTrending: true,
    ),
    SearchTopic(
      id: 't18',
      name: 'Outdoor Adventures & Hiking',
      description: 'Explore nature while staying fit through hiking and outdoor activities',
      emoji: '🥾',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 62,
        activeUsers: 1123,
        totalDiscussions: 389,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Hiking', 'Outdoor', 'Adventure', 'Nature'],
      isFollowing: false,
      isTrending: false,
    ),
    SearchTopic(
      id: 't19',
      name: 'Sports Supplements & Performance',
      description: 'Optimize performance with proper supplementation and fitness nutrition',
      emoji: '💊',
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 48,
        activeUsers: 923,
        totalDiscussions: 267,
        activityLevel: ActivityLevel.moderate,
      ),
      tags: ['Supplements', 'Performance', 'Nutrition', 'Recovery'],
      isFollowing: true,
      isTrending: false,
    ),
    SearchTopic(
      id: 't20',
      name: 'Functional Movement & Mobility',
      description: 'Improve daily movement patterns and functional strength for real life',
      emoji: '🏃‍♀️',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=200&fit=crop',
      analytics: TopicAnalytics(
        postsLast24h: 54,
        activeUsers: 1087,
        totalDiscussions: 334,
        activityLevel: ActivityLevel.active,
      ),
      tags: ['Functional Training', 'Movement', 'Mobility', 'Daily Life'],
      isFollowing: false,
      isTrending: false,
    ),
  ];

  // Sample posts
  static final List<FeedPost> _samplePosts = [
    FeedPost(
      id: 1,
      userId: '2',
      userAvatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&h=300&fit=crop&crop=face',
      userName: 'Maya Chen',
      userVerified: true,
      content:
          'Just finished an amazing sunrise yoga fitness session! 🧘‍♀️ Nothing beats starting the day with mindful movement. Who else loves morning yoga fitness routines? #YogaLife #MorningMotivation #Mindfulness #Fitness',
      timeAgo: '2h',
      category: 'Yoga',
      likes: 342,
      comments: 27,
      shares: 15,
      isLiked: false,
      isBookmarked: false,
      postType: PostType.photo,
      mediaItems: [
        MediaItem(
          type: MediaType.image,
          url:
              'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&h=800&fit=crop&crop=center',
          thumbnail:
              'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=400&fit=crop&crop=center',
        ),
      ],
      tags: ['yoga', 'mindfulness', 'morningworkout', 'beachyoga'],
    ),
    FeedPost(
      id: 2,
      userId: '3',
      userAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
      userName: 'Marcus Rodriguez',
      userVerified: false,
      content:
          'New PR on deadlifts today! 425lbs x 3 reps 💪 The fitness grind never stops. Remember, strength is built one rep at a time. #CrossFit #Powerlifting #StrengthTraining #PR #Fitness',
      timeAgo: '5h',
      category: 'Strength Training',
      likes: 567,
      comments: 45,
      shares: 23,
      isLiked: true,
      isBookmarked: false,
      postType: PostType.video,
      mediaItems: [
        MediaItem(
          type: MediaType.video,
          url:
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=400&fit=crop&crop=center', // Placeholder image instead of video
          thumbnail:
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=400&fit=crop',
          duration: 45,
        ),
      ],
      tags: ['crossfit', 'deadlift', 'personalrecord', 'strength'],
    ),
    FeedPost(
      id: 3,
      userId: '4',
      userAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300&h=300&fit=crop&crop=face',
      userName: 'Emma Thompson',
      userVerified: true,
      content:
          'Marathon training week 8 complete! 🏃‍♀️ Did my long run today - 18 miles at 7:45 pace. Fitness goals are getting closer every week. Boston, here I come! #MarathonTraining #RunningCommunity #BostonMarathon #Fitness',
      timeAgo: '8h',
      category: 'Running',
      likes: 892,
      comments: 67,
      shares: 34,
      isLiked: false,
      isBookmarked: true,
      postType: PostType.photo,
      mediaItems: [
        MediaItem(
          type: MediaType.image,
          url:
              'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800&h=800&fit=crop',
          thumbnail:
              'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=400&h=400&fit=crop',
        ),
      ],
      tags: ['marathon', 'running', 'bostonmarathon', 'training'],
    ),
    FeedPost(
      id: 4,
      userId: '5',
      userAvatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=300&fit=crop&crop=face',
      userName: 'David Kim',
      userVerified: false,
      content:
          'Epic climbing fitness session at the gorge today! 🧗‍♂️ Finally sent that V8 boulder problem I\'ve been projecting for weeks. The key was trusting the heel hook and consistent fitness training. #RockClimbing #Bouldering #ClimbingLife #Fitness',
      timeAgo: '1d',
      category: 'Adventure',
      likes: 423,
      comments: 38,
      shares: 19,
      isLiked: true,
      isBookmarked: true,
      postType: PostType.carousel,
      mediaItems: [
        MediaItem(
          type: MediaType.image,
          url:
              'https://images.unsplash.com/photo-1522163182402-834f871fd851?w=800&h=800&fit=crop',
          thumbnail:
              'https://images.unsplash.com/photo-1522163182402-834f871fd851?w=400&h=400&fit=crop',
        ),
        MediaItem(
          type: MediaType.image,
          url:
              'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?w=800&h=800&fit=crop',
          thumbnail:
              'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?w=400&h=400&fit=crop',
        ),
      ],
      tags: ['climbing', 'bouldering', 'outdoor', 'adventure'],
    ),
    FeedPost(
      id: 5,
      userId: '2',
      userAvatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&h=300&fit=crop&crop=face',
      userName: 'Maya Chen',
      userVerified: true,
      content:
          'Quick HIIT yoga fitness flow to get your heart pumping! 🔥 This 15-minute sequence combines traditional poses with cardio bursts. Save for your next fitness workout! #HIITYoga #YogaFlow #QuickWorkout #Fitness',
      timeAgo: '2d',
      category: 'HIIT',
      likes: 1234,
      comments: 89,
      shares: 67,
      isLiked: false,
      isBookmarked: false,
      postType: PostType.videoReel,
      mediaItems: [
        MediaItem(
          type: MediaType.video,
          url:
              'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=400&h=400&fit=crop&crop=center', // Placeholder image instead of video
          thumbnail:
              'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=400&h=400&fit=crop',
          duration: 30,
        ),
      ],
      tags: ['hiit', 'yoga', 'cardio', 'homeworkout'],
    ),
  ];

  // Sample videos (for video-specific search results)
  static final List<VideoPost> _sampleVideos = [
    VideoPost(
      id: 'v1',
      videoUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop&crop=center', // Placeholder image instead of video
      thumbnailUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
      creator: _sampleUsers[1], // Marcus Rodriguez
      title: '30-Minute Full Body HIIT Fitness Workout',
      description:
          'High-intensity interval fitness training for maximum calorie burn. No equipment needed!',
      tags: ['hiit', 'fullbody', 'noequipment', 'homeworkout'],
      workoutType: 'HIIT',
      difficulty: 'intermediate',
      duration: 1800,
      views: 15678,
      shares: 89,
      comments: 234,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isFollowing: false,
      reactionSummary: ReactionSummary.empty(),
      recommendations: [],
      isRecommended: false,
    ),
    VideoPost(
      id: 'v2',
      videoUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=400&fit=crop&crop=center', // Placeholder image instead of video
      thumbnailUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=400&fit=crop&crop=center',
      creator: _sampleUsers[0], // Maya Chen
      title: 'Morning Yoga Fitness Flow for Beginners',
      description:
          'Gentle 20-minute fitness flow to start your day with mindfulness and movement.',
      tags: ['yoga', 'morning', 'beginner', 'mindfulness'],
      workoutType: 'Yoga',
      difficulty: 'beginner',
      duration: 1200,
      views: 23456,
      shares: 123,
      comments: 345,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isFollowing: true,
      reactionSummary: ReactionSummary.empty(),
      recommendations: [],
      isRecommended: false,
    ),
    VideoPost(
      id: 'v3',
      videoUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=400&fit=crop&crop=center', // Placeholder image instead of video
      thumbnailUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=400&fit=crop',
      creator: _sampleUsers[1], // Marcus Rodriguez
      title: 'Advanced Calisthenics Fitness Progressions',
      description:
          'Master the muscle-up, human flag, and planche with these fitness progression exercises.',
      tags: ['calisthenics', 'advanced', 'strength', 'bodyweight'],
      workoutType: 'Strength',
      difficulty: 'advanced',
      duration: 2400,
      views: 8901,
      shares: 67,
      comments: 156,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      isFollowing: false,
      reactionSummary: ReactionSummary.empty(),
      recommendations: [],
      isRecommended: false,
    ),
  ];

  // Sample communities
  static final List<SearchCommunity> _sampleCommunities = [
    SearchCommunity(
      id: 'c1',
      name: 'Morning Warriors',
      description: 'Early birds who start their day with intense workouts',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop',
      memberCount: 12500,
      postsToday: 89,
      activityLevel: ActivityLevel.veryActive,
      isPrivate: false,
      isMember: true,
      tags: ['Morning Workouts', 'Early Birds', 'Motivation'],
      recentMembers: _sampleUsers.take(3).toList(),
    ),
    SearchCommunity(
      id: 'c2',
      name: 'Yoga Enthusiasts',
      description: 'A peaceful community for yoga lovers of all levels',
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=300&h=300&fit=crop&crop=center',
      memberCount: 8900,
      postsToday: 34,
      activityLevel: ActivityLevel.active,
      isPrivate: false,
      isMember: false,
      tags: ['Yoga', 'Meditation', 'Flexibility', 'Peace'],
      recentMembers: _sampleUsers.skip(1).take(3).toList(),
    ),
    SearchCommunity(
      id: 'c3',
      name: 'CrossFit Champions',
      description: 'Elite CrossFit athletes pushing their limits',
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=300&h=300&fit=crop',
      memberCount: 6700,
      postsToday: 67,
      activityLevel: ActivityLevel.veryActive,
      isPrivate: true,
      isMember: false,
      tags: ['CrossFit', 'Elite', 'Competition', 'Strength'],
      recentMembers: _sampleUsers.take(2).toList(),
    ),
    SearchCommunity(
      id: 'c4',
      name: 'Adventure Seekers',
      description: 'Outdoor fitness and adventure sports community',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop',
      memberCount: 4500,
      postsToday: 23,
      activityLevel: ActivityLevel.moderate,
      isPrivate: false,
      isMember: true,
      tags: ['Adventure', 'Outdoor', 'Hiking', 'Nature'],
      recentMembers: _sampleUsers.skip(2).take(2).toList(),
    ),
  ];

  // Search suggestions
  static final List<SearchSuggestion> _suggestions = [
    SearchSuggestion(
        id: 's1',
        text: 'HIIT workouts',
        type: SearchResultType.posts,
        popularity: 95),
    SearchSuggestion(
        id: 's2',
        text: 'Yoga poses',
        type: SearchResultType.posts,
        popularity: 87),
    SearchSuggestion(
        id: 's3',
        text: 'Strength training',
        type: SearchResultType.topics,
        popularity: 92),
    SearchSuggestion(
        id: 's4',
        text: 'Open to mingle',
        type: SearchResultType.people,
        popularity: 78),
    SearchSuggestion(
        id: 's5',
        text: 'CrossFit',
        type: SearchResultType.communities,
        popularity: 83),
    SearchSuggestion(
        id: 's6',
        text: 'Marathon training',
        type: SearchResultType.posts,
        popularity: 76),
    SearchSuggestion(
        id: 's7',
        text: 'Morning workouts',
        type: SearchResultType.communities,
        popularity: 82),
    SearchSuggestion(
        id: 's8',
        text: 'Nutrition tips',
        type: SearchResultType.topics,
        popularity: 74),
  ];

  // Search method
  static List<SearchResult> search(String query, SearchFilter filter) {
    final List<SearchResult> results = [];
    final lowerQuery = query.toLowerCase();

    // Search users
    if (filter.type == null || filter.type == SearchResultType.people) {
      for (final user in _sampleUsers) {
        double score = 0.0;

        // Name match
        if (user.name.toLowerCase().contains(lowerQuery)) score += 1.0;

        // Bio match
        if (user.bio.toLowerCase().contains(lowerQuery)) score += 0.5;

        // Interests match
        for (final interest in user.interests) {
          if (interest.toLowerCase().contains(lowerQuery)) score += 0.3;
        }

        // Filter by openToMingle if specified
        if (filter.openToMingleOnly && !user.openToMingle) continue;

        if (score > 0) {
          results.add(SearchResult.user(
            id: 'user_${user.id}',
            user: user,
            relevanceScore: score,
          ));
        }
      }
    }

    // Search topics
    if (filter.type == null || filter.type == SearchResultType.topics) {
      for (final topic in _sampleTopics) {
        double score = 0.0;

        // Name match
        if (topic.name.toLowerCase().contains(lowerQuery)) score += 1.0;

        // Description match
        if (topic.description.toLowerCase().contains(lowerQuery)) score += 0.7;

        // Tags match
        for (final tag in topic.tags) {
          if (tag.toLowerCase().contains(lowerQuery)) score += 0.4;
        }

        if (score > 0) {
          results.add(SearchResult.topic(
            id: 'topic_${topic.id}',
            topic: topic,
            relevanceScore: score,
          ));
        }
      }
    }

    // Search communities
    if (filter.type == null || filter.type == SearchResultType.communities) {
      for (final community in _sampleCommunities) {
        double score = 0.0;

        // Name match
        if (community.name.toLowerCase().contains(lowerQuery)) score += 1.0;

        // Description match
        if (community.description.toLowerCase().contains(lowerQuery))
          score += 0.7;

        // Tags match
        for (final tag in community.tags) {
          if (tag.toLowerCase().contains(lowerQuery)) score += 0.4;
        }

        if (score > 0) {
          results.add(SearchResult.community(
            id: 'community_${community.id}',
            community: community,
            relevanceScore: score,
          ));
        }
      }
    }

    // Search posts
    if (filter.type == null || filter.type == SearchResultType.posts) {
      for (final post in _samplePosts) {
        double score = 0.0;

        // Content match
        if (post.content.toLowerCase().contains(lowerQuery)) score += 1.0;

        // Username match
        if (post.userName.toLowerCase().contains(lowerQuery)) score += 0.5;

        // Category match
        if (post.category.toLowerCase().contains(lowerQuery)) score += 0.3;

        // Tags match
        for (final tag in post.tags) {
          if (tag.toLowerCase().contains(lowerQuery)) score += 0.4;
        }

        if (score > 0) {
          results.add(SearchResult.post(
            id: 'post_${post.id}',
            post: post,
            relevanceScore: score,
          ));
        }
      }

      // Also search videos for the posts tab
      for (final video in _sampleVideos) {
        double score = 0.0;

        // Title match
        if (video.title.toLowerCase().contains(lowerQuery)) score += 1.0;

        // Description match
        if (video.description.toLowerCase().contains(lowerQuery)) score += 0.7;

        // Creator name match
        if (video.creator.name.toLowerCase().contains(lowerQuery)) score += 0.5;

        // Workout type match
        if (video.workoutType.toLowerCase().contains(lowerQuery)) score += 0.6;

        // Tags match
        for (final tag in video.tags) {
          if (tag.toLowerCase().contains(lowerQuery)) score += 0.4;
        }

        if (score > 0) {
          results.add(SearchResult.video(
            id: 'video_${video.id}',
            video: video,
            relevanceScore: score,
          ));
        }
      }
    }

    // Sort by relevance score (highest first)
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return results;
  }

  // Get search suggestions
  static List<SearchSuggestion> getSuggestions(String query) {
    if (query.length < 2) return [];

    final lowerQuery = query.toLowerCase();
    return _suggestions
        .where(
            (suggestion) => suggestion.text.toLowerCase().contains(lowerQuery))
        .take(5)
        .toList();
  }

  // Get trending topics
  static List<SearchTopic> getTrendingTopics() {
    return _sampleTopics.where((topic) => topic.isTrending).toList();
  }

  // Get sample data for direct access
  static List<User> get sampleUsers => _sampleUsers;
  static List<SearchTopic> get sampleTopics => _sampleTopics;
  static List<SearchCommunity> get sampleCommunities => _sampleCommunities;
  static List<FeedPost> get samplePosts => _samplePosts;
  static List<VideoPost> get sampleVideos => _sampleVideos;
}

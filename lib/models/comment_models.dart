import 'user_model.dart';

class Comment {
  final String id;
  final String videoId;
  final User author;
  final String content;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;
  final List<Comment> replies;
  final String? parentCommentId;
  final bool isAuthor; // Is this comment from the video creator?
  final bool isPinned;
  final bool isEdited;
  final List<String> mentions; // @username mentions

  Comment({
    required this.id,
    required this.videoId,
    required this.author,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
    this.replies = const [],
    this.parentCommentId,
    this.isAuthor = false,
    this.isPinned = false,
    this.isEdited = false,
    this.mentions = const [],
  });

  Comment copyWith({
    String? id,
    String? videoId,
    User? author,
    String? content,
    DateTime? createdAt,
    int? likes,
    bool? isLiked,
    List<Comment>? replies,
    String? parentCommentId,
    bool? isAuthor,
    bool? isPinned,
    bool? isEdited,
    List<String>? mentions,
  }) {
    return Comment(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      isAuthor: isAuthor ?? this.isAuthor,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      mentions: mentions ?? this.mentions,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  bool get isReply => parentCommentId != null;
  int get totalReplies => replies.length;
  bool get hasReplies => replies.isNotEmpty;
}

class CommentReaction {
  final String id;
  final String commentId;
  final User user;
  final String emoji;
  final DateTime createdAt;

  CommentReaction({
    required this.id,
    required this.commentId,
    required this.user,
    required this.emoji,
    required this.createdAt,
  });
}

class CommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreComments;
  final String? replyingToId;
  final User? replyingToUser;
  final String? editingCommentId;
  final bool isSubmitting;
  final String? error;
  final int totalComments;

  CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreComments = true,
    this.replyingToId,
    this.replyingToUser,
    this.editingCommentId,
    this.isSubmitting = false,
    this.error,
    this.totalComments = 0,
  });

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMoreComments,
    String? replyingToId,
    User? replyingToUser,
    String? editingCommentId,
    bool? isSubmitting,
    String? error,
    int? totalComments,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      replyingToId: replyingToId ?? this.replyingToId,
      replyingToUser: replyingToUser ?? this.replyingToUser,
      editingCommentId: editingCommentId ?? this.editingCommentId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      totalComments: totalComments ?? this.totalComments,
    );
  }
}

// Mock data for testing
final List<User> mockCommentUsers = [
  User(
    id: 'user_1',
    name: 'Sarah Johnson',
    age: 26,
    bio: 'Fitness enthusiast',
    profilePic: 'https://images.unsplash.com/photo-1494790108755-2616b612b77c?w=150&h=150&fit=crop&crop=face',
    coverImage: '',
    isVerified: true,
    joinedAt: DateTime.now().subtract(const Duration(days: 100)),
    interests: ['Fitness'],
    posts: [],
    stats: UserStats(totalPosts: 0, followers: 0, following: 0, totalViews: 0),
    achievements: [],
  ),
  User(
    id: 'user_2',
    name: 'Mike Chen',
    age: 29,
    bio: 'Personal trainer',
    profilePic: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    coverImage: '',
    isVerified: false,
    joinedAt: DateTime.now().subtract(const Duration(days: 200)),
    interests: ['Training'],
    posts: [],
    stats: UserStats(totalPosts: 0, followers: 0, following: 0, totalViews: 0),
    achievements: [],
  ),
  User(
    id: 'user_3',
    name: 'Emma Wilson',
    age: 24,
    bio: 'Yoga instructor',
    profilePic: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
    coverImage: '',
    isVerified: true,
    joinedAt: DateTime.now().subtract(const Duration(days: 150)),
    interests: ['Yoga'],
    posts: [],
    stats: UserStats(totalPosts: 0, followers: 0, following: 0, totalViews: 0),
    achievements: [],
  ),
];

final List<Comment> mockComments = [
  Comment(
    id: 'comment_1',
    videoId: '1',
    author: mockCommentUsers[0],
    content: 'Amazing workout! 💪 This really pushed me to my limits. Thanks for the motivation!',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    likes: 23,
    isLiked: true,
    isPinned: true,
    replies: [
      Comment(
        id: 'reply_1',
        videoId: '1',
        parentCommentId: 'comment_1',
        author: mockCommentUsers[1],
        content: 'Same here! Let\'s keep pushing each other 🔥',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 7,
        isLiked: false,
      ),
      Comment(
        id: 'reply_2',
        videoId: '1',
        parentCommentId: 'comment_1',
        author: mockCommentUsers[2],
        content: 'Great form! 👌',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 3,
        isLiked: true,
      ),
    ],
  ),
  Comment(
    id: 'comment_2',
    videoId: '1',
    author: mockCommentUsers[1],
    content: 'What weight did you use for this exercise? I\'m trying to progress but not sure if I should increase.',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    likes: 12,
    isLiked: false,
    isAuthor: true,
    replies: [
      Comment(
        id: 'reply_3',
        videoId: '1',
        parentCommentId: 'comment_2',
        author: mockCommentUsers[2],
        content: 'Start with lighter weights and focus on form first! 💯',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likes: 8,
        isLiked: true,
      ),
    ],
  ),
  Comment(
    id: 'comment_3',
    videoId: '1',
    author: mockCommentUsers[2],
    content: 'Perfect timing! Just finished my chest day and this is exactly what I needed for tomorrow 🙌',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    likes: 18,
    isLiked: false,
  ),
  Comment(
    id: 'comment_4',
    videoId: '1',
    author: mockCommentUsers[0],
    content: 'Anyone else feel the burn in their shoulders? 😅 This move is no joke!',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    likes: 9,
    isLiked: true,
    replies: [
      Comment(
        id: 'reply_4',
        videoId: '1',
        parentCommentId: 'comment_4',
        author: mockCommentUsers[1],
        content: 'Yep! Make sure to warm up those shoulders first 🔥',
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        likes: 4,
        isLiked: false,
      ),
    ],
  ),
  Comment(
    id: 'comment_5',
    videoId: '1',
    author: mockCommentUsers[1],
    content: 'This is my new favorite exercise! Added it to my routine and already seeing results 💪',
    createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    likes: 15,
    isLiked: true,
  ),
];
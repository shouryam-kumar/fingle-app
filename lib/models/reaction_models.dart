import 'package:flutter/material.dart';

enum ReactionType {
  like,
  love,
  laugh,
  wow,
  sad,
  angry,
  fire,
  strong,
}

class ReactionData {
  final ReactionType type;
  final String emoji;
  final String label;
  final Color color;
  final String animationPath;

  const ReactionData({
    required this.type,
    required this.emoji,
    required this.label,
    required this.color,
    required this.animationPath,
  });

  static const Map<ReactionType, ReactionData> reactions = {
    ReactionType.like: ReactionData(
      type: ReactionType.like,
      emoji: '👍',
      label: 'Like',
      color: Color(0xFF1877F2),
      animationPath: 'assets/animations/like.json',
    ),
    ReactionType.love: ReactionData(
      type: ReactionType.love,
      emoji: '❤️',
      label: 'Love',
      color: Color(0xFFE91E63),
      animationPath: 'assets/animations/love.json',
    ),
    ReactionType.laugh: ReactionData(
      type: ReactionType.laugh,
      emoji: '😂',
      label: 'Laugh',
      color: Color(0xFFF7B928),
      animationPath: 'assets/animations/laugh.json',
    ),
    ReactionType.wow: ReactionData(
      type: ReactionType.wow,
      emoji: '😮',
      label: 'Wow',
      color: Color(0xFFF7B928),
      animationPath: 'assets/animations/wow.json',
    ),
    ReactionType.sad: ReactionData(
      type: ReactionType.sad,
      emoji: '😢',
      label: 'Sad',
      color: Color(0xFFF7B928),
      animationPath: 'assets/animations/sad.json',
    ),
    ReactionType.angry: ReactionData(
      type: ReactionType.angry,
      emoji: '😠',
      label: 'Angry',
      color: Color(0xFFE91E63),
      animationPath: 'assets/animations/angry.json',
    ),
    ReactionType.fire: ReactionData(
      type: ReactionType.fire,
      emoji: '🔥',
      label: 'Fire',
      color: Color(0xFFFF5722),
      animationPath: 'assets/animations/fire.json',
    ),
    ReactionType.strong: ReactionData(
      type: ReactionType.strong,
      emoji: '💪',
      label: 'Strong',
      color: Color(0xFF8BC34A),
      animationPath: 'assets/animations/strong.json',
    ),
  };

  static ReactionData getReactionData(ReactionType type) {
    return reactions[type] ?? reactions[ReactionType.like]!;
  }
}

class Reaction {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final ReactionType type;
  final DateTime createdAt;

  const Reaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.type,
    required this.createdAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      type: ReactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReactionType.like,
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ReactionSummary {
  final Map<ReactionType, int> counts;
  final Map<ReactionType, List<Reaction>> reactions;
  final ReactionType? userReaction;
  final int totalCount;

  const ReactionSummary({
    required this.counts,
    required this.reactions,
    this.userReaction,
    required this.totalCount,
  });

  factory ReactionSummary.empty() {
    return const ReactionSummary(
      counts: {},
      reactions: {},
      userReaction: null,
      totalCount: 0,
    );
  }

  factory ReactionSummary.fromReactions(
      List<Reaction> reactions, String currentUserId) {
    final counts = <ReactionType, int>{};
    final groupedReactions = <ReactionType, List<Reaction>>{};
    ReactionType? userReaction;

    for (final reaction in reactions) {
      counts[reaction.type] = (counts[reaction.type] ?? 0) + 1;

      if (!groupedReactions.containsKey(reaction.type)) {
        groupedReactions[reaction.type] = [];
      }
      groupedReactions[reaction.type]!.add(reaction);

      if (reaction.userId == currentUserId) {
        userReaction = reaction.type;
      }
    }

    return ReactionSummary(
      counts: counts,
      reactions: groupedReactions,
      userReaction: userReaction,
      totalCount: reactions.length,
    );
  }

  List<ReactionType> get topReactionTypes {
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.map((e) => e.key).take(3).toList();
  }

  bool get hasReactions => totalCount > 0;

  int getCount(ReactionType type) => counts[type] ?? 0;

  List<Reaction> getReactions(ReactionType type) => reactions[type] ?? [];
}

class Recommendation {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final DateTime createdAt;
  final String? message;

  const Recommendation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.createdAt,
    this.message,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      createdAt: DateTime.parse(json['createdAt']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'createdAt': createdAt.toIso8601String(),
      'message': message,
    };
  }
}

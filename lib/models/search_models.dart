import '../models/user_model.dart';
import '../models/video_models.dart';
import '../models/home_models.dart';

enum SearchResultType {
  all,
  people,
  topics,
  posts,
  communities,
  trending,
  saved,
}

enum SearchSuggestionType {
  general,
  user,
  topic,
  hashtag,
  recent,
}

enum ActivityLevel {
  veryActive,
  active,
  moderate,
}

enum SubFilterType {
  // People sub-filters
  nearby,
  following,
  openToMingle,

  // Topics sub-filters
  topicsTrending,
  topicsFollowing,
  topicsRecommended,

  // Posts sub-filters
  latest,
  popular,
  mediaOnly,

  // Communities sub-filters
  joined,
  recommended,
  local,
}

enum SortType {
  relevance,
  recent,
  popular,
  trending,
  alphabetical,
}

enum DateRange {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  allTime,
}

class SearchFilter {
  final SearchResultType? type;
  final String? category;
  final List<String> tags;
  final String? difficulty;
  final bool openToMingleOnly;
  final ActivityLevel? activityLevel;
  final SubFilterType? subFilter;
  final SortType sortType;
  final bool showMediaOnly;
  final bool nearbyOnly;
  final List<SearchResultType>? contentTypes;
  final List<String>? categories;
  final DateRange? dateRange;
  final SortType? sortBy;

  SearchFilter({
    this.type,
    this.category,
    this.tags = const [],
    this.difficulty,
    this.openToMingleOnly = false,
    this.activityLevel,
    this.subFilter,
    this.sortType = SortType.relevance,
    this.showMediaOnly = false,
    this.nearbyOnly = false,
    this.contentTypes,
    this.categories,
    this.dateRange,
    this.sortBy,
  });

  SearchFilter copyWith({
    SearchResultType? type,
    String? category,
    List<String>? tags,
    String? difficulty,
    bool? openToMingleOnly,
    ActivityLevel? activityLevel,
    SubFilterType? subFilter,
    SortType? sortType,
    bool? showMediaOnly,
    bool? nearbyOnly,
    List<SearchResultType>? contentTypes,
    List<String>? categories,
    DateRange? dateRange,
    SortType? sortBy,
  }) {
    return SearchFilter(
      type: type ?? this.type,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      openToMingleOnly: openToMingleOnly ?? this.openToMingleOnly,
      activityLevel: activityLevel ?? this.activityLevel,
      subFilter: subFilter ?? this.subFilter,
      sortType: sortType ?? this.sortType,
      showMediaOnly: showMediaOnly ?? this.showMediaOnly,
      nearbyOnly: nearbyOnly ?? this.nearbyOnly,
      contentTypes: contentTypes ?? this.contentTypes,
      categories: categories ?? this.categories,
      dateRange: dateRange ?? this.dateRange,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class SearchSuggestion {
  final String id;
  final String text;
  final SearchResultType type;
  final SearchSuggestionType suggestionType;
  final int popularity;
  final int searchCount;
  final bool isPopular;
  final String? iconUrl;
  final String? category;

  SearchSuggestion({
    String? id,
    required this.text,
    required this.type,
    SearchSuggestionType? suggestionType,
    int? popularity,
    int? searchCount,
    bool? isPopular,
    this.iconUrl,
    this.category,
  })  : id = id ?? text,
        suggestionType = suggestionType ?? SearchSuggestionType.general,
        popularity = popularity ?? 0,
        searchCount = searchCount ?? 0,
        isPopular = isPopular ?? false;
}

class TopicAnalytics {
  final int postsLast24h;
  final int activeUsers;
  final int totalDiscussions;
  final ActivityLevel activityLevel;

  TopicAnalytics({
    required this.postsLast24h,
    required this.activeUsers,
    required this.totalDiscussions,
    required this.activityLevel,
  });
}

class SearchTopic {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final TopicAnalytics analytics;
  final List<String> tags;
  final bool isFollowing;
  final bool isTrending;
  final String imageUrl;

  SearchTopic({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.analytics,
    required this.tags,
    this.isFollowing = false,
    this.isTrending = false,
    required this.imageUrl,
  });

  SearchTopic copyWith({
    bool? isFollowing,
  }) {
    return SearchTopic(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      analytics: analytics,
      tags: tags,
      isFollowing: isFollowing ?? this.isFollowing,
      isTrending: isTrending,
      imageUrl: imageUrl,
    );
  }
}

class SearchCommunity {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int memberCount;
  final int postsToday;
  final ActivityLevel activityLevel;
  final bool isPrivate;
  final bool isMember;
  final List<String> tags;
  final List<User> recentMembers;

  SearchCommunity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.memberCount,
    required this.postsToday,
    required this.activityLevel,
    this.isPrivate = false,
    this.isMember = false,
    required this.tags,
    required this.recentMembers,
  });

  SearchCommunity copyWith({
    bool? isMember,
  }) {
    return SearchCommunity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      memberCount: memberCount,
      postsToday: postsToday,
      activityLevel: activityLevel,
      isPrivate: isPrivate,
      isMember: isMember ?? this.isMember,
      tags: tags,
      recentMembers: recentMembers,
    );
  }
}

class SearchResult {
  final String id;
  final SearchResultType type;
  final User? user;
  final FeedPost? post;
  final VideoPost? video;
  final SearchTopic? topic;
  final SearchCommunity? community;
  final double relevanceScore;

  SearchResult({
    required this.id,
    required this.type,
    this.user,
    this.post,
    this.video,
    this.topic,
    this.community,
    required this.relevanceScore,
  });

  SearchResult.user({
    required this.id,
    required User user,
    required this.relevanceScore,
  })  : type = SearchResultType.people,
        user = user,
        post = null,
        video = null,
        topic = null,
        community = null;

  SearchResult.post({
    required this.id,
    required FeedPost post,
    required this.relevanceScore,
  })  : type = SearchResultType.posts,
        user = null,
        post = post,
        video = null,
        topic = null,
        community = null;

  SearchResult.video({
    required this.id,
    required VideoPost video,
    required this.relevanceScore,
  })  : type = SearchResultType.posts,
        user = null,
        post = null,
        video = video,
        topic = null,
        community = null;

  SearchResult.topic({
    required this.id,
    required SearchTopic topic,
    required this.relevanceScore,
  })  : type = SearchResultType.topics,
        user = null,
        post = null,
        video = null,
        topic = topic,
        community = null;

  SearchResult.community({
    required this.id,
    required SearchCommunity community,
    required this.relevanceScore,
  })  : type = SearchResultType.communities,
        user = null,
        post = null,
        video = null,
        topic = null,
        community = community;
}

class TrendingMetrics {
  final double trendingScore;
  final int engagementRate;
  final int recentActivity;
  final DateTime lastUpdated;
  final String trendingReason;

  TrendingMetrics({
    required this.trendingScore,
    required this.engagementRate,
    required this.recentActivity,
    required this.lastUpdated,
    required this.trendingReason,
  });
}

class MixedContentResult {
  final SearchResult result;
  final double algorithmScore;
  final String displayReason;
  final int priority;
  final TrendingMetrics? trendingMetrics;

  MixedContentResult({
    required this.result,
    required this.algorithmScore,
    required this.displayReason,
    required this.priority,
    this.trendingMetrics,
  });
}

class TabBadgeInfo {
  final int resultCount;
  final bool hasTrending;
  final bool hasNewContent;
  final int newContentCount;
  final ActivityLevel? activityLevel;

  TabBadgeInfo({
    required this.resultCount,
    this.hasTrending = false,
    this.hasNewContent = false,
    this.newContentCount = 0,
    this.activityLevel,
  });
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/search_models.dart';
import '../../models/user_model.dart' as app_models;
import '../../models/home_models.dart';

class SearchService {
  static final _supabase = Supabase.instance.client;

  /// Perform comprehensive search across all content types
  static Future<List<SearchResult>> performSearch({
    required String query,
    SearchFilter? filter,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc('api_search_content', params: {
        'p_query': query,
        'p_content_types': filter?.contentTypes?.map((t) => t.name).toList() ?? ['all'],
        'p_categories': filter?.categories ?? [],
        'p_date_range': filter?.dateRange?.name,
        'p_sort_by': filter?.sortBy?.name ?? 'relevance',
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response != null && response['success'] == true) {
        final resultsData = response['data'] as List;
        return resultsData.map((resultData) => _parseSearchResult(resultData)).toList();
      }
      return [];
    } catch (e) {
      print('Error performing search: $e');
      return [];
    }
  }

  /// Get search suggestions based on partial query
  static Future<List<SearchSuggestion>> getSearchSuggestions({
    required String query,
    int limit = 10,
  }) async {
    try {
      final response = await _supabase.rpc('api_get_search_suggestions', params: {
        'p_query': query,
        'p_limit': limit,
      });

      if (response != null && response['success'] == true) {
        final suggestionsData = response['data'] as List;
        return suggestionsData.map((suggestionData) => SearchSuggestion(
          text: suggestionData['text'] ?? '',
          type: SearchResultType.values.firstWhere(
            (type) => type.name == suggestionData['result_type'],
            orElse: () => SearchResultType.all,
          ),
          suggestionType: SearchSuggestionType.values.firstWhere(
            (type) => type.name == suggestionData['type'],
            orElse: () => SearchSuggestionType.general,
          ),
          searchCount: suggestionData['search_count'] ?? 0,
          isPopular: suggestionData['is_popular'] ?? false,
          category: suggestionData['category'],
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }

  /// Get trending topics and hashtags
  static Future<List<TrendingTopic>> getTrendingTopics({int limit = 20}) async {
    try {
      final response = await _supabase.rpc('api_get_trending_topics', params: {
        'p_limit': limit,
      });

      if (response != null && response['success'] == true) {
        final topicsData = response['data'] as List;
        return topicsData.map((topicData) => TrendingTopic(
          id: topicData['id'] ?? 0,
          name: topicData['name'] ?? '',
          emoji: topicData['emoji'] ?? '💪',
          gradient: _getGradientFromString(topicData['gradient_type'] ?? 'purple'),
          postCount: topicData['post_count'] ?? 0,
        )).toList();
      }
      return [];
    } catch (e) {
      print('Error getting trending topics: $e');
      return [];
    }
  }

  /// Search for users
  static Future<List<app_models.User>> searchUsers({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc('api_search_users', params: {
        'p_query': query,
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response != null && response['success'] == true) {
        final usersData = response['data'] as List;
        return usersData.map((userData) => _parseUserFromJson(userData)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Search for posts
  static Future<List<FeedPost>> searchPosts({
    required String query,
    List<String>? categories,
    String? sortBy,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc('api_search_posts', params: {
        'p_query': query,
        if (categories != null) 'p_categories': categories,
        'p_sort_by': sortBy ?? 'relevance',
        'p_limit': limit,
        'p_offset': offset,
      });

      if (response != null && response['success'] == true) {
        final postsData = response['data'] as List;
        return postsData.map((postData) => FeedPost.fromSupabaseJson(postData)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching posts: $e');
      return [];
    }
  }

  /// Get popular searches
  static Future<List<String>> getPopularSearches({int limit = 10}) async {
    try {
      final response = await _supabase.rpc('api_get_popular_searches', params: {
        'p_limit': limit,
      });

      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        return data.map((item) => item['query'] as String).toList();
      }
      return [];
    } catch (e) {
      print('Error getting popular searches: $e');
      return [];
    }
  }

  /// Track search analytics
  static Future<bool> trackSearchAnalytics({
    required String query,
    required String resultType,
    String? resultId,
  }) async {
    try {
      final response = await _supabase.rpc('api_track_search_analytics', params: {
        'p_query': query,
        'p_result_type': resultType,
        if (resultId != null) 'p_result_id': resultId,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error tracking search analytics: $e');
      return false;
    }
  }

  /// Get search history for current user
  static Future<List<String>> getSearchHistory({int limit = 20}) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return [];

      final response = await _supabase
          .from('search_history')
          .select('query')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((item) => item['query'] as String).toList();
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  /// Save search to history
  static Future<bool> saveSearchToHistory(String query) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      // Check if query already exists
      final existing = await _supabase
          .from('search_history')
          .select('id')
          .eq('user_id', currentUser.id)
          .eq('query', query)
          .limit(1);

      if (existing.isEmpty) {
        // Insert new search
        await _supabase.from('search_history').insert({
          'user_id': currentUser.id,
          'query': query,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Update timestamp
        await _supabase
            .from('search_history')
            .update({'created_at': DateTime.now().toIso8601String()})
            .eq('id', existing.first['id']);
      }

      return true;
    } catch (e) {
      print('Error saving search to history: $e');
      return false;
    }
  }

  /// Delete search from history
  static Future<bool> deleteSearchFromHistory(String query) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      await _supabase
          .from('search_history')
          .delete()
          .eq('user_id', currentUser.id)
          .eq('query', query);

      return true;
    } catch (e) {
      print('Error deleting search from history: $e');
      return false;
    }
  }

  /// Clear all search history
  static Future<bool> clearSearchHistory() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;

      await _supabase
          .from('search_history')
          .delete()
          .eq('user_id', currentUser.id);

      return true;
    } catch (e) {
      print('Error clearing search history: $e');
      return false;
    }
  }

  /// Get "Did you mean" suggestions
  static Future<String?> getDidYouMeanSuggestion(String query) async {
    try {
      final response = await _supabase.rpc('api_get_did_you_mean', params: {
        'p_query': query,
      });

      if (response != null && response['success'] == true) {
        return response['data']['suggestion'];
      }
      return null;
    } catch (e) {
      print('Error getting did you mean suggestion: $e');
      return null;
    }
  }

  /// Get related searches
  static Future<List<String>> getRelatedSearches(String query, {int limit = 5}) async {
    try {
      final response = await _supabase.rpc('api_get_related_searches', params: {
        'p_query': query,
        'p_limit': limit,
      });

      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        return data.map((item) => item['query'] as String).toList();
      }
      return [];
    } catch (e) {
      print('Error getting related searches: $e');
      return [];
    }
  }

  /// Parse search result from JSON
  static SearchResult _parseSearchResult(Map<String, dynamic> json) {
    final contentType = json['content_type'] ?? 'post';
    final resultType = SearchResultType.values.firstWhere(
      (type) => type.name == contentType,
      orElse: () => SearchResultType.posts,
    );

    switch (resultType) {
      case SearchResultType.people:
        return SearchResult.user(
          id: json['id'] ?? '',
          user: _parseUserFromJson(json),
          relevanceScore: (json['relevance_score'] ?? 0.0).toDouble(),
        );

      case SearchResultType.posts:
        return SearchResult.post(
          id: json['id'] ?? '',
          post: FeedPost.fromSupabaseJson(json),
          relevanceScore: (json['relevance_score'] ?? 0.0).toDouble(),
        );

      case SearchResultType.topics:
        return SearchResult.topic(
          id: json['id'] ?? '',
          topic: SearchTopic(
            id: json['id'] ?? '',
            name: json['name'] ?? '',
            description: json['description'] ?? '',
            emoji: json['emoji'] ?? '🏷️',
            analytics: TopicAnalytics(
              postsLast24h: json['posts_last_24h'] ?? json['post_count'] ?? 0,
              activeUsers: json['active_users'] ?? json['follower_count'] ?? 0,
              totalDiscussions: json['total_discussions'] ?? 0,
              activityLevel: ActivityLevel.moderate,
            ),
            tags: List<String>.from(json['tags'] ?? []),
            isFollowing: json['is_following'] ?? false,
            isTrending: json['is_trending'] ?? json['trending'] ?? false,
            imageUrl: json['image_url'] ?? '',
          ),
          relevanceScore: (json['relevance_score'] ?? 0.0).toDouble(),
        );

      default:
        return SearchResult.post(
          id: json['id'] ?? '',
          post: FeedPost.fromSupabaseJson(json),
          relevanceScore: (json['relevance_score'] ?? 0.0).toDouble(),
        );
    }
  }

  /// Parse user from JSON
  static app_models.User _parseUserFromJson(Map<String, dynamic> json) {
    return app_models.User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['full_name'] ?? json['name'] ?? 'Unknown',
      age: json['age'] ?? 25,
      bio: json['bio'] ?? '',
      profilePic: json['avatar_url'] ?? json['profile_pic'] ?? '',
      coverImage: json['cover_image'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isFollowing: json['is_following'] ?? false,
      joinedAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      interests: List<String>.from(json['interests'] ?? []),
      followers: json['followers_count'] ?? 0,
      following: json['following_count'] ?? 0,
      posts: [],
      stats: app_models.UserStats(
        totalPosts: json['posts_count'] ?? 0,
        followers: json['followers_count'] ?? 0,
        following: json['following_count'] ?? 0,
        totalViews: json['total_views'] ?? 0,
      ),
      achievements: [],
    );
  }

  /// Get gradient from string identifier
  static LinearGradient _getGradientFromString(String gradientType) {
    switch (gradientType.toLowerCase()) {
      case 'purple':
        return const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]);
      case 'mint':
        return const LinearGradient(colors: [Color(0xFF00d2ff), Color(0xFF3a7bd5)]);
      case 'sunset':
        return const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]);
      case 'ocean':
        return const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]);
      default:
        return const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]);
    }
  }
}
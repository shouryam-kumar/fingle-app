import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/search_models.dart';
import '../services/mock_search_data.dart';
import '../services/supabase/search_service.dart';

class SearchProvider extends ChangeNotifier {
  // Search state
  String _searchQuery = '';
  SearchFilter _filter = SearchFilter();
  List<SearchResult> _searchResults = [];
  List<SearchSuggestion> _suggestions = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _hasInitialContent = false;

  // Tab state
  int _selectedTabIndex = 0;
  final List<SearchResultType> _tabs = [
    SearchResultType.all,
    SearchResultType.people,
    SearchResultType.topics,
    SearchResultType.posts,
    SearchResultType.communities,
    SearchResultType.trending,
    SearchResultType.saved,
  ];

  // Enhanced tab state
  List<MixedContentResult> _mixedContentResults = [];
  List<TrendingMetrics> _trendingMetrics = [];
  Map<SearchResultType, TabBadgeInfo> _tabBadges = {};
  
  // Trending suggestions
  List<String> _trendingSuggestions = [
    'fitness',
    'yoga',
    'HIIT workouts',
    'nutrition',
    'morning routine',
    'strength training',
    'meditation',
    'cardio'
  ];

  // Pagination state
  int _currentPage = 1;
  bool _hasMoreResults = true;
  bool _isLoadingMore = false;

  // Bookmarks and saved searches
  List<String> _bookmarkedResults = [];
  List<SearchResult> _savedResults = [];

  // Enhanced suggestions
  List<String> _relatedSearches = [];
  String? _didYouMeanSuggestion;

  // Popular searches analytics
  Map<String, int> _searchAnalytics = {};
  List<String> _popularSearches = [];

  // Offline caching
  Map<String, List<SearchResult>> _searchCache = {};
  Map<String, DateTime> _cacheTimestamps = {};

  // Getters
  String get searchQuery => _searchQuery;
  SearchFilter get filter => _filter;
  List<SearchResult> get searchResults => _searchResults;
  List<SearchSuggestion> get suggestions => _suggestions;
  List<String> get searchHistory => _searchHistory;
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;
  bool get hasInitialContent => _hasInitialContent;
  int get selectedTabIndex => _selectedTabIndex;
  List<SearchResultType> get tabs => _tabs;
  SearchResultType get currentTab => _tabs[_selectedTabIndex];

  // Enhanced getters
  List<MixedContentResult> get mixedContentResults => _mixedContentResults;
  List<TrendingMetrics> get trendingMetrics => _trendingMetrics;
  Map<SearchResultType, TabBadgeInfo> get tabBadges => _tabBadges;
  List<String> get trendingSuggestions => _trendingSuggestions;

  // New getters
  int get currentPage => _currentPage;
  bool get hasMoreResults => _hasMoreResults;
  bool get isLoadingMore => _isLoadingMore;
  List<String> get bookmarkedResults => _bookmarkedResults;
  List<SearchResult> get savedResults => _savedResults;
  List<String> get relatedSearches => _relatedSearches;
  String? get didYouMeanSuggestion => _didYouMeanSuggestion;
  Map<String, int> get searchAnalytics => _searchAnalytics;
  List<String> get popularSearches => _popularSearches;

  // Filtered results by current tab
  List<SearchResult> get filteredResults {
    if (_searchResults.isEmpty) return [];

    return _searchResults.where((result) {
      switch (currentTab) {
        case SearchResultType.all:
          return true; // Show all results for All tab
        case SearchResultType.people:
          return result.type == SearchResultType.people;
        case SearchResultType.topics:
          return result.type == SearchResultType.topics;
        case SearchResultType.posts:
          return result.type == SearchResultType.posts;
        case SearchResultType.communities:
          return result.type == SearchResultType.communities;
        case SearchResultType.trending:
          // Show results that have trending metrics
          return _trendingMetrics.any((metric) =>
              metric.trendingScore > 0.7 &&
              DateTime.now().difference(metric.lastUpdated).inHours < 24);
        case SearchResultType.saved:
          // Saved results don't use the regular search results
          return false;
      }
    }).toList();
  }

  // Search methods
  void updateSearchQuery(String query) {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _suggestions.clear();
      _searchResults.clear();
      _hasSearched = false;
    } else {
      _loadSuggestions();
    }

    notifyListeners();
  }

  void _loadSuggestions() async {
    try {
      // Load suggestions from Supabase
      final suggestions = await SearchService.getSearchSuggestions(
        query: _searchQuery,
        limit: 10,
      );

      if (suggestions.isNotEmpty) {
        _suggestions = suggestions;
      } else {
        // Fallback to mock data
        _suggestions = MockSearchData.getSuggestions(_searchQuery);
      }

      // Load enhanced suggestions
      await _generateDidYouMeanSuggestion();
      await _generateRelatedSearches();
    } catch (e) {
      debugPrint('Error loading suggestions: $e');
      // Fallback to mock data
      _suggestions = MockSearchData.getSuggestions(_searchQuery);
      _generateDidYouMeanSuggestion();
      _generateRelatedSearches();
    }
    notifyListeners();
  }

  // History management methods
  Future<void> loadSearchHistory() async {
    try {
      // Load from Supabase first
      final history = await SearchService.getSearchHistory(limit: 20);
      
      if (history.isNotEmpty) {
        _searchHistory = history;
      } else {
        // Fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        _searchHistory = prefs.getStringList('search_history') ?? [];
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      _searchHistory = prefs.getStringList('search_history') ?? [];
    }
    notifyListeners();
  }

  Future<void> _saveSearchHistory() async {
    try {
      // Save to Supabase
      if (_searchHistory.isNotEmpty) {
        await SearchService.saveSearchToHistory(_searchHistory.first);
      }
    } catch (e) {
      debugPrint('Error saving search history to Supabase: $e');
    }
    
    // Also save locally as backup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
  }

  void removeFromHistory(String query) async {
    _searchHistory.remove(query);
    
    try {
      // Remove from Supabase
      await SearchService.deleteSearchFromHistory(query);
    } catch (e) {
      debugPrint('Error removing search from Supabase: $e');
    }
    
    _saveSearchHistory();
    notifyListeners();
  }

  void clearHistory() async {
    _searchHistory.clear();
    
    try {
      // Clear from Supabase
      await SearchService.clearSearchHistory();
    } catch (e) {
      debugPrint('Error clearing search history from Supabase: $e');
    }
    
    _saveSearchHistory();
    notifyListeners();
  }

  Future<void> performSearch({String? query}) async {
    final searchTerm = query ?? _searchQuery;
    if (searchTerm.isEmpty) return;

    _isSearching = true;
    _hasSearched = true;
    notifyListeners();

    try {
      // Add to search history and analytics
      if (!_searchHistory.contains(searchTerm)) {
        _searchHistory.insert(0, searchTerm);
        if (_searchHistory.length > 20) {
          _searchHistory.removeLast();
        }
      }
      
      // Track search analytics
      _searchAnalytics[searchTerm] = (_searchAnalytics[searchTerm] ?? 0) + 1;
      _updatePopularSearches();
      _saveSearchHistory();

      // Reset pagination
      _currentPage = 1;
      _hasMoreResults = true;

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Check cache first
      final cacheKey = '${searchTerm}_${_filter.hashCode}';
      final cachedResults = _getCachedResults(cacheKey);
      
      if (cachedResults != null) {
        _searchResults = cachedResults;
        _suggestions.clear();
      } else {
        // Perform search via Supabase
        try {
          final searchResults = await SearchService.performSearch(
            query: searchTerm,
            filter: _filter,
            limit: 20,
            offset: 0,
          );

          if (searchResults.isNotEmpty) {
            _searchResults = searchResults;
            
            // Track search analytics
            await SearchService.trackSearchAnalytics(
              query: searchTerm,
              resultType: 'mixed',
            );
          } else {
            // Fallback to mock data
            _searchResults = MockSearchData.search(searchTerm, _filter);
          }
          
          _suggestions.clear();
          
          // Cache the results
          _cacheResults(cacheKey, _searchResults);
        } catch (e) {
          debugPrint('Error performing search via Supabase: $e');
          // Fallback to mock data
          _searchResults = MockSearchData.search(searchTerm, _filter);
          _suggestions.clear();
          _cacheResults(cacheKey, _searchResults);
        }
      }

      // Generate mixed content and trending analysis
      await _generateMixedContent();
      await _analyzeTrending();
      _updateTabBadges();
    } catch (e) {
      debugPrint('Search error: $e');
      _searchResults.clear();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void selectTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void updateFilter(SearchFilter filter) {
    _filter = filter;
    if (_hasSearched) {
      performSearch();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    _suggestions.clear();
    _hasSearched = false;
    _isSearching = false;
    _selectedTabIndex = 0;
    notifyListeners();
  }

  // Load initial trending content
  Future<void> loadInitialTrendingContent() async {
    if (_hasInitialContent) return;
    
    _isSearching = true;
    notifyListeners();
    
    try {
      // Load trending topics from Supabase
      final trendingTopics = await SearchService.getTrendingTopics(limit: 10);
      
      // Update trending suggestions based on real data
      if (trendingTopics.isNotEmpty) {
        _trendingSuggestions = trendingTopics.map((topic) => topic.name).toList();
      }
      
      // Load popular searches to populate initial content
      final popularSearches = await SearchService.getPopularSearches(limit: 5);
      
      String initialQuery = 'fitness'; // Default fallback
      if (popularSearches.isNotEmpty) {
        initialQuery = popularSearches.first;
      }
      
      // Perform a search with most popular or trending term
      await performSearch(query: initialQuery);
      _hasInitialContent = true;
    } catch (e) {
      debugPrint('Error loading initial content: $e');
      // Fallback to default search
      await performSearch(query: 'fitness');
      _hasInitialContent = true;
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void selectSuggestion(SearchSuggestion suggestion) {
    _searchQuery = suggestion.text;
    performSearch(query: suggestion.text);
  }

  // Topic actions
  void toggleTopicFollow(String topicId) {
    final resultIndex = _searchResults.indexWhere(
      (result) =>
          result.type == SearchResultType.topics && result.topic?.id == topicId,
    );

    if (resultIndex != -1) {
      final result = _searchResults[resultIndex];
      final updatedTopic = result.topic?.copyWith(
        isFollowing: !(result.topic?.isFollowing ?? false),
      );

      if (updatedTopic != null) {
        _searchResults[resultIndex] = SearchResult.topic(
          id: result.id,
          topic: updatedTopic,
          relevanceScore: result.relevanceScore,
        );
        notifyListeners();
      }
    }
  }

  // Community actions
  void toggleCommunityMembership(String communityId) {
    final resultIndex = _searchResults.indexWhere(
      (result) =>
          result.type == SearchResultType.communities &&
          result.community?.id == communityId,
    );

    if (resultIndex != -1) {
      final result = _searchResults[resultIndex];
      final updatedCommunity = result.community?.copyWith(
        isMember: !(result.community?.isMember ?? false),
      );

      if (updatedCommunity != null) {
        _searchResults[resultIndex] = SearchResult.community(
          id: result.id,
          community: updatedCommunity,
          relevanceScore: result.relevanceScore,
        );
        notifyListeners();
      }
    }
  }

  // User actions
  void toggleUserFollow(String userId) {
    final resultIndex = _searchResults.indexWhere(
      (result) =>
          result.type == SearchResultType.people && result.user?.id == userId,
    );

    if (resultIndex != -1) {
      final result = _searchResults[resultIndex];
      final updatedUser = result.user?.copyWith(
        isFollowing: !(result.user?.isFollowing ?? false),
      );

      if (updatedUser != null) {
        _searchResults[resultIndex] = SearchResult.user(
          id: result.id,
          user: updatedUser,
          relevanceScore: result.relevanceScore,
        );
        notifyListeners();
      }
    }
  }

  // Get tab display name
  String getTabDisplayName(SearchResultType type) {
    switch (type) {
      case SearchResultType.all:
        return 'All';
      case SearchResultType.people:
        return 'People';
      case SearchResultType.topics:
        return 'Topics';
      case SearchResultType.posts:
        return 'Posts';
      case SearchResultType.communities:
        return 'Communities';
      case SearchResultType.trending:
        return 'Trending';
      case SearchResultType.saved:
        return 'Saved';
    }
  }

  // Get results count for each tab
  int getTabResultCount(SearchResultType type) {
    if (type == SearchResultType.all) {
      return _searchResults.length;
    }
    if (type == SearchResultType.trending) {
      return _trendingMetrics.where((m) => m.trendingScore > 0.7).length;
    }
    if (type == SearchResultType.saved) {
      return _savedResults.length;
    }
    return _searchResults.where((result) => result.type == type).length;
  }

  // Get tab icon
  IconData getTabIcon(SearchResultType type) {
    switch (type) {
      case SearchResultType.all:
        return Icons.dashboard;
      case SearchResultType.people:
        return Icons.people;
      case SearchResultType.topics:
        return Icons.tag;
      case SearchResultType.posts:
        return Icons.article;
      case SearchResultType.communities:
        return Icons.groups;
      case SearchResultType.trending:
        return Icons.trending_up;
      case SearchResultType.saved:
        return Icons.bookmark;
    }
  }

  // Mixed content algorithm for All tab
  Future<void> _generateMixedContent() async {
    _mixedContentResults.clear();

    if (_searchResults.isEmpty) return;

    // Algorithm: Mix content types based on relevance and diversity
    final List<MixedContentResult> mixed = [];

    // Group results by type
    final Map<SearchResultType, List<SearchResult>> grouped = {};
    for (final result in _searchResults) {
      grouped.putIfAbsent(result.type, () => []).add(result);
    }

    // Calculate priority scores for each result
    for (final entry in grouped.entries) {
      final type = entry.key;
      final results = entry.value;

      for (int i = 0; i < results.length; i++) {
        final result = results[i];

        // Base algorithm score considering relevance and position
        double algorithmScore = result.relevanceScore * 0.6;

        // Boost score based on content type popularity
        switch (type) {
          case SearchResultType.people:
            algorithmScore += 0.2; // People are highly engaging
            break;
          case SearchResultType.topics:
            algorithmScore += 0.15;
            break;
          case SearchResultType.posts:
            algorithmScore += 0.1;
            break;
          case SearchResultType.communities:
            algorithmScore += 0.05;
            break;
          default:
            break;
        }

        // Penalty for lower positions within type
        algorithmScore -= (i * 0.02);

        // Boost for certain criteria
        String displayReason = 'High relevance';
        if (result.user?.openToMingle == true) {
          algorithmScore += 0.1;
          displayReason = 'Open to Mingle';
        }
        if (result.topic?.isTrending == true) {
          algorithmScore += 0.15;
          displayReason = 'Trending topic';
        }

        mixed.add(MixedContentResult(
          result: result,
          algorithmScore: algorithmScore,
          displayReason: displayReason,
          priority: (algorithmScore * 100).round(),
        ));
      }
    }

    // Sort by algorithm score and take top results
    mixed.sort((a, b) => b.algorithmScore.compareTo(a.algorithmScore));
    _mixedContentResults = mixed.take(20).toList(); // Limit to top 20
  }

  // Trending analysis algorithm
  Future<void> _analyzeTrending() async {
    _trendingMetrics.clear();

    final now = DateTime.now();

    // Generate trending metrics for results
    for (final result in _searchResults) {
      double trendingScore = 0.0;
      int engagementRate = 0;
      int recentActivity = 0;
      String reason = '';

      // Calculate trending based on content type
      switch (result.type) {
        case SearchResultType.topics:
          if (result.topic != null) {
            final topic = result.topic!;
            trendingScore =
                (topic.analytics.postsLast24h / 100.0).clamp(0.0, 1.0);
            engagementRate = topic.analytics.activeUsers;
            recentActivity = topic.analytics.postsLast24h;
            reason = 'High activity in last 24h';

            if (topic.isTrending) {
              trendingScore += 0.3;
              reason = 'Marked as trending';
            }
          }
          break;

        case SearchResultType.people:
          if (result.user != null) {
            final user = result.user!;
            // Simulate engagement based on followers and activity
            trendingScore = (user.followers / 10000.0).clamp(0.0, 0.8);
            engagementRate = (user.stats.totalPosts * 2);
            recentActivity = user.stats.totalPosts; // Simulate recent posts
            reason = 'Active user with high engagement';

            if (user.openToMingle) {
              trendingScore += 0.2;
              reason = 'Open to Mingle and active';
            }
          }
          break;

        case SearchResultType.communities:
          if (result.community != null) {
            final community = result.community!;
            trendingScore = (community.postsToday / 50.0).clamp(0.0, 1.0);
            engagementRate = community.memberCount;
            recentActivity = community.postsToday;
            reason = 'Active community with recent posts';
          }
          break;

        case SearchResultType.posts:
          // Simulate post engagement metrics
          trendingScore = (result.relevanceScore * 0.8).clamp(0.0, 1.0);
          engagementRate = (result.relevanceScore * 100).round();
          recentActivity = (result.relevanceScore * 50).round();
          reason = 'High engagement content';
          break;
        default:
          continue;
      }

      if (trendingScore > 0.3) {
        _trendingMetrics.add(TrendingMetrics(
          trendingScore: trendingScore,
          engagementRate: engagementRate,
          recentActivity: recentActivity,
          lastUpdated: now,
          trendingReason: reason,
        ));
      }
    }

    // Sort by trending score
    _trendingMetrics.sort((a, b) => b.trendingScore.compareTo(a.trendingScore));
  }

  // Update tab badges with counts and indicators
  void _updateTabBadges() {
    _tabBadges.clear();

    for (final tab in _tabs) {
      final count = getTabResultCount(tab);
      bool hasTrending = false;
      bool hasNewContent = false;
      int newContentCount = 0;
      ActivityLevel? activityLevel;

      // Check for trending content
      if (tab == SearchResultType.trending) {
        hasTrending = _trendingMetrics.isNotEmpty;
        activityLevel = _trendingMetrics.isNotEmpty
            ? ActivityLevel.veryActive
            : ActivityLevel.moderate;
      } else if (tab == SearchResultType.all) {
        hasTrending = _trendingMetrics.length > 3;
        hasNewContent = true;
        newContentCount = _searchResults.length;
        activityLevel = _searchResults.length > 10
            ? ActivityLevel.veryActive
            : ActivityLevel.active;
      } else {
        // Check if this tab type has trending items
        final typeResults = _searchResults.where((r) => r.type == tab).toList();
        hasTrending = typeResults.any((result) {
          switch (tab) {
            case SearchResultType.topics:
              return result.topic?.isTrending == true;
            case SearchResultType.people:
              return result.user?.openToMingle == true;
            default:
              return false;
          }
        });

        hasNewContent = typeResults.isNotEmpty;
        newContentCount = typeResults.length;

        // Set activity level based on count
        if (typeResults.length > 5) {
          activityLevel = ActivityLevel.veryActive;
        } else if (typeResults.length > 2) {
          activityLevel = ActivityLevel.active;
        } else {
          activityLevel = ActivityLevel.moderate;
        }
      }

      _tabBadges[tab] = TabBadgeInfo(
        resultCount: count,
        hasTrending: hasTrending,
        hasNewContent: hasNewContent,
        newContentCount: newContentCount,
        activityLevel: activityLevel,
      );
    }
  }

  // Pagination methods
  Future<void> loadMoreResults() async {
    if (!_hasMoreResults || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Simulate loading more results
      final moreResults = MockSearchData.search(_searchQuery, _filter, page: _currentPage + 1);
      
      if (moreResults.isNotEmpty) {
        _searchResults.addAll(moreResults);
        _currentPage++;
        
        // Simulate no more results after page 3
        if (_currentPage >= 3) {
          _hasMoreResults = false;
        }
      } else {
        _hasMoreResults = false;
      }
    } catch (e) {
      debugPrint('Error loading more results: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Bookmark methods
  void toggleBookmark(String resultId) {
    if (_bookmarkedResults.contains(resultId)) {
      _bookmarkedResults.remove(resultId);
      _savedResults.removeWhere((result) => result.id == resultId);
    } else {
      _bookmarkedResults.add(resultId);
      final result = _searchResults.firstWhere((r) => r.id == resultId);
      _savedResults.add(result);
    }
    _saveBookmarks();
    notifyListeners();
  }

  bool isBookmarked(String resultId) {
    return _bookmarkedResults.contains(resultId);
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarked_results', _bookmarkedResults);
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarkedResults = prefs.getStringList('bookmarked_results') ?? [];
    notifyListeners();
  }

  // Enhanced suggestions methods
  Future<void> _generateDidYouMeanSuggestion() async {
    if (_searchQuery.length < 3) {
      _didYouMeanSuggestion = null;
      return;
    }

    try {
      // Get suggestion from Supabase
      final suggestion = await SearchService.getDidYouMeanSuggestion(_searchQuery);
      _didYouMeanSuggestion = suggestion;
    } catch (e) {
      debugPrint('Error getting did you mean suggestion: $e');
      
      // Fallback to local suggestions
      final suggestions = [
        {'yoga' : 'yoga'},
        {'fittness': 'fitness'},
        {'nutrtion': 'nutrition'},
        {'excersize': 'exercise'},
        {'meditaion': 'meditation'},
      ];

      for (final suggestion in suggestions) {
        final typo = suggestion.keys.first;
        final correction = suggestion.values.first;
        if (_searchQuery.toLowerCase().contains(typo)) {
          _didYouMeanSuggestion = _searchQuery.toLowerCase().replaceAll(typo, correction);
          return;
        }
      }

      _didYouMeanSuggestion = null;
    }
  }

  Future<void> _generateRelatedSearches() async {
    try {
      // Get related searches from Supabase
      final related = await SearchService.getRelatedSearches(_searchQuery, limit: 4);
      
      if (related.isNotEmpty) {
        _relatedSearches = related;
        return;
      }
    } catch (e) {
      debugPrint('Error getting related searches: $e');
    }
    
    // Fallback to local related searches
    final related = <String>[];
    final query = _searchQuery.toLowerCase();

    if (query.contains('fitness') || query.contains('workout')) {
      related.addAll(['strength training', 'cardio', 'HIIT workouts', 'home workout']);
    } else if (query.contains('yoga')) {
      related.addAll(['meditation', 'pilates', 'stretching', 'mindfulness']);
    } else if (query.contains('nutrition')) {
      related.addAll(['healthy eating', 'meal prep', 'protein', 'vitamins']);
    } else if (query.contains('running')) {
      related.addAll(['marathon training', 'jogging', 'sprints', 'cardio']);
    } else {
      // Default related searches
      related.addAll(['fitness', 'wellness', 'health tips', 'exercise']);
    }

    _relatedSearches = related.take(4).toList();
  }

  void _updatePopularSearches() async {
    try {
      // Get popular searches from Supabase
      final popularSearches = await SearchService.getPopularSearches(limit: 10);
      
      if (popularSearches.isNotEmpty) {
        _popularSearches = popularSearches;
        return;
      }
    } catch (e) {
      debugPrint('Error getting popular searches: $e');
    }
    
    // Fallback to local analytics
    final sortedEntries = _searchAnalytics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    _popularSearches = sortedEntries
        .take(10)
        .map((entry) => entry.key)
        .toList();
  }

  // Cache management methods
  List<SearchResult>? _getCachedResults(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return null;
    
    // Cache expires after 10 minutes
    final cacheExpiry = timestamp.add(const Duration(minutes: 10));
    if (DateTime.now().isAfter(cacheExpiry)) {
      _searchCache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
      return null;
    }
    
    return _searchCache[cacheKey];
  }

  void _cacheResults(String cacheKey, List<SearchResult> results) {
    _searchCache[cacheKey] = List.from(results);
    _cacheTimestamps[cacheKey] = DateTime.now();
    
    // Limit cache size to 50 entries
    if (_searchCache.length > 50) {
      final oldestKey = _cacheTimestamps.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      _searchCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }
  }

  void clearCache() {
    _searchCache.clear();
    _cacheTimestamps.clear();
  }

  int get cacheSize => _searchCache.length;
  
  bool isCached(String query) {
    final cacheKey = '${query}_${_filter.hashCode}';
    return _getCachedResults(cacheKey) != null;
  }

  // Initialize provider
  Future<void> initialize() async {
    await loadSearchHistory();
    await loadBookmarks();
  }
}

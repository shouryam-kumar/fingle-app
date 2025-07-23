import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/search_models.dart';
import '../services/mock_search_data.dart';

class SearchProvider extends ChangeNotifier {
  // Search state
  String _searchQuery = '';
  SearchFilter _filter = SearchFilter();
  List<SearchResult> _searchResults = [];
  List<SearchSuggestion> _suggestions = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  // Tab state
  int _selectedTabIndex = 0;
  final List<SearchResultType> _tabs = [
    SearchResultType.all,
    SearchResultType.people,
    SearchResultType.topics,
    SearchResultType.posts,
    SearchResultType.communities,
    SearchResultType.trending,
  ];
  
  // Enhanced tab state
  List<MixedContentResult> _mixedContentResults = [];
  List<TrendingMetrics> _trendingMetrics = [];
  Map<SearchResultType, TabBadgeInfo> _tabBadges = {};

  // Getters
  String get searchQuery => _searchQuery;
  SearchFilter get filter => _filter;
  List<SearchResult> get searchResults => _searchResults;
  List<SearchSuggestion> get suggestions => _suggestions;
  List<String> get searchHistory => _searchHistory;
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;
  int get selectedTabIndex => _selectedTabIndex;
  List<SearchResultType> get tabs => _tabs;
  SearchResultType get currentTab => _tabs[_selectedTabIndex];
  
  // Enhanced getters
  List<MixedContentResult> get mixedContentResults => _mixedContentResults;
  List<TrendingMetrics> get trendingMetrics => _trendingMetrics;
  Map<SearchResultType, TabBadgeInfo> get tabBadges => _tabBadges;

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
            DateTime.now().difference(metric.lastUpdated).inHours < 24
          );
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

  void _loadSuggestions() {
    _suggestions = MockSearchData.getSuggestions(_searchQuery);
    notifyListeners();
  }

  Future<void> performSearch({String? query}) async {
    final searchTerm = query ?? _searchQuery;
    if (searchTerm.isEmpty) return;

    _isSearching = true;
    _hasSearched = true;
    notifyListeners();

    try {
      // Add to search history
      if (!_searchHistory.contains(searchTerm)) {
        _searchHistory.insert(0, searchTerm);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Perform search
      _searchResults = MockSearchData.search(searchTerm, _filter);
      _suggestions.clear();
      
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

  void selectSuggestion(SearchSuggestion suggestion) {
    _searchQuery = suggestion.text;
    performSearch(query: suggestion.text);
  }

  // Topic actions
  void toggleTopicFollow(String topicId) {
    final resultIndex = _searchResults.indexWhere(
      (result) => result.type == SearchResultType.topics && result.topic?.id == topicId,
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
      (result) => result.type == SearchResultType.communities && result.community?.id == communityId,
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
      (result) => result.type == SearchResultType.people && result.user?.id == userId,
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
            trendingScore = (topic.analytics.postsLast24h / 100.0).clamp(0.0, 1.0);
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
        activityLevel = _trendingMetrics.isNotEmpty ? ActivityLevel.veryActive : ActivityLevel.moderate;
      } else if (tab == SearchResultType.all) {
        hasTrending = _trendingMetrics.length > 3;
        hasNewContent = true;
        newContentCount = _searchResults.length;
        activityLevel = _searchResults.length > 10 ? ActivityLevel.veryActive : ActivityLevel.active;
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
}
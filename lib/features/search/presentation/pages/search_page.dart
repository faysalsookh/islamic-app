import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/models/bookmark.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/search_service.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SearchService _searchService = SearchService();
  late TabController _tabController;

  String _searchQuery = '';
  List<Surah> _surahResults = [];
  List<Bookmark> _bookmarkResults = [];
  List<AyahSearchResult> _ayahResults = [];
  bool _isSearching = false;
  bool _isSearchingAyahs = false;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchFocusNode.requestFocus();
    _loadRecentSearches();
    _initializeSearchService();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _initializeSearchService() {
    // Initialize cache in background
    _searchService.initializeCache();
  }

  void _loadRecentSearches() {
    // In a real app, load from SharedPreferences
    _recentSearches = ['Al-Fatihah', 'Ayat Al-Kursi', 'Surah Yasin', 'mercy', 'prayer'];
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchQuery = '';
        _surahResults = [];
        _bookmarkResults = [];
        _ayahResults = [];
        _isSearching = false;
        _isSearchingAyahs = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchingAyahs = true;
      _searchQuery = query;
    });

    // Search surahs and bookmarks (fast, synchronous)
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;

      final surahResults = _searchService.searchSurahs(query);
      final appState = context.read<AppStateProvider>();
      final bookmarkResults = _searchService.searchBookmarks(query, appState.bookmarks);

      setState(() {
        _surahResults = surahResults;
        _bookmarkResults = bookmarkResults;
        _isSearching = false;
      });
    });

    // Search ayahs (may take longer)
    _searchAyahs(query);
  }

  Future<void> _searchAyahs(String query) async {
    if (query.length < 2) {
      setState(() {
        _ayahResults = [];
        _isSearchingAyahs = false;
      });
      return;
    }

    try {
      // First, try quick search in cached surahs
      final quickResults = _searchService.quickSearchAyahs(query, maxResults: 10);

      if (mounted) {
        setState(() {
          _ayahResults = quickResults;
        });
      }

      // Then perform full search if query is 3+ chars
      if (query.length >= 3) {
        final fullResults = await _searchService.searchAyahs(
          query,
          maxResults: 30,
          surahsToSearch: [1, 2, 3, 18, 36, 55, 56, 67, 78, 112, 113, 114], // Popular surahs first
        );

        if (mounted && _searchQuery == query) {
          setState(() {
            _ayahResults = fullResults;
            _isSearchingAyahs = false;
          });
        }
      } else {
        setState(() {
          _isSearchingAyahs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearchingAyahs = false;
        });
      }
    }
  }

  void _addToRecentSearches(String query) {
    if (query.isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
    // In a real app, save to SharedPreferences
  }

  void _navigateToSurah(Surah surah) {
    HapticService().lightImpact();
    _addToRecentSearches(surah.nameTransliteration);
    Navigator.pushNamed(context, '/quran-reader', arguments: surah.number);
  }

  void _navigateToBookmark(Bookmark bookmark) {
    HapticService().lightImpact();
    Navigator.pushNamed(
      context,
      '/quran-reader',
      arguments: {
        'surahNumber': bookmark.surahNumber,
        'ayahNumber': bookmark.ayahNumber,
      },
    );
  }

  void _navigateToAyah(AyahSearchResult result) {
    HapticService().lightImpact();
    _addToRecentSearches(_searchQuery);
    Navigator.pushNamed(
      context,
      '/quran-reader',
      arguments: {
        'surahNumber': result.surah.number,
        'ayahNumber': result.ayah.numberInSurah,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(isDark),

            // Tab Bar
            if (_searchQuery.isNotEmpty) _buildTabBar(isDark),

            // Content
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildRecentSearches(isDark)
                  : _buildSearchResults(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.cardShadow.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () {
              HapticService().lightImpact();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),

          // Search Field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _performSearch,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search surahs, verses, translations...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                    size: 22,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            HapticService().selectionClick();
                            _searchController.clear();
                            _performSearch('');
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                            size: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    final totalResults = _surahResults.length + _bookmarkResults.length + _ayahResults.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => HapticService().selectionClick(),
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 3,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('All'),
                const SizedBox(width: 4),
                _buildBadge(totalResults, isDark),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Surahs'),
                const SizedBox(width: 4),
                _buildBadge(_surahResults.length, isDark),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.format_quote_rounded, size: 16),
                const SizedBox(width: 4),
                const Text('Verses'),
                const SizedBox(width: 4),
                _isSearchingAyahs
                    ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : _buildBadge(_ayahResults.length, isDark),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bookmarks'),
                const SizedBox(width: 4),
                _buildBadge(_bookmarkResults.length, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(int count, bool isDark) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildRecentSearches(bool isDark) {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Search the Quran',
              style: AppTypography.heading3(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find surahs, verses, translations & bookmarks',
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Search tips
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search tips:',
                    style: AppTypography.label(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSearchTip('Search by surah name (Arabic or English)', isDark),
                  _buildSearchTip('Search within translations', isDark),
                  _buildSearchTip('Search by transliteration', isDark),
                  _buildSearchTip('Find saved bookmarks', isDark),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTypography.heading4(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticService().lightImpact();
                  setState(() {
                    _recentSearches.clear();
                  });
                },
                child: Text(
                  'Clear',
                  style: AppTypography.bodySmall(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return ActionChip(
                avatar: Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                ),
                label: Text(search),
                onPressed: () {
                  HapticService().selectionClick();
                  _searchController.text = search;
                  _performSearch(search);
                },
                backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                side: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
                labelStyle: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTip(String tip, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    if (_isSearching) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16),
        child: const SearchResultSkeleton(itemCount: 6),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllResults(isDark),
        _buildSurahResults(isDark),
        _buildAyahResults(isDark),
        _buildBookmarkResults(isDark),
      ],
    );
  }

  Widget _buildAllResults(bool isDark) {
    if (_surahResults.isEmpty && _bookmarkResults.isEmpty && _ayahResults.isEmpty && !_isSearchingAyahs) {
      return _buildNoResults(isDark);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (_surahResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Surahs',
              style: AppTypography.label(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          ...(_surahResults.take(3).map((surah) => _buildSurahTile(surah, isDark))),
          if (_surahResults.length > 3)
            TextButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              child: Text('View all ${_surahResults.length} surahs'),
            ),
        ],
        if (_ayahResults.isNotEmpty || _isSearchingAyahs) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Verses',
                  style: AppTypography.label(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                if (_isSearchingAyahs) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...(_ayahResults.take(3).map((result) => _buildAyahTile(result, isDark))),
          if (_ayahResults.length > 3)
            TextButton(
              onPressed: () {
                _tabController.animateTo(2);
              },
              child: Text('View all ${_ayahResults.length} verses'),
            ),
        ],
        if (_bookmarkResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Bookmarks',
              style: AppTypography.label(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          ...(_bookmarkResults.take(2).map((bookmark) => _buildBookmarkTile(bookmark, isDark))),
          if (_bookmarkResults.length > 2)
            TextButton(
              onPressed: () {
                _tabController.animateTo(3);
              },
              child: Text('View all ${_bookmarkResults.length} bookmarks'),
            ),
        ],
      ],
    );
  }

  Widget _buildSurahResults(bool isDark) {
    if (_surahResults.isEmpty) {
      return _buildNoResults(isDark, message: 'No surahs found');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _surahResults.length,
      itemBuilder: (context, index) => _buildSurahTile(_surahResults[index], isDark),
    );
  }

  Widget _buildAyahResults(bool isDark) {
    if (_isSearchingAyahs && _ayahResults.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16),
        child: const SearchResultSkeleton(itemCount: 5),
      );
    }

    if (_ayahResults.isEmpty) {
      return _buildNoResults(
        isDark,
        message: _searchQuery.length < 2
            ? 'Type at least 2 characters'
            : 'No verses found',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _ayahResults.length + (_isSearchingAyahs ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _ayahResults.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Searching more surahs...',
                    style: AppTypography.bodySmall(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildAyahTile(_ayahResults[index], isDark);
      },
    );
  }

  Widget _buildBookmarkResults(bool isDark) {
    if (_bookmarkResults.isEmpty) {
      return _buildNoResults(isDark, message: 'No bookmarks found');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _bookmarkResults.length,
      itemBuilder: (context, index) => _buildBookmarkTile(_bookmarkResults[index], isDark),
    );
  }

  Widget _buildSurahTile(Surah surah, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToSurah(surah),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Surah Number
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    surah.number.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Surah Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.nameTransliteration,
                      style: AppTypography.bodyLarge(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${surah.nameEnglish} • ${surah.ayahCount} Ayahs',
                      style: AppTypography.bodySmall(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Arabic Name
              Text(
                surah.nameArabic,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Amiri',
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAyahTile(AyahSearchResult result, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToAyah(result),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Surah & Ayah info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${result.surah.nameTransliteration} ${result.ayah.numberInSurah}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Match type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getMatchTypeColor(result.matchType).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      result.matchType.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _getMatchTypeColor(result.matchType),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Matched text with highlighting
              _buildHighlightedText(result.matchedText, _searchQuery, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMatchTypeColor(SearchMatchType type) {
    switch (type) {
      case SearchMatchType.arabic:
        return AppColors.forestGreen;
      case SearchMatchType.translationEnglish:
        return AppColors.mutedTeal;
      case SearchMatchType.translationBengali:
        return AppColors.softRoseDark;
      case SearchMatchType.transliterationEnglish:
      case SearchMatchType.transliterationBengali:
        return AppColors.oliveGreen;
    }
  }

  Widget _buildHighlightedText(String text, String query, bool isDark) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(
        text,
        style: AppTypography.bodyMedium(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final before = text.substring(0, matchIndex);
    final match = text.substring(matchIndex, matchIndex + query.length);
    final after = text.substring(matchIndex + query.length);

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppTypography.bodyMedium(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: TextStyle(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }

  Widget _buildBookmarkTile(Bookmark bookmark, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToBookmark(bookmark),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Bookmark Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.softRose.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.softRoseDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Bookmark Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bookmark.surahNameEnglish}, Ayah ${bookmark.ayahNumber}',
                      style: AppTypography.bodyLarge(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (bookmark.note != null && bookmark.note!.isNotEmpty)
                      Text(
                        bookmark.note!,
                        style: AppTypography.bodySmall(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bookmark.label ?? 'Saved',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults(bool isDark, {String message = 'No results found'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTypography.bodyLarge(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term',
            style: AppTypography.bodySmall(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

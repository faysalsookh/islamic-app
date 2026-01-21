import 'package:flutter/foundation.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/bookmark.dart';
import 'quran_data_service.dart';

/// Model for ayah search results
class AyahSearchResult {
  final Ayah ayah;
  final Surah surah;
  final String matchedText;
  final SearchMatchType matchType;

  const AyahSearchResult({
    required this.ayah,
    required this.surah,
    required this.matchedText,
    required this.matchType,
  });
}

/// Type of match found in search
enum SearchMatchType {
  arabic,
  translationEnglish,
  translationBengali,
  transliterationEnglish,
  transliterationBengali,
}

extension SearchMatchTypeExtension on SearchMatchType {
  String get displayName {
    switch (this) {
      case SearchMatchType.arabic:
        return 'Arabic';
      case SearchMatchType.translationEnglish:
        return 'English';
      case SearchMatchType.translationBengali:
        return 'Bengali';
      case SearchMatchType.transliterationEnglish:
        return 'Transliteration';
      case SearchMatchType.transliterationBengali:
        return 'Transliteration (BN)';
    }
  }
}

/// Service for searching Quran content
class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final QuranDataService _quranDataService = QuranDataService();

  // Cache of loaded surahs for searching
  final Map<int, List<Ayah>> _searchCache = {};
  bool _isInitialized = false;

  /// Initialize search cache with commonly accessed surahs
  Future<void> initializeCache() async {
    if (_isInitialized) return;

    // Pre-load popular surahs for faster search
    final popularSurahs = [1, 2, 18, 36, 55, 56, 67, 112, 113, 114];
    for (final surahNum in popularSurahs) {
      try {
        final ayahs = await _quranDataService.getAyahsForSurah(surahNum);
        _searchCache[surahNum] = ayahs;
      } catch (e) {
        debugPrint('Failed to cache surah $surahNum: $e');
      }
    }
    _isInitialized = true;
  }

  /// Search for surahs by name
  List<Surah> searchSurahs(String query) {
    if (query.isEmpty) return [];
    return SurahData.searchSurahs(query);
  }

  /// Search for bookmarks
  List<Bookmark> searchBookmarks(String query, List<Bookmark> bookmarks) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();

    return bookmarks.where((b) =>
      b.surahNameEnglish.toLowerCase().contains(lowerQuery) ||
      b.surahNameArabic.contains(query) ||
      (b.note?.toLowerCase().contains(lowerQuery) ?? false) ||
      (b.label?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  /// Search within ayah content (Arabic, translations, transliterations)
  /// This performs a search across loaded/cached surahs
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int maxResults = 50,
    List<int>? surahsToSearch,
  }) async {
    if (query.isEmpty || query.length < 2) return [];

    final results = <AyahSearchResult>[];
    final lowerQuery = query.toLowerCase();

    // Determine which surahs to search
    final surahNumbers = surahsToSearch ?? List.generate(114, (i) => i + 1);

    for (final surahNum in surahNumbers) {
      if (results.length >= maxResults) break;

      List<Ayah>? ayahs;

      // Try cache first
      if (_searchCache.containsKey(surahNum)) {
        ayahs = _searchCache[surahNum];
      } else {
        // Try to load from QuranDataService (which has its own cache)
        try {
          ayahs = await _quranDataService.getAyahsForSurah(surahNum);
          _searchCache[surahNum] = ayahs;
        } catch (e) {
          continue; // Skip this surah if we can't load it
        }
      }

      if (ayahs == null) continue;

      final surah = SurahData.getSurahByNumber(surahNum);
      if (surah == null) continue;

      for (final ayah in ayahs) {
        if (results.length >= maxResults) break;

        // Search in Arabic text
        if (ayah.textArabic.contains(query)) {
          results.add(AyahSearchResult(
            ayah: ayah,
            surah: surah,
            matchedText: _extractMatchContext(ayah.textArabic, query),
            matchType: SearchMatchType.arabic,
          ));
          continue; // Only add one result per ayah
        }

        // Search in English translation
        if (ayah.translationEnglish?.toLowerCase().contains(lowerQuery) ?? false) {
          results.add(AyahSearchResult(
            ayah: ayah,
            surah: surah,
            matchedText: _extractMatchContext(ayah.translationEnglish!, query),
            matchType: SearchMatchType.translationEnglish,
          ));
          continue;
        }

        // Search in Bengali translation
        if (ayah.translationBengali?.toLowerCase().contains(lowerQuery) ?? false) {
          results.add(AyahSearchResult(
            ayah: ayah,
            surah: surah,
            matchedText: _extractMatchContext(ayah.translationBengali!, query),
            matchType: SearchMatchType.translationBengali,
          ));
          continue;
        }

        // Search in English transliteration
        if (ayah.transliterationEnglish?.toLowerCase().contains(lowerQuery) ?? false) {
          results.add(AyahSearchResult(
            ayah: ayah,
            surah: surah,
            matchedText: _extractMatchContext(ayah.transliterationEnglish!, query),
            matchType: SearchMatchType.transliterationEnglish,
          ));
          continue;
        }

        // Search in Bengali transliteration
        if (ayah.transliterationBengali?.toLowerCase().contains(lowerQuery) ?? false) {
          results.add(AyahSearchResult(
            ayah: ayah,
            surah: surah,
            matchedText: _extractMatchContext(ayah.transliterationBengali!, query),
            matchType: SearchMatchType.transliterationBengali,
          ));
          continue;
        }
      }
    }

    return results;
  }

  /// Extract context around the matched text
  String _extractMatchContext(String text, String query, {int contextLength = 60}) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) return text.length > contextLength * 2
        ? '${text.substring(0, contextLength * 2)}...'
        : text;

    // Calculate start and end indices for context
    int start = matchIndex - contextLength;
    int end = matchIndex + query.length + contextLength;

    // Adjust bounds
    if (start < 0) start = 0;
    if (end > text.length) end = text.length;

    // Build context string
    String result = text.substring(start, end);

    // Add ellipsis if truncated
    if (start > 0) result = '...$result';
    if (end < text.length) result = '$result...';

    return result;
  }

  /// Quick search that only searches in cached/pre-loaded surahs
  List<AyahSearchResult> quickSearchAyahs(String query, {int maxResults = 20}) {
    if (query.isEmpty || query.length < 2) return [];

    final results = <AyahSearchResult>[];
    final lowerQuery = query.toLowerCase();

    for (final entry in _searchCache.entries) {
      if (results.length >= maxResults) break;

      final surahNum = entry.key;
      final ayahs = entry.value;
      final surah = SurahData.getSurahByNumber(surahNum);
      if (surah == null) continue;

      for (final ayah in ayahs) {
        if (results.length >= maxResults) break;

        // Search in Arabic text
        if (ayah.textArabic.contains(query)) {
          results.add(AyahSearchResult(
            ayah: ayah,
            surah: surah,
            matchedText: _extractMatchContext(ayah.textArabic, query),
            matchType: SearchMatchType.arabic,
          ));
          continue;
        }

        // Search in translations
        if (ayah.translationEnglish?.toLowerCase().contains(lowerQuery) ?? false) {
          results.add(AyahSearchResult(
            ayah: ayah,
            surah: surah,
            matchedText: _extractMatchContext(ayah.translationEnglish!, query),
            matchType: SearchMatchType.translationEnglish,
          ));
          continue;
        }

        if (ayah.translationBengali?.toLowerCase().contains(lowerQuery) ?? false) {
          results.add(AyahSearchResult(
            ayah: ayah,
            surah: surah,
            matchedText: _extractMatchContext(ayah.translationBengali!, query),
            matchType: SearchMatchType.translationBengali,
          ));
          continue;
        }
      }
    }

    return results;
  }

  /// Clear search cache
  void clearCache() {
    _searchCache.clear();
    _isInitialized = false;
  }

  /// Get number of cached surahs
  int get cachedSurahCount => _searchCache.length;
}

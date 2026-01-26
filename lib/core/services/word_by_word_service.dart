import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/quran_word.dart';

/// Service to fetch word-by-word translation data from Quran.com API
class WordByWordService {
  static const String _baseUrl = 'https://api.quran.com/api/v4';

  // Cache for word data to avoid repeated API calls
  final Map<String, VerseWordsResponse> _cache = {};

  // Singleton pattern
  static final WordByWordService _instance = WordByWordService._internal();
  factory WordByWordService() => _instance;
  WordByWordService._internal();

  /// Get words for a specific verse with both English and Bengali translations
  /// [surahNumber] - Surah number (1-114)
  /// [ayahNumber] - Ayah number within the surah
  Future<VerseWordsResponse?> getWordsForVerse(int surahNumber, int ayahNumber) async {
    final verseKey = '$surahNumber:$ayahNumber';

    // Check cache first
    if (_cache.containsKey(verseKey)) {
      return _cache[verseKey];
    }

    try {
      // Fetch both English and Bengali translations in parallel
      final englishUrl = Uri.parse(
        '$_baseUrl/verses/by_key/$verseKey?language=en&words=true&word_fields=text_uthmani,text_imlaei&word_translation_language=en',
      );
      final bengaliUrl = Uri.parse(
        '$_baseUrl/verses/by_key/$verseKey?language=bn&words=true&word_fields=text_uthmani,text_imlaei&word_translation_language=bn',
      );

      debugPrint('Fetching word-by-word (EN): $englishUrl');
      debugPrint('Fetching word-by-word (BN): $bengaliUrl');

      // Fetch both in parallel for better performance
      final responses = await Future.wait([
        http.get(englishUrl, headers: {'Accept': 'application/json'}),
        http.get(bengaliUrl, headers: {'Accept': 'application/json'}),
      ]);

      final englishResponse = responses[0];
      final bengaliResponse = responses[1];

      debugPrint('English response status: ${englishResponse.statusCode}');
      debugPrint('Bengali response status: ${bengaliResponse.statusCode}');

      if (englishResponse.statusCode == 200) {
        final englishData = json.decode(englishResponse.body) as Map<String, dynamic>;
        final englishVerse = englishData['verse'] as Map<String, dynamic>?;

        Map<String, dynamic>? bengaliVerse;
        if (bengaliResponse.statusCode == 200) {
          final bengaliData = json.decode(bengaliResponse.body) as Map<String, dynamic>;
          bengaliVerse = bengaliData['verse'] as Map<String, dynamic>?;
        }

        if (englishVerse != null && englishVerse['words'] != null) {
          final englishWords = englishVerse['words'] as List<dynamic>;
          List<dynamic>? bengaliWords;

          if (bengaliVerse != null && bengaliVerse['words'] != null) {
            bengaliWords = bengaliVerse['words'] as List<dynamic>;
          }

          debugPrint('English words found: ${englishWords.length}');
          debugPrint('Bengali words found: ${bengaliWords?.length ?? 0}');

          // Merge English and Bengali translations
          final wordsResponse = VerseWordsResponse.fromJsonWithDualLanguage(
            englishWords,
            bengaliWords,
            verseKey,
          );
          _cache[verseKey] = wordsResponse;
          return wordsResponse;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching word-by-word data: $e');
      return null;
    }
  }

  /// Get detailed word information including grammar
  /// Uses the corpus.quran.com style data if available
  Future<QuranWord?> getWordDetails(int surahNumber, int ayahNumber, int wordPosition) async {
    final wordsResponse = await getWordsForVerse(surahNumber, ayahNumber);
    if (wordsResponse == null) return null;

    final words = wordsResponse.words.where((w) => w.isWord).toList();
    if (wordPosition > 0 && wordPosition <= words.length) {
      return words[wordPosition - 1];
    }
    return null;
  }

  /// Preload words for a surah (background loading)
  Future<void> preloadSurah(int surahNumber, int totalAyahs) async {
    for (int i = 1; i <= totalAyahs; i++) {
      await getWordsForVerse(surahNumber, i);
      // Small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }

  /// Get cache size
  int get cacheSize => _cache.length;
}

/// Extension to parse Arabic roots
extension ArabicRootExtension on String {
  /// Convert root letters to spaced format (ك ت ب)
  String get spacedRoot {
    return split('').join(' ');
  }
}

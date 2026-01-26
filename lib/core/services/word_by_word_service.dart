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

  /// Get words for a specific verse
  /// [surahNumber] - Surah number (1-114)
  /// [ayahNumber] - Ayah number within the surah
  Future<VerseWordsResponse?> getWordsForVerse(int surahNumber, int ayahNumber) async {
    final verseKey = '$surahNumber:$ayahNumber';

    // Check cache first
    if (_cache.containsKey(verseKey)) {
      return _cache[verseKey];
    }

    try {
      // Fetch from Quran.com API with word translations
      // word_fields: text_uthmani (Arabic text), text_imlaei (simple text)
      // Include transliteration and translation
      final url = Uri.parse(
        '$_baseUrl/verses/by_key/$verseKey?language=en&words=true&word_fields=text_uthmani,text_imlaei&word_translation_language=en',
      );

      debugPrint('Fetching word-by-word: $url');

      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final verse = data['verse'] as Map<String, dynamic>?;

        if (verse != null && verse['words'] != null) {
          debugPrint('Words found: ${(verse['words'] as List).length}');
          final wordsResponse = VerseWordsResponse.fromJson(verse, verseKey);
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

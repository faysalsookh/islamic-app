import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for fetching and converting Quran transliterations
/// Fetches English transliteration from API and converts to Bengali script
///
/// API Source: Al-Quran Cloud API (en.transliteration)
class TransliterationService {
  static final TransliterationService _instance = TransliterationService._internal();
  factory TransliterationService() => _instance;
  TransliterationService._internal();

  // Cache for transliterations
  final Map<String, String> _bengaliCache = {};
  final Map<String, String> _englishCache = {};

  /// Get Bengali transliteration for a specific ayah
  /// Fetches from API if not cached
  Future<String?> getBengaliTransliteration(int surahNumber, int ayahNumber) async {
    final key = '$surahNumber:$ayahNumber';

    // Check cache first
    if (_bengaliCache.containsKey(key)) {
      return _bengaliCache[key];
    }

    // Fetch English transliteration and convert
    final english = await getEnglishTransliteration(surahNumber, ayahNumber);
    if (english != null) {
      final bengali = convertToBengali(english);
      _bengaliCache[key] = bengali;
      return bengali;
    }
    return null;
  }

  /// Get English transliteration for a specific ayah
  Future<String?> getEnglishTransliteration(int surahNumber, int ayahNumber) async {
    final key = '$surahNumber:$ayahNumber';

    if (_englishCache.containsKey(key)) {
      return _englishCache[key];
    }

    try {
      final url = 'https://api.alquran.cloud/v1/ayah/$surahNumber:$ayahNumber/en.transliteration';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          final text = data['data']['text'] as String?;
          if (text != null) {
            _englishCache[key] = text;
            return text;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching transliteration: $e');
    }
    return null;
  }

  /// Fetch all transliterations for a surah
  Future<Map<int, String>> getSurahTransliterations(int surahNumber) async {
    final Map<int, String> result = {};

    try {
      final url = 'https://api.alquran.cloud/v1/surah/$surahNumber/en.transliteration';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          final ayahs = data['data']['ayahs'] as List;
          for (final ayah in ayahs) {
            final number = ayah['numberInSurah'] as int;
            final text = ayah['text'] as String;
            final key = '$surahNumber:$number';

            _englishCache[key] = text;
            final bengali = convertToBengali(text);
            _bengaliCache[key] = bengali;
            result[number] = bengali;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching surah transliterations: $e');
    }
    return result;
  }

  /// Convert English/Latin transliteration to Bengali script
  /// Following standard Bengali Quran pronunciation conventions
  /// This is a public method that can be called directly
  String convertToBengali(String english) {
    String result = english;

    // Pre-processing: normalize text
    result = result.toLowerCase();

    // === SPECIAL COMBINATIONS (must come first) ===

    // Allah special handling
    result = result.replaceAll('allah', 'আল্লাহ');
    result = result.replaceAll('allaah', 'আল্লা-হ');

    // Common Islamic terms
    result = result.replaceAll('muhammad', 'মুহাম্মাদ');
    result = result.replaceAll('ibrahim', 'ইবরা-হীম');
    result = result.replaceAll('quran', 'কুরআন');
    result = result.replaceAll("qur'an", 'কুরআন');

    // === LONG VOWELS (Madd) - process before short vowels ===
    result = result.replaceAll('aa', 'া-');
    result = result.replaceAll('ā', 'া-');
    result = result.replaceAll('ee', 'ী');
    result = result.replaceAll('ī', 'ী');
    result = result.replaceAll('ii', 'ী');
    result = result.replaceAll('oo', 'ূ');
    result = result.replaceAll('ū', 'ূ');
    result = result.replaceAll('uu', 'ূ');

    // === DIPHTHONGS ===
    result = result.replaceAll('ai', 'াই');
    result = result.replaceAll('ay', 'াই');
    result = result.replaceAll('au', 'াউ');
    result = result.replaceAll('aw', 'াও');

    // === CONSONANT COMBINATIONS (Shaddah/Tashdeed) ===
    // Double consonants
    result = result.replaceAll('bb', 'ব্ব');
    result = result.replaceAll('dd', 'দ্দ');
    result = result.replaceAll('ff', 'ফ্ফ');
    result = result.replaceAll('gg', 'গ্গ');
    result = result.replaceAll('hh', 'হ্হ');
    result = result.replaceAll('jj', 'জ্জ');
    result = result.replaceAll('kk', 'ক্ক');
    result = result.replaceAll('ll', 'ল্ল');
    result = result.replaceAll('mm', 'ম্ম');
    result = result.replaceAll('nn', 'ন্ন');
    result = result.replaceAll('pp', 'প্প');
    result = result.replaceAll('rr', 'র্র');
    result = result.replaceAll('ss', 'স্স');
    result = result.replaceAll('tt', 'ত্ত');
    result = result.replaceAll('ww', 'ওও');
    result = result.replaceAll('yy', 'ইয়্য');
    result = result.replaceAll('zz', 'য্য');

    // === SPECIAL ARABIC LETTERS ===

    // Emphatic/Heavy letters
    result = result.replaceAll('dh', 'দ');  // ذ Dhaal
    result = result.replaceAll('ḍ', 'দ');   // ض Daad
    result = result.replaceAll('ḏ', 'য');   // ظ Dhaa
    result = result.replaceAll('gh', 'গ');  // غ Ghain
    result = result.replaceAll('ġ', 'গ');   // غ Ghain
    result = result.replaceAll('kh', 'খ');  // خ Khaa
    result = result.replaceAll('ḫ', 'খ');   // خ Khaa
    result = result.replaceAll('sh', 'শ');  // ش Sheen
    result = result.replaceAll('š', 'শ');   // ش Sheen
    result = result.replaceAll('th', 'স');  // ث Thaa (or 'থ' depending on context)
    result = result.replaceAll('ṯ', 'স');   // ث Thaa
    result = result.replaceAll('ṭ', 'ত');   // ط Taa
    result = result.replaceAll('ẓ', 'য');   // ظ Dhaa
    result = result.replaceAll('ṣ', 'স');   // ص Saad
    result = result.replaceAll('ḥ', 'হ');   // ح Haa
    result = result.replaceAll("'", '');    // Hamza/Ain - often silent
    result = result.replaceAll('`', '');    // Ain
    result = result.replaceAll('ʿ', '');    // Ain
    result = result.replaceAll('ʾ', '');    // Hamza

    // Qaf - ক্ব (important for Quran pronunciation)
    result = result.replaceAll('q', 'ক্ব');

    // === BASIC CONSONANTS ===
    result = result.replaceAll('b', 'ব');
    result = result.replaceAll('d', 'দ');
    result = result.replaceAll('f', 'ফ');
    result = result.replaceAll('g', 'গ');
    result = result.replaceAll('h', 'হ');
    result = result.replaceAll('j', 'জ');
    result = result.replaceAll('k', 'ক');
    result = result.replaceAll('l', 'ল');
    result = result.replaceAll('m', 'ম');
    result = result.replaceAll('n', 'ন');
    result = result.replaceAll('p', 'প');
    result = result.replaceAll('r', 'র');
    result = result.replaceAll('s', 'স');
    result = result.replaceAll('t', 'ত');
    result = result.replaceAll('v', 'ভ');
    result = result.replaceAll('w', 'ও');
    result = result.replaceAll('x', 'ক্স');
    result = result.replaceAll('y', 'ই');
    result = result.replaceAll('z', 'য');

    // === SHORT VOWELS ===
    result = result.replaceAll('a', 'া');
    result = result.replaceAll('e', 'ে');
    result = result.replaceAll('i', 'ি');
    result = result.replaceAll('o', 'ো');
    result = result.replaceAll('u', 'ু');

    // === POST-PROCESSING ===

    // Fix standalone vowels at word start
    result = _fixWordStartVowels(result);

    // Fix consecutive vowel marks
    result = _cleanupVowelMarks(result);

    // Capitalize first letter equivalent (optional)
    // Bengali doesn't have uppercase, but we can clean up

    return result.trim();
  }

  /// Fix vowels at the start of words
  String _fixWordStartVowels(String text) {
    // Replace standalone vowel marks at word boundaries with full vowel letters
    final words = text.split(' ');
    final fixed = words.map((word) {
      if (word.isEmpty) return word;

      // Check if word starts with a vowel mark (needs base letter)
      if (word.startsWith('া')) {
        return 'আ${word.substring(1)}';
      } else if (word.startsWith('ি')) {
        return 'ই${word.substring(1)}';
      } else if (word.startsWith('ী')) {
        return 'ঈ${word.substring(1)}';
      } else if (word.startsWith('ু')) {
        return 'উ${word.substring(1)}';
      } else if (word.startsWith('ূ')) {
        return 'ঊ${word.substring(1)}';
      } else if (word.startsWith('ে')) {
        return 'এ${word.substring(1)}';
      } else if (word.startsWith('ো')) {
        return 'ও${word.substring(1)}';
      } else if (word.startsWith('া-')) {
        return 'আ-${word.substring(2)}';
      }
      return word;
    }).join(' ');

    return fixed;
  }

  /// Clean up consecutive or misplaced vowel marks
  String _cleanupVowelMarks(String text) {
    String result = text;

    // Remove duplicate vowel marks
    result = result.replaceAll(RegExp(r'া+'), 'া');
    result = result.replaceAll(RegExp(r'ি+'), 'ি');
    result = result.replaceAll(RegExp(r'ী+'), 'ী');
    result = result.replaceAll(RegExp(r'ু+'), 'ু');
    result = result.replaceAll(RegExp(r'ূ+'), 'ূ');
    result = result.replaceAll(RegExp(r'ে+'), 'ে');
    result = result.replaceAll(RegExp(r'ো+'), 'ো');

    // Fix vowel + vowel combinations
    result = result.replaceAll('াি', 'ৈ'); // ai
    result = result.replaceAll('াু', 'ৌ'); // au

    return result;
  }

  /// Clear all cached transliterations
  void clearCache() {
    _bengaliCache.clear();
    _englishCache.clear();
  }
}

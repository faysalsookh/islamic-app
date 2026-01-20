import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class TafsirService {
  static final TafsirService _instance = TafsirService._internal();

  factory TafsirService() {
    return _instance;
  }

  TafsirService._internal();

  // Cache structure: Surah ID -> {Ayah ID -> Tafsir Text}
  final Map<int, Map<int, String>> _cache = {};

  // URL for Bengali Tafsir Ibn Kathir
  final String _baseUrl = 'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir/bn-tafseer-ibn-e-kaseer';

  /// Fetch Tafsir for a specific ayah (Offline first, then API)
  Future<String?> fetchTafsir(int surahNumber, int ayahNumber) async {
    // Check cache first
    if (_cache.containsKey(surahNumber)) {
      if (_cache[surahNumber]!.containsKey(ayahNumber)) {
        return _cache[surahNumber]![ayahNumber];
      }
    }

    // Try loading from local assets
    try {
      final String jsonString = await rootBundle.loadString('assets/tafsir/bn_ibn_kathir/$surahNumber.json');
      return _parseAndCacheResponse(jsonString, surahNumber, ayahNumber);
    } catch (e) {
      // Asset not found or error, fall back to API
      // print('Asset not found for surah $surahNumber, falling back to API');
    }

    try {
      // Fetch the full surah tafsir from API
      final url = Uri.parse('$_baseUrl/$surahNumber.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return _parseAndCacheResponse(utf8.decode(response.bodyBytes), surahNumber, ayahNumber);
      }
      return null;
    } catch (e) {
      print('Error fetching tafsir: $e');
      return null;
    }
  }

  String? _parseAndCacheResponse(String jsonString, int surahNumber, int ayahNumber) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      
      if (data.containsKey('ayahs')) {
        final List<dynamic> ayahs = data['ayahs'];
        
        // Initialize cache for this surah
        _cache[surahNumber] = {};
        
        String? requestedTafsir;
        
        // Process all ayahs
        for (var item in ayahs) {
          final int ayahId = item['ayah'];
          final String text = item['text'] ?? '';
          
          _cache[surahNumber]![ayahId] = text;
          
          if (ayahId == ayahNumber) {
            requestedTafsir = text;
          }
        }
        
        return requestedTafsir;
      }
    } catch (e) {
      print('Error parsing tafsir JSON: $e');
    }
    return null;
  }

  /// Check if tafsir is cached
  bool isCached(int surahNumber, int ayahNumber) {
    return _cache.containsKey(surahNumber) && _cache[surahNumber]!.containsKey(ayahNumber);
  }
}

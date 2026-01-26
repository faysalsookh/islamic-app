import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ayah.dart';
import '../data/shohoz_quran_transliterations.dart';
import 'tajweed_service.dart';
import 'transliteration_service.dart';

/// Service for fetching and caching Quran data from APIs
///
/// Arabic Text: QuranEnc API (King Fahd Quran Complex - Most Authoritative)
/// Bengali Translation: Quran.com API v4 (Taisirul Quran, Dr. Abu Bakr Zakaria)
/// English Translation: QuranEnc API (Sahih International)
/// Fallback: Al-Quran Cloud API
///
/// Features:
/// - Arabic text (Uthmani script from King Fahd Complex via QuranEnc)
/// - Bengali translation (Taisirul Quran, Dr. Abu Bakr Zakaria)
/// - English translation (Sahih International)
/// - Bengali transliteration (সহজ কুরআন + API conversion)
/// - Bengali Tafsir (Ibn Kathir, Ahsanul Bayaan, Abu Bakr Zakaria)
/// - Shani Nuzul (Context of revelation)
/// - Audio URLs
class QuranDataService extends ChangeNotifier {
  static final QuranDataService _instance = QuranDataService._internal();
  factory QuranDataService() => _instance;
  QuranDataService._internal();

  // Transliteration service for API-based transliterations
  final TransliterationService _transliterationService = TransliterationService();

  // Cache for loaded surahs
  final Map<int, List<Ayah>> _ayahCache = {};
  final Map<String, String> _tafsirCache = {};
  bool _isLoading = false;
  String? _error;

  // ============================================================
  // API CONFIGURATION - Quran.com API v4 (Primary)
  // ============================================================
  static const String _quranComBaseUrl = 'https://api.quran.com/api/v4';

  // Bengali Translation IDs (Quran.com)
  static const int _bengaliTaisirul = 161;      // Taisirul Quran - Most accurate
  static const int _bengaliRawai = 162;          // Rawai Al-bayan
  static const int _bengaliMujibur = 163;        // Sheikh Mujibur Rahman
  static const int _bengaliAbuBakr = 213;        // Dr. Abu Bakr Zakaria
  static const int _bengaliMuhiuddin = 9999;     // Muhiuddin Khan (Islamic Foundation) - served via Al-Quran Cloud

  // Bengali Tafsir IDs (Quran.com)
  static const int _tafsirIbnKathir = 164;       // Tafseer ibn Kathir (Bengali)
  static const int _tafsirAhsanulBayaan = 165;   // Tafsir Ahsanul Bayaan (Bengali)
  static const int _tafsirAbuBakrZakaria = 166;  // Tafsir Abu Bakr Zakaria (Bengali)
  static const int _tafsirFathulMajid = 381;     // Tafsir Fathul Majid (Bengali)

  // ============================================================
  // API CONFIGURATION - QuranEnc (King Fahd Complex - Most Authoritative)
  // ============================================================
  static const String _quranEncBaseUrl = 'https://quranenc.com/api/v1';
  static const String _quranEncEnglishKey = 'english_saheeh';  // Sahih International (Noor International)

  // ============================================================
  // API CONFIGURATION - Al-Quran Cloud (Fallback)
  // ============================================================
  static const String _alQuranCloudBaseUrl = 'https://api.alquran.cloud/v1';
  static const String _bengaliTranslationEdition = 'bn.bengali';  // Muhiuddin Khan
  static const String _arabicEdition = 'quran-uthmani';           // Uthmani script (fallback only)

  // Current settings
  int _currentBengaliTranslationId = 161; // Default to Taisirul Quran

  void setBengaliTranslationId(int id) {
    _currentBengaliTranslationId = id;
  }


  // Cache version - increment when data structure changes
  // v7: Added QuranEnc API for Arabic text (King Fahd Complex)
  // v8: Added Tajweed-annotated text from Quran.com API
  static const String _cacheVersion = 'v8';

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get ayahs for a specific surah
  /// Returns cached data if available, otherwise fetches from API
  Future<List<Ayah>> getAyahsForSurah(int surahNumber) async {
    // Check cache first
    if (_ayahCache.containsKey(surahNumber)) {
      return _ayahCache[surahNumber]!;
    }

    // Check local storage cache
    final cachedAyahs = await _loadFromLocalCache(surahNumber);
    if (cachedAyahs != null) {
      _ayahCache[surahNumber] = cachedAyahs;
      return cachedAyahs;
    }

    // Fetch from API
    return await _fetchSurahFromApi(surahNumber);
  }

  /// Fetch surah data from API with Arabic, Bengali, English, Transliteration, and Tafsir
  /// Primary: Quran.com API v4 (comprehensive data)
  /// Fallback: Al-Quran Cloud API
  Future<List<Ayah>> _fetchSurahFromApi(int surahNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try Quran.com API v4 first (comprehensive data)
      // Exception: If Muhiuddin Khan is selected, skip Quran.com and go directly to Al-Quran Cloud
      // because Quran.com v4 doesn't support this specific translation ID.
      List<Ayah>? quranComResult;
      if (_currentBengaliTranslationId != _bengaliMuhiuddin) {
        quranComResult = await _fetchFromQuranComApi(surahNumber);
      }
      
      if (quranComResult != null && quranComResult.isNotEmpty) {
        _ayahCache[surahNumber] = quranComResult;
        await _saveToLocalCache(surahNumber, quranComResult);
        _isLoading = false;
        notifyListeners();
        return quranComResult;
      }

      // Fallback to Al-Quran Cloud API (or primary if Muhiuddin Khan selected)
      debugPrint('Fetching from Al-Quran Cloud API for surah $surahNumber (Muhiuddin/Fallback)');
      final fallbackResult = await _fetchFromAlQuranCloudApi(surahNumber);

      _ayahCache[surahNumber] = fallbackResult;
      await _saveToLocalCache(surahNumber, fallbackResult);

      _isLoading = false;
      notifyListeners();
      return fallbackResult;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Error fetching surah $surahNumber: $e');

      // Return fallback data for demo surahs
      return _getFallbackAyahs(surahNumber);
    }
  }

  /// Fetch Quran data using hybrid approach:
  /// - Arabic text: QuranEnc API (King Fahd Quran Complex - Most Authoritative)
  /// - Bengali translation: Quran.com API v4
  /// - English translation: QuranEnc API
  /// Returns null if API fails, allowing fallback to Al-Quran Cloud
  Future<List<Ayah>?> _fetchFromQuranComApi(int surahNumber) async {
    try {
      // Fetch in parallel for better performance:
      // 1. QuranEnc for Arabic text + English translation
      // 2. Quran.com for Bengali translation + metadata + Tajweed text
      // 3. Al-Quran Cloud for transliteration
      final futures = await Future.wait([
        _fetchFromQuranEncApi(surahNumber, translationKey: _quranEncEnglishKey),
        http.get(Uri.parse(
          '$_quranComBaseUrl/verses/by_chapter/$surahNumber'
          '?language=bn'
          '&words=false'
          '&translations=$_currentBengaliTranslationId'
          '&fields=text_uthmani,text_uthmani_tajweed,text_indopak,text_uthmani_simple,verse_key,juz_number,page_number,hizb_number'
          '&per_page=300',
        )).timeout(const Duration(seconds: 20)),
        _fetchAlQuranCloudEdition(surahNumber, 'en.transliteration'),
      ]);

      final quranEncData = futures[0] as List<Map<String, dynamic>>?;
      final quranComResponse = futures[1] as http.Response;
      final transliterationData = futures[2] as Map<String, dynamic>?;

      // Parse Quran.com response for Bengali translation and metadata
      Map<String, dynamic>? versesData;
      List<dynamic>? verses;
      if (quranComResponse.statusCode == 200) {
        versesData = json.decode(quranComResponse.body);
        verses = versesData?['verses'] as List?;
      }

      // If neither API returned data, return null for fallback
      if (quranEncData == null && (verses == null || verses.isEmpty)) {
        debugPrint('Both QuranEnc and Quran.com APIs failed for surah $surahNumber');
        return null;
      }

      // Build ayah list
      final List<Ayah> ayahs = [];
      final int totalAyahs = quranEncData?.length ?? verses?.length ?? 0;

      for (int i = 0; i < totalAyahs; i++) {
        final ayahNumberInSurah = i + 1;

        // Get Arabic text from QuranEnc (King Fahd Complex - Most Authoritative)
        String arabicText = '';
        String? englishTranslation;
        if (quranEncData != null && i < quranEncData.length) {
          arabicText = quranEncData[i]['arabic_text'] as String? ?? '';
          englishTranslation = quranEncData[i]['translation'] as String?;
        }

        // Get metadata, Bengali translation, and Tajweed text from Quran.com
        String? bengaliTranslation;
        String? indopakText;
        String? tajweedText; // Tajweed-annotated text from Quran.com API
        int juz = 1, page = 1, hizbQuarter = 1;
        int ayahId = surahNumber * 1000 + ayahNumberInSurah;

        if (verses != null && i < verses.length) {
          final verse = verses[i];
          ayahId = verse['id'] as int? ?? ayahId;

          // Fallback Arabic text from Quran.com if QuranEnc failed
          if (arabicText.isEmpty) {
            arabicText = verse['text_uthmani'] as String? ?? verse['text_uthmani_simple'] as String? ?? '';
          }
          indopakText = verse['text_indopak'] as String?;

          // Get Tajweed-annotated text from Quran.com API
          tajweedText = verse['text_uthmani_tajweed'] as String?;
          if (i == 0) {
            debugPrint('Tajweed text for ayah 1: ${tajweedText?.substring(0, (tajweedText?.length ?? 0) > 50 ? 50 : (tajweedText?.length ?? 0))}...');
          }

          // Get Bengali translation
          final translations = verse['translations'] as List?;
          if (translations != null && translations.isNotEmpty) {
            for (final t in translations) {
              if (t['resource_id'] == _currentBengaliTranslationId) {
                bengaliTranslation = _cleanHtmlText(t['text'] as String?);
                break;
              }
            }
            bengaliTranslation ??= _cleanHtmlText(translations.first['text'] as String?);
          }

          // Get metadata
          juz = verse['juz_number'] as int? ?? 1;
          page = verse['page_number'] as int? ?? 1;
          hizbQuarter = verse['hizb_number'] as int? ?? 1;
        }

        // Get English transliteration
        String? englishTranslit;
        if (transliterationData != null && i < (transliterationData['ayahs'] as List).length) {
          englishTranslit = (transliterationData['ayahs'] as List)[i]['text'] as String?;
        }

        // Get Bengali transliteration:
        // Priority 1: সহজ কুরআন (Shohoz Quran) - Most accurate
        // Priority 2: Pre-defined transliterations
        // Priority 3: API conversion (fallback)
        String? bengaliTranslit = ShohozQuranTransliterations.getTransliteration(surahNumber, ayahNumberInSurah);
        bengaliTranslit ??= _getAccurateBengaliTransliteration(surahNumber, ayahNumberInSurah);
        if (bengaliTranslit == null && englishTranslit != null) {
          bengaliTranslit = _transliterationService.convertToBengali(englishTranslit);
        }

        final ayah = Ayah(
          number: ayahId,
          numberInSurah: ayahNumberInSurah,
          surahNumber: surahNumber,
          textArabic: arabicText,
          textIndopak: indopakText ?? arabicText,
          // Use API Tajweed text if available, otherwise fallback to generated markup
          textWithTajweed: tajweedText ?? TajweedService().generateTajweedMarkup(arabicText),
          translationBengali: bengaliTranslation,
          translationEnglish: englishTranslation,
          transliterationBengali: bengaliTranslit,
          transliterationEnglish: englishTranslit ?? _getAccurateEnglishTransliteration(surahNumber, ayahNumberInSurah),
          juz: juz,
          page: page,
          hizbQuarter: hizbQuarter,
        );
        ayahs.add(ayah);
      }

      debugPrint('Built ${ayahs.length} ayahs with QuranEnc Arabic + Quran.com Tajweed for surah $surahNumber');
      return ayahs;
    } catch (e) {
      debugPrint('Error fetching from hybrid API: $e');
      return null;
    }
  }

  /// Fetch from Al-Quran Cloud API - Fallback API
  /// Also tries QuranEnc for Arabic text (more authoritative)
  Future<List<Ayah>> _fetchFromAlQuranCloudApi(int surahNumber) async {
    // Fetch all editions in parallel for better performance
    // Try QuranEnc for Arabic + English first (King Fahd Complex)
    final results = await Future.wait([
      _fetchFromQuranEncApi(surahNumber, translationKey: _quranEncEnglishKey),
      _fetchAlQuranCloudEdition(surahNumber, _arabicEdition),
      _fetchAlQuranCloudEdition(surahNumber, _bengaliTranslationEdition),
      _fetchAlQuranCloudEdition(surahNumber, 'en.transliteration'),
    ]);

    final quranEncData = results[0] as List<Map<String, dynamic>>?;
    final arabicData = results[1] as Map<String, dynamic>?;
    final bengaliData = results[2] as Map<String, dynamic>?;
    final transliterationData = results[3] as Map<String, dynamic>?;

    // Determine Arabic text source
    final bool useQuranEnc = quranEncData != null && quranEncData.isNotEmpty;
    if (!useQuranEnc && arabicData == null) {
      throw Exception('Failed to fetch Arabic text from both QuranEnc and Al-Quran Cloud');
    }

    // Build ayah list combining all editions
    final List<Ayah> ayahs = [];
    final int totalAyahs = useQuranEnc
        ? quranEncData.length
        : (arabicData!['ayahs'] as List).length;

    for (int i = 0; i < totalAyahs; i++) {
      // Get Arabic text - prefer QuranEnc (King Fahd Complex)
      String arabicText;
      String? englishTranslation;
      int ayahNumber;
      int ayahNumberInSurah;
      int juz = 1, page = 1, hizbQuarter = 1;

      if (useQuranEnc) {
        arabicText = quranEncData[i]['arabic_text'] as String? ?? '';
        englishTranslation = quranEncData[i]['translation'] as String?;
        ayahNumberInSurah = int.parse(quranEncData[i]['aya'] as String? ?? '${i + 1}');
        ayahNumber = surahNumber * 1000 + ayahNumberInSurah;

        // Get metadata from Al-Quran Cloud if available
        if (arabicData != null && i < (arabicData['ayahs'] as List).length) {
          final arabicAyah = (arabicData['ayahs'] as List)[i];
          ayahNumber = arabicAyah['number'] as int? ?? ayahNumber;
          juz = arabicAyah['juz'] as int? ?? 1;
          page = arabicAyah['page'] as int? ?? 1;
          hizbQuarter = arabicAyah['hizbQuarter'] as int? ?? 1;
        }
      } else {
        // arabicData is guaranteed non-null here since useQuranEnc is false
        final arabicAyah = (arabicData!['ayahs'] as List)[i];
        arabicText = arabicAyah['text'] as String;
        ayahNumber = arabicAyah['number'] as int;
        ayahNumberInSurah = arabicAyah['numberInSurah'] as int;
        juz = arabicAyah['juz'] as int? ?? 1;
        page = arabicAyah['page'] as int? ?? 1;
        hizbQuarter = arabicAyah['hizbQuarter'] as int? ?? 1;
      }

      // Get Bengali translation
      final bengaliAyah = bengaliData != null && i < (bengaliData['ayahs'] as List).length
          ? (bengaliData['ayahs'] as List)[i]
          : null;

      // Get English transliteration
      final translitAyah = transliterationData != null && i < (transliterationData['ayahs'] as List).length
          ? (transliterationData['ayahs'] as List)[i]
          : null;

      // Get Bengali transliteration with priority system
      String? bengaliTranslit = ShohozQuranTransliterations.getTransliteration(surahNumber, ayahNumberInSurah);
      bengaliTranslit ??= _getAccurateBengaliTransliteration(surahNumber, ayahNumberInSurah);
      final englishTranslit = translitAyah?['text'] as String?;

      if (bengaliTranslit == null && englishTranslit != null) {
        bengaliTranslit = _transliterationService.convertToBengali(englishTranslit);
      }

      final ayah = Ayah(
        number: ayahNumber,
        numberInSurah: ayahNumberInSurah,
        surahNumber: surahNumber,
        textArabic: arabicText,
        textWithTajweed: TajweedService().generateTajweedMarkup(arabicText),
        translationBengali: bengaliAyah?['text'] as String?,
        translationEnglish: englishTranslation,
        transliterationBengali: bengaliTranslit,
        transliterationEnglish: englishTranslit ?? _getAccurateEnglishTransliteration(surahNumber, ayahNumberInSurah),
        juz: juz,
        page: page,
        hizbQuarter: hizbQuarter,
      );
      ayahs.add(ayah);
    }

    debugPrint('Fallback: Built ${ayahs.length} ayahs ${useQuranEnc ? "with QuranEnc" : "with Al-Quran Cloud"} for surah $surahNumber');
    return ayahs;
  }

  /// Clean HTML tags from API text responses
  String? _cleanHtmlText(String? text) {
    if (text == null) return null;
    // Remove HTML tags like <sup>, </sup>, etc.
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  /// Fetch Bengali Tafsir for a specific ayah
  /// Returns tafsir text from Quran.com API
  Future<String?> getBengaliTafsir(int surahNumber, int ayahNumber, {int? tafsirId}) async {
    final key = '${tafsirId ?? _tafsirIbnKathir}:$surahNumber:$ayahNumber';

    // Check cache first
    if (_tafsirCache.containsKey(key)) {
      return _tafsirCache[key];
    }

    try {
      final selectedTafsirId = tafsirId ?? _tafsirIbnKathir;
      final url = Uri.parse(
        '$_quranComBaseUrl/tafsirs/$selectedTafsirId/by_ayah/$surahNumber:$ayahNumber',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tafsirData = data['tafsir'];
        if (tafsirData != null) {
          final text = _cleanHtmlText(tafsirData['text'] as String?);
          if (text != null) {
            _tafsirCache[key] = text;
            return text;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching tafsir: $e');
    }
    return null;
  }

  /// Get available Bengali Tafsir options
  static List<Map<String, dynamic>> getBengaliTafsirOptions() {
    return [
      {'id': _tafsirIbnKathir, 'name': 'তাফসীর ইবনে কাসীর', 'nameEn': 'Tafsir Ibn Kathir'},
      {'id': _tafsirAhsanulBayaan, 'name': 'তাফসীর আহসানুল বায়ান', 'nameEn': 'Tafsir Ahsanul Bayaan'},
      {'id': _tafsirAbuBakrZakaria, 'name': 'তাফসীর আবু বকর জাকারিয়া', 'nameEn': 'Tafsir Abu Bakr Zakaria'},
      {'id': _tafsirFathulMajid, 'name': 'তাফসীর ফাতহুল মাজীদ', 'nameEn': 'Tafsir Fathul Majid'},
    ];
  }

  /// Get available Bengali Translation options
  static List<Map<String, dynamic>> getBengaliTranslationOptions() {
    return [
      {'id': _bengaliTaisirul, 'name': 'তাইসীরুল কুরআন', 'nameEn': 'Taisirul Quran'},
      {'id': _bengaliMuhiuddin, 'name': 'মুহিউদ্দীন খান (ইসলামিক ফাউন্ডেশন)', 'nameEn': 'Muhiuddin Khan (Islamic Foundation)'},
      {'id': _bengaliAbuBakr, 'name': 'ড. আবু বকর জাকারিয়া', 'nameEn': 'Dr. Abu Bakr Zakaria'},
      {'id': _bengaliMujibur, 'name': 'শেখ মুজিবুর রহমান', 'nameEn': 'Sheikh Mujibur Rahman'},
      {'id': _bengaliRawai, 'name': 'রওয়াই আল-বায়ান', 'nameEn': 'Rawai Al-bayan'},
    ];
  }

  /// Get Shani Nuzul (শানে নুযূল - Context of Revelation) for a surah
  /// Returns Bengali text explaining when/why the surah was revealed
  String? getShaniNuzul(int surahNumber) {
    return _shaniNuzulData[surahNumber];
  }

  /// Get Shani Nuzul for a specific ayah if available
  String? getAyahShaniNuzul(int surahNumber, int ayahNumber) {
    final key = '$surahNumber:$ayahNumber';
    return _ayahShaniNuzulData[key];
  }

  // ============================================================
  // SHANI NUZUL DATA (শানে নুযূল - Context of Revelation)
  // Professionally researched from authentic Islamic sources
  // ============================================================
  static const Map<int, String> _shaniNuzulData = {
    // সূরা আল-ফাতিহা
    1: 'সূরা আল-ফাতিহা মক্কায় অবতীর্ণ হয়েছে। এটি কুরআনের প্রথম পূর্ণাঙ্গ সূরা যা নাযিল হয়েছে। এই সূরাকে "উম্মুল কুরআন" (কুরআনের মা), "সাবউল মাসানী" (সাতটি বারবার পঠিত আয়াত) এবং "আল-কাফিয়া" (যথেষ্ট) বলা হয়। প্রতিটি নামাজে এই সূরা পাঠ করা ফরজ।',

    // সূরা আল-বাকারা
    2: 'সূরা আল-বাকারা মদীনায় অবতীর্ণ সর্ববৃহৎ সূরা। হিজরতের পর প্রায় ১০ বছরে বিভিন্ন সময়ে এর আয়াতসমূহ নাযিল হয়েছে। এতে ইসলামী জীবনবিধান, শরীয়তের বিধিবিধান এবং ইহুদী-খ্রিস্টানদের সাথে সংলাপ রয়েছে। "বাকারা" অর্থ গাভী, যা বনী ইসরাইলের গাভী জবাইয়ের ঘটনা থেকে এসেছে।',

    // সূরা আলে ইমরান
    3: 'সূরা আলে ইমরান মদীনায় অবতীর্ণ। নাজরানের খ্রিস্টান প্রতিনিধিদল মদীনায় এসে ঈসা (আ.) সম্পর্কে বিতর্ক করলে এই সূরার অধিকাংশ আয়াত নাযিল হয়। "আলে ইমরান" অর্থ ইমরানের পরিবার - মারইয়াম (আ.)-এর পিতা।',

    // সূরা আন-নিসা
    4: 'সূরা আন-নিসা মদীনায় অবতীর্ণ। উহুদ যুদ্ধের পর যখন অনেক মুসলিম শহীদ হন এবং তাদের পরিবার ও সম্পদ রক্ষার প্রয়োজন দেখা দেয়, তখন এই সূরা নাযিল হয়। "নিসা" অর্থ নারী - এতে নারীদের অধিকার ও পারিবারিক বিধান রয়েছে।',

    // সূরা আল-মায়িদা
    5: 'সূরা আল-মায়িদা মদীনায় অবতীর্ণ শেষ দিকের সূরা। বিদায় হজ্জের সময় বা তার কাছাকাছি সময়ে এর অধিকাংশ আয়াত নাযিল হয়। "মায়িদা" অর্থ খাবারের থালা - ঈসা (আ.)-এর হাওয়ারীদের জন্য আসমান থেকে খাবার নাযিলের ঘটনা থেকে এসেছে।',

    // সূরা আল-আনআম
    6: 'সূরা আল-আনআম সম্পূর্ণ মক্কায় একসাথে অবতীর্ণ। ৭০ হাজার ফেরেশতার সাথে রাতে এই সূরা নাযিল হয়েছে বলে বর্ণিত। "আনআম" অর্থ গবাদি পশু - মুশরিকদের পশু সম্পর্কিত কুসংস্কার খণ্ডন করা হয়েছে।',

    // সূরা আল-আরাফ
    7: 'সূরা আল-আরাফ মক্কায় অবতীর্ণ। "আরাফ" অর্থ উঁচু স্থান - জান্নাত ও জাহান্নামের মধ্যবর্তী একটি স্থান যেখানে কিছু মানুষ অবস্থান করবে। এই সূরায় আদম (আ.) থেকে মূসা (আ.) পর্যন্ত নবীদের কাহিনী এবং ইবলিসের অবাধ্যতার বিবরণ রয়েছে।',

    // সূরা আল-আনফাল
    8: 'সূরা আল-আনফাল মদীনায় বদর যুদ্ধের পর অবতীর্ণ। "আনফাল" অর্থ যুদ্ধলব্ধ সম্পদ। বদর যুদ্ধের গনিমতের মাল বণ্টন নিয়ে সাহাবীদের মধ্যে মতভেদ হলে এই সূরা নাযিল হয়। জিহাদের বিধান ও যুদ্ধনীতি এতে বর্ণিত।',

    // সূরা আত-তাওবা
    9: 'সূরা আত-তাওবা মদীনায় অবতীর্ণ শেষ সূরাগুলোর একটি। তাবুক যুদ্ধের সময় ৯ম হিজরিতে নাযিল হয়েছে। এটি একমাত্র সূরা যা "বিসমিল্লাহ" ছাড়া শুরু হয়েছে কারণ এতে মুনাফিক ও মুশরিকদের বিরুদ্ধে কঠোর বার্তা রয়েছে।',

    // সূরা ইউনুস
    10: 'সূরা ইউনুস মক্কায় অবতীর্ণ। ইউনুস (আ.)-এর কওম তাওবা করায় আল্লাহ তাদের আজাব উঠিয়ে নিয়েছিলেন - এই অনন্য ঘটনা থেকে সূরার নামকরণ। কুরআনের সত্যতা ও তাওহীদের প্রমাণ এতে রয়েছে।',

    // সূরা হুদ
    11: 'সূরা হুদ মক্কায় অবতীর্ণ। হুদ (আ.) সহ নূহ, সালিহ, ইব্রাহীম, লূত, শুআইব (আ.) প্রমুখ নবীদের কাহিনী বর্ণিত। রাসূল (সা.) বলেছেন, "সূরা হুদ ও এর অনুরূপ সূরাগুলো আমাকে বৃদ্ধ করে দিয়েছে।"',

    // সূরা ইউসুফ
    12: 'সূরা ইউসুফ মক্কায় "আমুল হুযন" (দুঃখের বছর) এ অবতীর্ণ, যখন খাদিজা (রা.) ও আবু তালিব মারা গেলেন। রাসূল (সা.)-কে সান্ত্বনা দিতে ইউসুফ (আ.)-এর কষ্ট ও বিজয়ের কাহিনী নাযিল হয়। এটি "আহসানুল কাসাস" (সর্বোত্তম কাহিনী)।',

    // সূরা আর-রাদ
    13: 'সূরা আর-রাদ মদীনায় অবতীর্ণ। "রাদ" অর্থ বজ্র - যা আল্লাহর তাসবীহ পাঠ করে। আল্লাহর একত্ব, সৃষ্টির নিদর্শন এবং রিসালাতের সত্যতা প্রমাণ করা হয়েছে। মক্কার কাফিররা মুজিযা দাবি করলে এই সূরা নাযিল হয়।',

    // সূরা ইব্রাহীম
    14: 'সূরা ইব্রাহীম মক্কায় অবতীর্ণ। ইব্রাহীম (আ.)-এর দোয়া এবং মক্কাকে নিরাপদ শহর বানানোর প্রার্থনা এতে রয়েছে। কৃতজ্ঞতা ও অকৃতজ্ঞতার পরিণতি, এবং শয়তানের কিয়ামতের দিনের বক্তব্য বর্ণিত।',

    // সূরা আল-হিজর
    15: 'সূরা আল-হিজর মক্কায় অবতীর্ণ। "হিজর" হলো সামূদ জাতির বাসস্থান। কুরআনের সংরক্ষণের ওয়াদা, ইবলিসের সৃষ্টি ও অভিশাপের কাহিনী, এবং লূত (আ.)-এর কওমের ধ্বংসের বিবরণ রয়েছে।',

    // সূরা আন-নাহল
    16: 'সূরা আন-নাহল মক্কায় অবতীর্ণ। "নাহল" অর্থ মৌমাছি - আল্লাহর অপূর্ব সৃষ্টি। এই সূরাকে "সূরাতুন নিয়াম" (নিয়ামতের সূরা) বলা হয় কারণ এতে আল্লাহর অসংখ্য নিয়ামতের বর্ণনা রয়েছে।',

    // সূরা আল-ইসরা (বনী ইসরাঈল)
    17: 'সূরা আল-ইসরা মক্কায় অবতীর্ণ। মিরাজের ঘটনা দিয়ে শুরু - রাসূল (সা.)-এর মসজিদুল হারাম থেকে মসজিদুল আকসায় রাতের সফর। বনী ইসরাঈলের উত্থান-পতন এবং ১২টি গুরুত্বপূর্ণ নৈতিক বিধান বর্ণিত।',

    // সূরা আল-কাহফ
    18: 'সূরা আল-কাহফ মক্কায় অবতীর্ণ। কুরাইশরা ইহুদী পণ্ডিতদের পরামর্শে তিনটি প্রশ্ন করেছিল - গুহাবাসী যুবক, যুলকারনাইন এবং রূহ সম্পর্কে। এর উত্তরে এই সূরা নাযিল হয়। জুমার দিন এই সূরা পাঠে বিশেষ ফজিলত রয়েছে।',

    // সূরা মারইয়াম
    19: 'সূরা মারইয়াম মক্কায় অবতীর্ণ। আবিসিনিয়ায় হিজরতের সময় জাফর (রা.) নাজাশী বাদশাহর সামনে এই সূরার প্রথম অংশ তিলাওয়াত করেছিলেন। মারইয়াম (আ.) ও ঈসা (আ.)-এর প্রকৃত পরিচয় এতে বর্ণিত।',

    // সূরা ত্বা-হা
    20: 'সূরা ত্বা-হা মক্কায় অবতীর্ণ। উমর (রা.)-এর ইসলাম গ্রহণের ঘটনায় এই সূরার ভূমিকা রয়েছে। তিনি বোনের ঘরে এই সূরা শুনে ইসলাম গ্রহণ করেন। মূসা (আ.)-এর বিস্তারিত কাহিনী এতে বর্ণিত।',

    // সূরা আল-আম্বিয়া
    21: 'সূরা আল-আম্বিয়া মক্কায় অবতীর্ণ। "আম্বিয়া" অর্থ নবীগণ - এই সূরায় ১৬ জন নবীর সংক্ষিপ্ত কাহিনী বর্ণিত। ইব্রাহীম (আ.)-এর মূর্তি ভাঙা ও অগ্নিকুণ্ডে নিক্ষেপের ঘটনা রয়েছে।',

    // সূরা আল-হাজ্জ
    22: 'সূরা আল-হাজ্জ মদীনায় অবতীর্ণ। হজ্জের বিধান, কুরবানী এবং কাবার ইতিহাস বর্ণিত। কিয়ামতের ভয়াবহতা এবং আল্লাহর পথে জিহাদের অনুমতি এই সূরায় প্রথম নাযিল হয়।',

    // সূরা আল-মুমিনূন
    23: 'সূরা আল-মুমিনূন মক্কায় অবতীর্ণ। সফল মুমিনদের ৭টি গুণ দিয়ে শুরু - নামাজে খুশু, অনর্থক কথা ও কাজ থেকে বিরত, যাকাত আদায়, লজ্জাস্থান হেফাজত, আমানত রক্ষা, ওয়াদা পালন এবং নামাজের হেফাজত।',

    // সূরা আন-নূর
    24: 'সূরা আন-নূর মদীনায় অবতীর্ণ। আয়িশা (রা.)-এর উপর মিথ্যা অপবাদ (ইফক)-এর ঘটনায় এই সূরার অধিকাংশ আয়াত নাযিল হয়। পর্দা, ব্যভিচারের শাস্তি, অপবাদের বিধান এবং "আয়াতুন নূর" (নূরের আয়াত) এতে রয়েছে।',

    // সূরা আল-ফুরকান
    25: 'সূরা আল-ফুরকান মক্কায় অবতীর্ণ। "ফুরকান" অর্থ সত্য-মিথ্যার পার্থক্যকারী - কুরআনের একটি নাম। মুশরিকদের আপত্তির জবাব এবং "ইবাদুর রহমান" (রহমানের বান্দাদের) ১২টি গুণ বর্ণিত।',

    // সূরা আশ-শুআরা
    26: 'সূরা আশ-শুআরা মক্কায় অবতীর্ণ। "শুআরা" অর্থ কবিগণ। মূসা (আ.)-এর বিস্তারিত কাহিনী এবং সাতজন নবীর কওমের ধ্বংসের বিবরণ রয়েছে। রাসূল (সা.)-কে কবি বলার অভিযোগ খণ্ডন করা হয়েছে।',

    // সূরা আন-নামল
    27: 'সূরা আন-নামল মক্কায় অবতীর্ণ। "নামল" অর্থ পিপীলিকা - সুলাইমান (আ.)-এর সেনাবাহিনী দেখে পিপীলিকার সতর্কবাণী থেকে নামকরণ। সুলাইমান (আ.) ও বিলকিসের কাহিনী বিস্তারিত বর্ণিত।',

    // সূরা আল-কাসাস
    28: 'সূরা আল-কাসাস মক্কায় অবতীর্ণ। "কাসাস" অর্থ কাহিনী। মূসা (আ.)-এর জন্ম থেকে নবুওয়াত পর্যন্ত বিস্তারিত কাহিনী রয়েছে। ফিরআউন, হামান ও কারুনের পরিণতি বর্ণিত। রাসূল (সা.)-এর মক্কায় ফিরে আসার ভবিষ্যদ্বাণী রয়েছে।',

    // সূরা আল-আনকাবূত
    29: 'সূরা আল-আনকাবূত মক্কায় অবতীর্ণ। "আনকাবূত" অর্থ মাকড়সা - যার জাল দুর্বল, তেমনি আল্লাহ ছাড়া সব আশ্রয় দুর্বল। মুমিনদের পরীক্ষা ও ধৈর্যের গুরুত্ব এবং পূর্ববর্তী জাতিদের পরীক্ষার কথা বর্ণিত।',

    // সূরা আর-রূম
    30: 'সূরা আর-রূম মক্কায় অবতীর্ণ। পারস্যের কাছে রোমানদের পরাজয়ের পর এই সূরা নাযিল হয় এবং ভবিষ্যদ্বাণী করা হয় যে কয়েক বছরের মধ্যে রোম বিজয়ী হবে - যা সত্য প্রমাণিত হয়। আল্লাহর সৃষ্টির নিদর্শন বর্ণিত।',

    // সূরা লুকমান
    31: 'সূরা লুকমান মক্কায় অবতীর্ণ। প্রজ্ঞাবান লুকমান (আ.) তাঁর পুত্রকে যে উপদেশ দিয়েছিলেন তা এই সূরায় বর্ণিত - শিরক থেকে বিরত থাকা, পিতামাতার সাথে সদ্ব্যবহার, নামাজ, সৎকাজের আদেশ এবং বিনয়।',

    // সূরা আস-সাজদা
    32: 'সূরা আস-সাজদা মক্কায় অবতীর্ণ। রাসূল (সা.) প্রতি জুমার রাতে ফজরের নামাজে সূরা সাজদা ও সূরা ইনসান পাঠ করতেন। আল্লাহর সৃষ্টি, মানুষের সৃষ্টি এবং কিয়ামতের বিবরণ রয়েছে।',

    // সূরা আল-আহযাব
    33: 'সূরা আল-আহযাব মদীনায় অবতীর্ণ। "আহযাব" অর্থ সম্মিলিত বাহিনী - খন্দক যুদ্ধে কুরাইশ ও তাদের মিত্রদের সম্মিলিত আক্রমণ। রাসূল (সা.)-এর বিবাহ সংক্রান্ত বিধান, পর্দার আয়াত এবং যায়নাব (রা.)-এর বিবাহের ঘটনা রয়েছে।',

    // সূরা সাবা
    34: 'সূরা সাবা মক্কায় অবতীর্ণ। ইয়ামানের সাবা জাতির সমৃদ্ধি ও ধ্বংসের কাহিনী বর্ণিত। দাউদ ও সুলাইমান (আ.)-এর নিয়ামত এবং আল্লাহর কৃতজ্ঞতার গুরুত্ব এতে রয়েছে।',

    // সূরা ফাতির
    35: 'সূরা ফাতির মক্কায় অবতীর্ণ। "ফাতির" অর্থ স্রষ্টা - আল্লাহর একটি নাম। ফেরেশতাদের বর্ণনা দিয়ে শুরু। আল্লাহর সৃষ্টি ক্ষমতা, রিসালাতের সত্যতা এবং মুমিন-কাফিরের পার্থক্য বর্ণিত।',

    // সূরা ইয়াসীন
    36: 'সূরা ইয়াসীন মক্কায় অবতীর্ণ। এটি কুরআনের "হৃদয়" বলে পরিচিত। মৃত্যুশয্যায় ও মৃতদের জন্য এই সূরা পাঠের বিশেষ ফজিলত রয়েছে। রাসূল (সা.) বলেছেন, "যে ব্যক্তি সূরা ইয়াসীন পাঠ করবে, তার জন্য দশবার কুরআন খতমের সওয়াব।"',

    // সূরা আস-সাফফাত
    37: 'সূরা আস-সাফফাত মক্কায় অবতীর্ণ। "সাফফাত" অর্থ সারিবদ্ধ (ফেরেশতাগণ)। ইব্রাহীম (আ.) কর্তৃক পুত্র কুরবানীর মহান ঘটনা এই সূরায় বর্ণিত। নূহ, ইব্রাহীম, মূসা, হারুন, ইলিয়াস, লূত, ইউনুস (আ.)-এর কাহিনী রয়েছে।',

    // সূরা সোয়াদ
    38: 'সূরা সোয়াদ মক্কায় অবতীর্ণ। আবু তালিবের অসুস্থতার সময় কুরাইশ নেতারা রাসূল (সা.)-কে দাওয়াত ত্যাগ করতে চাপ দিলে এই সূরা নাযিল হয়। দাউদ ও সুলাইমান (আ.)-এর কাহিনী এবং ইবলিসের অহংকারের বিবরণ রয়েছে।',

    // সূরা আয-যুমার
    39: 'সূরা আয-যুমার মক্কায় অবতীর্ণ। "যুমার" অর্থ দলে দলে - কিয়ামতের দিন মানুষ দলে দলে জান্নাত ও জাহান্নামে যাবে। তাওহীদ, ইখলাস এবং তাওবার গুরুত্ব বর্ণিত। শিরকের ভয়াবহতা সম্পর্কে সতর্ক করা হয়েছে।',

    // সূরা গাফির (আল-মুমিন)
    40: 'সূরা গাফির মক্কায় অবতীর্ণ। "গাফির" অর্থ ক্ষমাকারী - আল্লাহর একটি গুণ। ফিরআউনের দরবারে এক গোপন মুমিনের সাহসী বক্তব্য এই সূরায় বর্ণিত। "হা-মীম" দিয়ে শুরু হওয়া সাতটি সূরার প্রথম।',

    // সূরা ফুসসিলাত (হা-মীম সাজদা)
    41: 'সূরা ফুসসিলাত মক্কায় অবতীর্ণ। "ফুসসিলাত" অর্থ বিস্তারিত বর্ণিত। উতবা ইবনে রাবীআ রাসূল (সা.)-এর কাছে এসে এই সূরা শুনে মুগ্ধ হয়ে ফিরে যান। কুরআনের মুজিযা ও সৃষ্টির নিদর্শন বর্ণিত।',

    // সূরা আশ-শূরা
    42: 'সূরা আশ-শূরা মক্কায় অবতীর্ণ। "শূরা" অর্থ পরামর্শ - মুসলমানদের পারস্পরিক পরামর্শের গুরুত্ব। ওহী, রিসালাত এবং আল্লাহর একত্বের প্রমাণ বর্ণিত। ধৈর্য ও ক্ষমার ফজিলত রয়েছে।',

    // সূরা আয-যুখরুফ
    43: 'সূরা আয-যুখরুফ মক্কায় অবতীর্ণ। "যুখরুফ" অর্থ সোনার অলংকার। দুনিয়ার সম্পদের প্রকৃত মূল্যহীনতা বর্ণিত। ঈসা (আ.) সম্পর্কে সত্য তথ্য এবং মুশরিকদের ফেরেশতা পূজার খণ্ডন রয়েছে।',

    // সূরা আদ-দুখান
    44: 'সূরা আদ-দুখান মক্কায় অবতীর্ণ। "দুখান" অর্থ ধোঁয়া - কিয়ামতের একটি আলামত। মক্কায় দুর্ভিক্ষের সময় আকাশ ধোঁয়াটে দেখাচ্ছিল। লাইলাতুল মুবারাকা (বরকতময় রাত) এবং ফিরআউনের ধ্বংস বর্ণিত।',

    // সূরা আল-জাসিয়া
    45: 'সূরা আল-জাসিয়া মক্কায় অবতীর্ণ। "জাসিয়া" অর্থ হাঁটু গেড়ে বসা - কিয়ামতের দিন সকল জাতি এভাবে বসবে। আল্লাহর নিদর্শন অস্বীকারকারীদের পরিণতি এবং বনী ইসরাঈলের প্রতি নিয়ামতের কথা বর্ণিত।',

    // সূরা আল-আহকাফ
    46: 'সূরা আল-আহকাফ মক্কায় অবতীর্ণ। "আহকাফ" হলো আদ জাতির বাসস্থান বালুর পাহাড়। জিনদের কুরআন শোনা ও ইসলাম গ্রহণের ঘটনা এই সূরায় বর্ণিত। পিতামাতার প্রতি সদ্ব্যবহারের নির্দেশ রয়েছে।',

    // সূরা মুহাম্মাদ
    47: 'সূরা মুহাম্মাদ মদীনায় অবতীর্ণ। জিহাদের বিধান, যুদ্ধবন্দীদের সাথে আচরণ এবং মুনাফিকদের বৈশিষ্ট্য বর্ণিত। ঈমান ও আমলের গুরুত্ব এবং কাফিরদের আমল বিনষ্টের কথা রয়েছে।',

    // সূরা আল-ফাতহ
    48: 'সূরা আল-ফাতহ মদীনায় হুদাইবিয়ার সন্ধির পর অবতীর্ণ। "ফাতহ" অর্থ বিজয়। এই সন্ধি বাহ্যত পরাজয় মনে হলেও আল্লাহ একে "সুস্পষ্ট বিজয়" বলেছেন। রাসূল (সা.)-এর স্বপ্নে মক্কা বিজয়ের ভবিষ্যদ্বাণী সত্য হয়।',

    // সূরা আল-হুজুরাত
    49: 'সূরা আল-হুজুরাত মদীনায় অবতীর্ণ। "হুজুরাত" অর্থ কক্ষসমূহ - রাসূল (সা.)-এর ঘর। ইসলামী শিষ্টাচার, সামাজিক বিধান, গীবত-অপবাদ নিষেধ এবং মানুষের মধ্যে সাম্যের ঘোষণা এতে রয়েছে।',

    // সূরা ক্বাফ
    50: 'সূরা ক্বাফ মক্কায় অবতীর্ণ। রাসূল (সা.) প্রায়ই জুমার খুতবায় এই সূরা পাঠ করতেন। পুনরুত্থান, হিসাব-নিকাশ এবং জান্নাত-জাহান্নামের বর্ণনা রয়েছে। মৃত্যুর সময় মালাকুল মাউতের আগমনের কথা বর্ণিত।',

    // সূরা আয-যারিয়াত
    51: 'সূরা আয-যারিয়াত মক্কায় অবতীর্ণ। "যারিয়াত" অর্থ বায়ু যা ধূলিকণা উড়িয়ে নিয়ে যায়। ইব্রাহীম (আ.)-এর মেহমানদারি এবং লূত (আ.)-এর কওমের ধ্বংসের কথা বর্ণিত। জিন ও মানুষ সৃষ্টির উদ্দেশ্য - একমাত্র আল্লাহর ইবাদত।',

    // সূরা আত-তূর
    52: 'সূরা আত-তূর মক্কায় অবতীর্ণ। "তূর" হলো সেই পাহাড় যেখানে মূসা (আ.) আল্লাহর সাথে কথা বলেছিলেন। কিয়ামতের ভয়াবহতা, জান্নাতের সুখ এবং কাফিরদের বাতিল যুক্তির খণ্ডন রয়েছে।',

    // সূরা আন-নাজম
    53: 'সূরা আন-নাজম মক্কায় অবতীর্ণ। "নাজম" অর্থ তারা। মিরাজের ঘটনা এবং রাসূল (সা.)-এর সিদরাতুল মুনতাহায় পৌঁছানোর বর্ণনা রয়েছে। এটি প্রথম সূরা যা প্রকাশ্যে তিলাওয়াত করা হয় এবং কাফিররাও সিজদা করেছিল।',

    // সূরা আল-ক্বামার
    54: 'সূরা আল-ক্বামার মক্কায় অবতীর্ণ। "ক্বামার" অর্থ চাঁদ। রাসূল (সা.)-এর মুজিযায় চাঁদ দ্বিখণ্ডিত হওয়ার ঘটনা দিয়ে শুরু। "ওয়ালাক্বাদ ইয়াসসারনাল কুরআনা লিয-যিকরি" (আমি কুরআনকে সহজ করেছি) চারবার পুনরাবৃত্তি হয়েছে।',

    // সূরা আর-রহমান
    55: 'সূরা আর-রহমান মদীনায় অবতীর্ণ। জিন ও মানুষ উভয়কে সম্বোধন করে আল্লাহর নিয়ামতের কথা বলা হয়েছে। "ফাবিআইয়ি আলা-ই রাব্বিকুমা তুকাযযিবান" (তোমরা তোমাদের রবের কোন নিয়ামতকে অস্বীকার করবে?) ৩১ বার পুনরাবৃত্তি হয়েছে।',

    // সূরা আল-ওয়াকিয়া
    56: 'সূরা আল-ওয়াকিয়া মক্কায় অবতীর্ণ। "ওয়াকিয়া" অর্থ মহাঘটনা - কিয়ামত। মানুষকে তিন দলে ভাগ করা হয়েছে: সাবিকুন (অগ্রবর্তী), আসহাবুল ইয়ামীন (ডানপন্থী) এবং আসহাবুশ শিমাল (বামপন্থী)। রাসূল (সা.) বলেছেন, যে প্রতি রাতে এই সূরা পড়বে তাকে দারিদ্র্য স্পর্শ করবে না।',

    // সূরা আল-হাদীদ
    57: 'সূরা আল-হাদীদ মদীনায় অবতীর্ণ। "হাদীদ" অর্থ লোহা - যাতে কঠোরতা ও মানুষের জন্য উপকার রয়েছে। আল্লাহর পথে ব্যয়, দুনিয়ার জীবনের বাস্তবতা এবং পূর্ববর্তী নবীদের প্রেরণের উদ্দেশ্য বর্ণিত।',

    // সূরা আল-মুজাদালা
    58: 'সূরা আল-মুজাদালা মদীনায় অবতীর্ণ। খাওলা বিনতে সালাবা তার স্বামীর যিহার (স্ত্রীকে মায়ের সাথে তুলনা) নিয়ে রাসূল (সা.)-এর কাছে অভিযোগ করলে এই সূরা নাযিল হয়। যিহারের কাফফারা এবং গোপন পরামর্শের বিধান রয়েছে।',

    // সূরা আল-হাশর
    59: 'সূরা আল-হাশর মদীনায় অবতীর্ণ। বনু নাযীর গোত্রকে মদীনা থেকে বহিষ্কারের ঘটনা বর্ণিত। ফাই (যুদ্ধ ছাড়া প্রাপ্ত সম্পদ)-এর বণ্টন বিধান এবং আল্লাহর অনেক সুন্দর নাম (আসমাউল হুসনা) এই সূরার শেষে রয়েছে।',

    // সূরা আল-মুমতাহানা
    60: 'সূরা আল-মুমতাহানা মদীনায় অবতীর্ণ। হাতিব ইবনে আবি বালতাআ মক্কার কাফিরদের কাছে গোপন সংবাদ পাঠালে এই সূরা নাযিল হয়। কাফিরদের সাথে বন্ধুত্ব নিষেধ এবং মুসলিম নারীদের পরীক্ষার বিধান রয়েছে।',

    // সূরা আস-সাফ
    61: 'সূরা আস-সাফ মদীনায় অবতীর্ণ। "সাফ" অর্থ সারি - আল্লাহর পথে সারিবদ্ধ হয়ে জিহাদ। মূসা (আ.)-এর কওমের অবাধ্যতা, ঈসা (আ.)-এর আহমাদ নামে নবীর ভবিষ্যদ্বাণী এবং হাওয়ারীদের কথা বর্ণিত।',

    // সূরা আল-জুমুআ
    62: 'সূরা আল-জুমুআ মদীনায় অবতীর্ণ। জুমার নামাজের বিধান এবং খুতবার সময় বাণিজ্য ত্যাগের নির্দেশ রয়েছে। একবার জুমার খুতবার সময় বাণিজ্য কাফেলা আসলে অনেকে চলে যায়, তখন এই আয়াত নাযিল হয়।',

    // সূরা আল-মুনাফিকূন
    63: 'সূরা আল-মুনাফিকূন মদীনায় অবতীর্ণ। মুনাফিক নেতা আব্দুল্লাহ ইবনে উবাই ও তার সঙ্গীদের বৈশিষ্ট্য বর্ণিত। তাদের মিথ্যা শপথ, ঈমানের ভান এবং মুসলমানদের বিরুদ্ধে ষড়যন্ত্রের কথা রয়েছে।',

    // সূরা আত-তাগাবুন
    64: 'সূরা আত-তাগাবুন মদীনায় অবতীর্ণ। "তাগাবুন" অর্থ লাভ-ক্ষতি - কিয়ামতের দিন প্রকৃত লাভ-ক্ষতি প্রকাশ পাবে। পরিবার-সন্তান কখনো আল্লাহর পথে বাধা হতে পারে এই সতর্কতা এবং আল্লাহর পথে ব্যয়ের ফজিলত রয়েছে।',

    // সূরা আত-তালাক
    65: 'সূরা আত-তালাক মদীনায় অবতীর্ণ। তালাকের বিস্তারিত বিধান - ইদ্দত পালন, গর্ভবতী স্ত্রীর অধিকার, বাসস্থান ও ভরণ-পোষণ। আল্লাহভীরুদের জন্য রিজিকের দরজা খোলার ওয়াদা রয়েছে।',

    // সূরা আত-তাহরীম
    66: 'সূরা আত-তাহরীম মদীনায় অবতীর্ণ। রাসূল (সা.) নিজের উপর মধু অথবা মারিয়া কিবতিয়ার সাথে সাক্ষাৎ হারাম করেছিলেন। স্ত্রীদের গোপনীয়তা রক্ষা এবং পরিবারকে জাহান্নাম থেকে বাঁচানোর নির্দেশ রয়েছে।',

    // সূরা আল-মুলক
    67: 'সূরা আল-মুলক মক্কায় অবতীর্ণ। রাসূল (সা.) প্রতি রাতে ঘুমানোর আগে এই সূরা পাঠ করতেন। এই সূরা কবরের আজাব থেকে রক্ষা করবে এবং কিয়ামতের দিন সুপারিশ করবে।',

    // সূরা আল-কলম
    68: 'সূরা আল-কলম মক্কায় প্রথম দিকে অবতীর্ণ। "নূন ওয়াল কলম" - কলম ও লেখনীর শপথ দিয়ে শুরু। রাসূল (সা.)-কে পাগল বলার অভিযোগ খণ্ডন এবং বাগান মালিকদের কাহিনী বর্ণিত। ইউনুস (আ.)-এর উল্লেখ রয়েছে।',

    // সূরা আল-হাক্কা
    69: 'সূরা আল-হাক্কা মক্কায় অবতীর্ণ। "হাক্কা" অর্থ অবধারিত সত্য - কিয়ামতের একটি নাম। আদ, সামূদ ও ফিরআউনের ধ্বংস, কিয়ামতের ভয়াবহতা এবং আমলনামা ডান ও বাম হাতে প্রাপ্তির বিবরণ রয়েছে।',

    // সূরা আল-মাআরিজ
    70: 'সূরা আল-মাআরিজ মক্কায় অবতীর্ণ। "মাআরিজ" অর্থ উর্ধ্বগমনের সিঁড়ি। একজন কাফির আজাবের তাড়াহুড়া করেছিল। মানুষের দুর্বলতা ও মুসল্লীদের গুণাবলী বর্ণিত। কিয়ামতের দিনের দৈর্ঘ্য ৫০,০০০ বছরের সমান।',

    // সূরা নূহ
    71: 'সূরা নূহ মক্কায় অবতীর্ণ। নূহ (আ.)-এর সাড়ে নয়শ বছরের দাওয়াত, তাঁর কওমের অবাধ্যতা এবং তাঁর দোয়ায় তাদের ধ্বংসের বিবরণ। ইস্তিগফারের ফজিলত - বৃষ্টি, সম্পদ ও সন্তান লাভ।',

    // সূরা আল-জিন
    72: 'সূরা আল-জিন মক্কায় অবতীর্ণ। তায়েফ থেকে ফেরার পথে জিনরা রাসূল (সা.)-এর কুরআন তিলাওয়াত শুনে ঈমান আনে। জিনদের সম্পর্কে সঠিক তথ্য এবং গায়েবের জ্ঞান একমাত্র আল্লাহর কাছে - এই বিষয়গুলো বর্ণিত।',

    // সূরা আল-মুযযাম্মিল
    73: 'সূরা আল-মুযযাম্মিল মক্কায় প্রথম দিকে অবতীর্ণ। "মুযযাম্মিল" অর্থ চাদরাবৃত - রাসূল (সা.)-কে সম্বোধন। রাতের নামাজ (তাহাজ্জুদ), কুরআন তিলাওয়াত এবং ধৈর্যের নির্দেশ রয়েছে।',

    // সূরা আল-মুদ্দাসসির
    74: 'সূরা আল-মুদ্দাসসির মক্কায় অবতীর্ণ। প্রথম ওহী পাওয়ার পর বিরতির পরে এই সূরা নাযিল হয়। "মুদ্দাসসির" অর্থ কম্বলাবৃত। দাওয়াতের নির্দেশ এবং ওয়ালিদ ইবনে মুগীরার শাস্তির বিবরণ রয়েছে।',

    // সূরা আল-কিয়ামা
    75: 'সূরা আল-কিয়ামা মক্কায় অবতীর্ণ। কিয়ামতের দিনের বিবরণ এবং পুনরুত্থান অস্বীকারকারীদের জবাব। মৃত্যুর সময়ের ভয়াবহতা এবং মানুষের অঙ্গ-প্রত্যঙ্গ সাক্ষ্য দেবে।',

    // সূরা আল-ইনসান (আদ-দাহর)
    76: 'সূরা আল-ইনসান মদীনায় অবতীর্ণ। মানুষ সৃষ্টির আগে কিছুই ছিল না। আলী, ফাতিমা ও তাদের পরিবার তিন দিন রোযা রেখে ইফতারের খাবার মিসকিন, ইয়াতীম ও বন্দীকে দিয়েছিলেন - এই ঘটনায় আয়াত নাযিল হয়।',

    // সূরা আল-মুরসালাত
    77: 'সূরা আল-মুরসালাত মক্কায় অবতীর্ণ। "মুরসালাত" অর্থ প্রেরিত বায়ু। "ওয়াইলুই ইয়াওমাইযিল লিলমুকাযযিবীন" (সেদিন মিথ্যাবাদীদের জন্য ধ্বংস) দশবার পুনরাবৃত্তি হয়েছে। একটি গুহায় এই সূরা নাযিল হয়।',

    // সূরা আন-নাবা
    78: 'সূরা আন-নাবা মক্কায় অবতীর্ণ। "নাবা" অর্থ মহাসংবাদ - কিয়ামত। কাফিররা পুনরুত্থান নিয়ে তর্ক করত। আল্লাহর সৃষ্টির নিদর্শন, কিয়ামতের বিবরণ এবং জান্নাত-জাহান্নামের বর্ণনা রয়েছে।',

    // সূরা আন-নাযিআত
    79: 'সূরা আন-নাযিআত মক্কায় অবতীর্ণ। "নাযিআত" হলো ফেরেশতা যারা কাফিরদের রূহ কঠোরভাবে বের করে। মূসা (আ.) ও ফিরআউনের সংক্ষিপ্ত কাহিনী এবং কিয়ামতের বিবরণ রয়েছে।',

    // সূরা আবাসা
    80: 'সূরা আবাসা মক্কায় অবতীর্ণ। অন্ধ সাহাবী আব্দুল্লাহ ইবনে উম্মে মাকতূম রাসূল (সা.)-এর কাছে এলে তিনি কুরাইশ নেতাদের দাওয়াতে ব্যস্ত ছিলেন। আল্লাহ এই সূরায় সতর্ক করেন যে দরিদ্র মুমিনদের গুরুত্ব বেশি।',

    // সূরা আত-তাকভীর
    81: 'সূরা আত-তাকভীর মক্কায় অবতীর্ণ। কিয়ামতের প্রাথমিক আলামত - সূর্য জ্যোতিহীন হবে, তারা খসে পড়বে, পাহাড় চলমান হবে। জীবন্ত কবরস্থ কন্যাকে জিজ্ঞাসা করা হবে কোন অপরাধে তাকে হত্যা করা হয়েছিল।',

    // সূরা আল-ইনফিতার
    82: 'সূরা আল-ইনফিতার মক্কায় অবতীর্ণ। "ইনফিতার" অর্থ বিদীর্ণ হওয়া - আকাশ বিদীর্ণ হবে। কিরামান কাতিবীন (সম্মানিত লেখক) ফেরেশতাদের উল্লেখ যারা মানুষের আমল লিখে রাখেন।',

    // সূরা আল-মুতাফফিফীন
    83: 'সূরা আল-মুতাফফিফীন মক্কা-মদীনার মধ্যবর্তী সময়ে অবতীর্ণ। "মুতাফফিফীন" অর্থ মাপে কম দাতা। মদীনায় কিছু ব্যবসায়ী প্রতারণা করত। সিজ্জীন (পাপীদের আমলনামা) ও ইল্লিয়ীন (নেককারদের আমলনামা) এর বর্ণনা রয়েছে।',

    // সূরা আল-ইনশিকাক
    84: 'সূরা আল-ইনশিকাক মক্কায় অবতীর্ণ। "ইনশিকাক" অর্থ ফেটে যাওয়া - আকাশ ফেটে যাবে। মানুষ ধাপে ধাপে বিভিন্ন অবস্থার মধ্য দিয়ে যাবে। আমলনামা পিঠের পেছন দিক থেকে প্রাপ্তির বিবরণ রয়েছে।',

    // সূরা আল-বুরূজ
    85: 'সূরা আল-বুরূজ মক্কায় অবতীর্ণ। "বুরূজ" অর্থ তারকামণ্ডলী। আসহাবুল উখদূদ (গর্তওয়ালাদের) ঘটনা - ইয়ামানের খ্রিস্টান মুমিনদের আগুনে পুড়িয়ে হত্যার বিবরণ। ফিরআউন ও সামূদের ধ্বংসের উল্লেখ।',

    // সূরা আত-তারিক
    86: 'সূরা আত-তারিক মক্কায় অবতীর্ণ। "তারিক" অর্থ রাতে আগমনকারী তারা। মানুষ সৃষ্টির বিবরণ এবং পুনরুত্থানের প্রমাণ রয়েছে। আল্লাহর পরিকল্পনা ও কাফিরদের ষড়যন্ত্রের তুলনা করা হয়েছে।',

    // সূরা আল-আলা
    87: 'সূরা আল-আলা মক্কায় অবতীর্ণ। রাসূল (সা.) বিতর নামাজে এই সূরা পাঠ করতেন। "সাব্বিহিসমা রাব্বিকাল আলা" (তোমার মহান রবের নামের পবিত্রতা ঘোষণা কর) দিয়ে শুরু। ইব্রাহীম ও মূসা (আ.)-এর সহীফার উল্লেখ।',

    // সূরা আল-গাশিয়া
    88: 'সূরা আল-গাশিয়া মক্কায় অবতীর্ণ। "গাশিয়া" অর্থ আচ্ছন্নকারী - কিয়ামতের একটি নাম। রাসূল (সা.) জুমা ও ঈদের নামাজে এই সূরা পাঠ করতেন। জান্নাত ও জাহান্নামবাসীদের চেহারার বর্ণনা রয়েছে।',

    // সূরা আল-ফাজর
    89: 'সূরা আল-ফাজর মক্কায় অবতীর্ণ। "ফাজর" অর্থ ভোর। আদ, সামূদ ও ফিরআউনের ধ্বংসের কথা বর্ণিত। সম্পদ দিয়ে পরীক্ষা এবং ইয়াতীম ও মিসকিনদের প্রতি আচরণের গুরুত্ব। "ইয়া আইয়াতুহান নাফসুল মুতমাইন্না" (হে প্রশান্ত আত্মা) আয়াত রয়েছে।',

    // সূরা আল-বালাদ
    90: 'সূরা আল-বালাদ মক্কায় অবতীর্ণ। "বালাদ" অর্থ শহর - মক্কা। মক্কার শপথ এবং মানুষ সংগ্রামে সৃষ্ট - এই সত্য বর্ণিত। দুটি পথ - ভালো ও মন্দ, এবং দাস মুক্তি ও মিসকিন আহারের ফজিলত রয়েছে।',

    // সূরা আশ-শামস
    91: 'সূরা আশ-শামস মক্কায় অবতীর্ণ। "শামস" অর্থ সূর্য। সাত/আট বার শপথ করে বলা হয়েছে - যে আত্মাকে পরিশুদ্ধ করে সে সফল। সামূদ জাতির উটনী হত্যা ও তাদের ধ্বংসের সংক্ষিপ্ত বিবরণ।',

    // সূরা আল-লাইল
    92: 'সূরা আল-লাইল মক্কায় অবতীর্ণ। "লাইল" অর্থ রাত। রাত ও দিনের শপথ করে দুই ধরনের মানুষের কথা বলা হয়েছে - দানশীল ও কৃপণ। আবু বকর (রা.)-এর দাস বিলাল (রা.)-কে মুক্ত করার ঘটনা এই সূরার প্রেক্ষাপট।',

    // সূরা আদ-দুহা
    93: 'সূরা আদ-দুহা মক্কায় অবতীর্ণ। ওহী নাযিলে বিরতির সময় কাফিররা বলেছিল আল্লাহ রাসূল (সা.)-কে ত্যাগ করেছেন। তখন এই সূরা নাযিল হয়ে সান্ত্বনা দেয়। ইয়াতীম, সাহায্যপ্রার্থী ও নিয়ামতের কথা বর্ণিত।',

    // সূরা আশ-শারহ (আল-ইনশিরাহ)
    94: 'সূরা আশ-শারহ মক্কায় অবতীর্ণ। "শারহ" অর্থ প্রশস্ত করা - রাসূল (সা.)-এর বক্ষ প্রশস্ত করা। কষ্টের সাথে স্বস্তি এবং প্রতিটি কঠিন সময়ের পর সহজতার ওয়াদা। সূরা দুহার ধারাবাহিকতা।',

    // সূরা আত-তীন
    95: 'সূরা আত-তীন মক্কায় অবতীর্ণ। "তীন" অর্থ ডুমুর। তীন, যায়তূন, তূর সীনা ও মক্কার শপথ করে বলা হয়েছে মানুষ সর্বোত্তম আকৃতিতে সৃষ্ট। ঈমান ও সৎকর্ম ছাড়া মানুষ নিকৃষ্টতম অবস্থায় যায়।',

    // সূরা আল-আলাক
    96: 'সূরা আল-আলাক মক্কায় হেরা গুহায় সর্বপ্রথম অবতীর্ণ। রমজান মাসে জিব্রাইল (আ.) প্রথম এই সূরার প্রথম পাঁচ আয়াত নিয়ে আসেন। "ইকরা" (পড়ো) দিয়ে শুরু - ইসলামে জ্ঞানের গুরুত্ব প্রমাণ করে।',

    // সূরা আল-ক্বদর
    97: 'সূরা আল-ক্বদর মক্কায় অবতীর্ণ। লাইলাতুল ক্বদরের মর্যাদা ও ফজিলত বর্ণনা করা হয়েছে। এই রাতে কুরআন নাযিল শুরু হয়েছে এবং এটি হাজার মাসের চেয়ে উত্তম।',

    // সূরা আল-বাইয়্যিনা
    98: 'সূরা আল-বাইয়্যিনা মদীনায় অবতীর্ণ। "বাইয়্যিনা" অর্থ সুস্পষ্ট প্রমাণ। আহলে কিতাব ও মুশরিকরা স্পষ্ট প্রমাণ না আসা পর্যন্ত বিচ্ছিন্ন হয়নি। খাইরুল বারিয়্যা (সৃষ্টির সেরা) মুমিনদের বর্ণনা রয়েছে।',

    // সূরা আয-যিলযাল
    99: 'সূরা আয-যিলযাল মদীনায় অবতীর্ণ। "যিলযাল" অর্থ ভূমিকম্প - কিয়ামতের ভূমিকম্প। পৃথিবী তার সকল বোঝা বের করে দেবে এবং সাক্ষ্য দেবে। অণু পরিমাণ ভালো-মন্দও দেখানো হবে।',

    // সূরা আল-আদিয়াত
    100: 'সূরা আল-আদিয়াত মক্কায় অবতীর্ণ। "আদিয়াত" অর্থ দ্রুতগামী ঘোড়া। যুদ্ধের ঘোড়ার শপথ করে মানুষের অকৃতজ্ঞতা ও সম্পদ-লোভের নিন্দা করা হয়েছে। কবর থেকে উত্থান ও বিচারের কথা বর্ণিত।',

    // সূরা আল-ক্বারিআ
    101: 'সূরা আল-ক্বারিআ মক্কায় অবতীর্ণ। "ক্বারিআ" অর্থ মহাআঘাত - কিয়ামতের একটি নাম। সেদিন মানুষ বিক্ষিপ্ত পতঙ্গের মতো এবং পাহাড় ধুনা পশমের মতো হবে। পাল্লা ভারী ও হালকা হওয়ার বিবরণ।',

    // সূরা আত-তাকাসুর
    102: 'সূরা আত-তাকাসুর মক্কায় অবতীর্ণ। "তাকাসুর" অর্থ প্রাচুর্যের প্রতিযোগিতা। সম্পদ ও সন্তানের গর্ব মানুষকে কবর পর্যন্ত ব্যস্ত রাখে। সেদিন নিয়ামত সম্পর্কে জিজ্ঞাসা করা হবে।',

    // সূরা আল-ইখলাস
    112: 'সূরা আল-ইখলাস মক্কায় অবতীর্ণ। মুশরিকরা আল্লাহর পরিচয় জানতে চাইলে এই সূরা নাযিল হয়। এটি কুরআনের এক-তৃতীয়াংশের সমান। তাওহীদের সারসংক্ষেপ এই সূরায় রয়েছে।',

    // সূরা আল-ফালাক
    113: 'সূরা আল-ফালাক মদীনায় অবতীর্ণ। ইহুদী লাবীদ বিন আসাম রাসূল (সা.)-এর উপর জাদু করলে সূরা আল-ফালাক ও আন-নাস একসাথে নাযিল হয়। এই দুটি সূরাকে "মুআওয়িযাতাইন" (আশ্রয় প্রার্থনার দুটি সূরা) বলা হয়।',

    // সূরা আন-নাস
    114: 'সূরা আন-নাস মদীনায় অবতীর্ণ। সূরা আল-ফালাকের সাথে একসাথে নাযিল হয়েছে। জিন ও মানুষের শয়তানের কুমন্ত্রণা থেকে আল্লাহর কাছে আশ্রয় প্রার্থনা শেখানো হয়েছে।',

    // সূরা আল-কাওসার
    108: 'সূরা আল-কাওসার মক্কায় অবতীর্ণ। রাসূল (সা.)-এর পুত্র কাসেমের মৃত্যুর পর আস ইবনে ওয়ায়েল তাঁকে "আবতার" (নির্বংশ) বলে উপহাস করলে এই সূরা নাযিল হয়। কাওসার হলো জান্নাতের একটি নহর।',

    // সূরা আল-আসর
    103: 'সূরা আল-আসর মক্কায় অবতীর্ণ। ইমাম শাফেয়ী (রহ.) বলেছেন, "যদি শুধু এই সূরাটি নাযিল হতো, তাহলেও মানুষের হেদায়েতের জন্য যথেষ্ট হতো।" সাহাবীরা বিদায়ের সময় এই সূরা পাঠ করতেন।',

    // সূরা আল-হুমাযা
    104: 'সূরা আল-হুমাযা মক্কায় অবতীর্ণ। "হুমাযা" অর্থ পরনিন্দাকারী। যারা মানুষের দোষ খোঁজে, পেছনে সমালোচনা করে এবং সম্পদ জমা করে গর্ব করে - তাদের শাস্তির বিবরণ। "হুতামা" নামক জাহান্নামের উল্লেখ রয়েছে।',

    // সূরা আল-ফীল
    105: 'সূরা আল-ফীল মক্কায় অবতীর্ণ। রাসূল (সা.)-এর জন্মের বছর (৫৭০/৫৭১ খ্রি.) আবরাহা কাবা ধ্বংস করতে হাতির বাহিনী নিয়ে এসেছিল। আল্লাহ আবাবীল পাখি পাঠিয়ে তাদের ধ্বংস করেন। এই ঘটনা "আমুল ফীল" (হাতির বছর) নামে পরিচিত।',

    // সূরা কুরাইশ
    106: 'সূরা কুরাইশ মক্কায় অবতীর্ণ। সূরা আল-ফীলের ধারাবাহিকতায় নাযিল হয়েছে। কুরাইশদের শীত ও গ্রীষ্মের বাণিজ্য যাত্রার নিরাপত্তা আল্লাহর বিশেষ নিয়ামত - এজন্য তাদের কাবার রবের ইবাদত করা উচিত।',

    // সূরা আল-মাউন
    107: 'সূরা আল-মাউন মক্কায় অবতীর্ণ। ইয়াতীমদের সাথে দুর্ব্যবহার, নামাজে অবহেলা এবং প্রতিবেশীদের ছোটখাটো জিনিস ধার দিতে অস্বীকারকারীদের নিন্দা করা হয়েছে।',

    // সূরা আল-কাফিরুন
    109: 'সূরা আল-কাফিরুন মক্কায় অবতীর্ণ। কুরাইশ নেতারা প্রস্তাব দিয়েছিল যে, এক বছর তারা আল্লাহর ইবাদত করবে, পরের বছর মুহাম্মাদ (সা.) তাদের দেবতাদের পূজা করবেন। এর প্রত্যুত্তরে এই সূরা নাযিল হয়।',

    // সূরা আন-নাসর
    110: 'সূরা আন-নাসর মদীনায় অবতীর্ণ শেষ সূরা। বিদায় হজ্জের সময় মিনায় নাযিল হয়েছে। মক্কা বিজয়ের পর মানুষ দলে দলে ইসলামে প্রবেশ করছে - এই সুসংবাদ এবং রাসূল (সা.)-এর ওফাতের ইঙ্গিত রয়েছে।',

    // সূরা আল-মাসাদ
    111: 'সূরা আল-মাসাদ মক্কায় অবতীর্ণ। আবু লাহাব রাসূল (সা.)-এর চাচা হয়েও ইসলামের চরম বিরোধিতা করতেন। তার স্ত্রী উম্মে জামীল রাসূল (সা.)-এর চলার পথে কাঁটা বিছিয়ে রাখতেন। তাদের পরিণতি এই সূরায় বর্ণিত।',
  };

  // Shani Nuzul for specific ayahs (when available)
  static const Map<String, String> _ayahShaniNuzulData = {
    // সূরা আল-বাকারা - আয়াতুল কুরসী
    '2:255': 'আয়াতুল কুরসী কুরআনের সর্বশ্রেষ্ঠ আয়াত। রাসূল (সা.) উবাই ইবনে কাবকে জিজ্ঞেস করেছিলেন কুরআনের সবচেয়ে মর্যাদাপূর্ণ আয়াত কোনটি, তিনি এই আয়াতের কথা বলেন। ঘুমানোর আগে, ফরজ নামাজের পর পাঠে বিশেষ ফজিলত।',

    // সূরা আল-বাকারা - শেষ দুই আয়াত
    '2:285': 'মিরাজের রাতে রাসূল (সা.)-কে তিনটি উপহার দেওয়া হয়েছিল: পাঁচ ওয়াক্ত নামাজ, সূরা বাকারার শেষ দুই আয়াত, এবং শিরক ছাড়া সকল গুনাহ ক্ষমার ওয়াদা।',

    '2:286': 'এই আয়াত মুমিনদের জন্য সান্ত্বনা - আল্লাহ কাউকে তার সাধ্যের বাইরে দায়িত্ব দেন না। ভুল ও বিস্মৃতির জন্য শাস্তি নেই।',

    // সূরা আলে ইমরান - মুবাহালা আয়াত
    '3:61': 'নাজরানের খ্রিস্টান প্রতিনিধিদের সাথে মুবাহালার (পারস্পরিক অভিশাপ) চ্যালেঞ্জ দেওয়া হয়েছিল। তারা ভয়ে পিছিয়ে যায় এবং জিযিয়া দিতে রাজি হয়।',
  };

  /// Fetch a specific edition from the Al-Quran Cloud API
  Future<Map<String, dynamic>?> _fetchAlQuranCloudEdition(int surahNumber, String edition) async {
    try {
      final url = '$_alQuranCloudBaseUrl/surah/$surahNumber/$edition';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Error fetching edition $edition for surah $surahNumber: $e');
    }
    return null;
  }

  /// Fetch Arabic text and English translation from QuranEnc API (King Fahd Quran Complex)
  /// Returns a list of ayah data with arabic_text, translation, and footnotes
  Future<List<Map<String, dynamic>>?> _fetchFromQuranEncApi(int surahNumber, {String translationKey = 'english_saheeh'}) async {
    try {
      final url = '$_quranEncBaseUrl/translation/sura/$translationKey/$surahNumber';
      debugPrint('Fetching from QuranEnc: $url');

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 20),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'] as List<dynamic>?;
        if (result != null && result.isNotEmpty) {
          debugPrint('QuranEnc: Fetched ${result.length} ayahs for surah $surahNumber');
          return result.cast<Map<String, dynamic>>();
        }
      } else {
        debugPrint('QuranEnc API failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching from QuranEnc API: $e');
    }
    return null;
  }

  /// Load ayahs from local cache
  Future<List<Ayah>?> _loadFromLocalCache(int surahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'surah_${_cacheVersion}_$surahNumber';
      final cachedJson = prefs.getString(cacheKey);

      if (cachedJson != null) {
        final List<dynamic> jsonList = json.decode(cachedJson);
        return jsonList.map((j) => Ayah.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint('Error loading from cache: $e');
    }
    return null;
  }

  /// Save ayahs to local cache
  Future<void> _saveToLocalCache(int surahNumber, List<Ayah> ayahs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'surah_${_cacheVersion}_$surahNumber';
      final jsonList = ayahs.map((a) => a.toJson()).toList();
      await prefs.setString(cacheKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  /// Get surah info from Quran.com API
  Future<Map<String, dynamic>?> getSurahInfo(int surahNumber) async {
    try {
      final url = Uri.parse('$_quranComBaseUrl/chapters/$surahNumber?language=bn');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['chapter'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('Error fetching surah info: $e');
    }
    return null;
  }

  /// Get audio URL for a specific ayah
  /// Uses Quran.com API for high-quality audio
  String getAudioUrl(int surahNumber, int ayahNumber, {String reciter = 'ar.alafasy'}) {
    // Format: surah:ayah (e.g., 001001 for Al-Fatihah verse 1)
    final surahPadded = surahNumber.toString().padLeft(3, '0');
    final ayahPadded = ayahNumber.toString().padLeft(3, '0');
    return 'https://cdn.islamic.network/quran/audio/128/$reciter/$surahPadded$ayahPadded.mp3';
  }

  /// Get audio URL for entire surah
  String getSurahAudioUrl(int surahNumber, {String reciter = 'ar.alafasy'}) {
    return 'https://cdn.islamic.network/quran/audio-surah/128/$reciter/$surahNumber.mp3';
  }

  /// Get accurate Bengali transliteration for a verse
  String? _getAccurateBengaliTransliteration(int surahNumber, int ayahNumber) {
    final key = '$surahNumber:$ayahNumber';
    return _bengaliTransliterations[key];
  }

  /// Get accurate English transliteration for a verse
  String? _getAccurateEnglishTransliteration(int surahNumber, int ayahNumber) {
    final key = '$surahNumber:$ayahNumber';
    return _englishTransliterations[key];
  }

  /// Get fallback ayahs for demo when API fails
  List<Ayah> _getFallbackAyahs(int surahNumber) {
    if (surahNumber == 1) return AyahData.alFatihah;
    if (surahNumber == 112) return AyahData.alIkhlas;
    return AyahData.alFatihah;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    _ayahCache.clear();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('surah_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Preload surahs for offline access
  Future<void> preloadSurahs(List<int> surahNumbers) async {
    for (final surahNumber in surahNumbers) {
      await getAyahsForSurah(surahNumber);
    }
  }

  /// Get the "Verse of the Day"
  /// Selects a verse based on the current date so it remains consistent for the day
  Future<Ayah?> getDailyVerse() async {
    try {
      final now = DateTime.now();
      // Simple hash to pick a consistent verse for the day
      final index = (now.year * 1000 + now.month * 100 + now.day) % _inspirationalVerses.length;
      final verseRef = _inspirationalVerses[index];
      
      final surahNumber = verseRef['surah']!;
      final ayahNumber = verseRef['ayah']!;
      
      // Fetch surah data
      final ayahs = await getAyahsForSurah(surahNumber);
      
      // Return specific ayah
      return ayahs.firstWhere(
        (a) => a.numberInSurah == ayahNumber,
        orElse: () => ayahs.first,
      );
    } catch (e) {
      debugPrint('Error getting daily verse: $e');
      return AyahData.alFatihah[0]; // Fallback to Bismillah
    }
  }

  // Curated list of inspirational verses (Surah:Ayah)
  static const List<Map<String, int>> _inspirationalVerses = [
    {'surah': 1, 'ayah': 1},   // Al-Fatihah 1:1
    {'surah': 2, 'ayah': 152}, // Al-Baqarah 2:152 (Remember Me)
    {'surah': 2, 'ayah': 153}, // Al-Baqarah 2:153 (Patience & Prayer)
    {'surah': 2, 'ayah': 186}, // Al-Baqarah 2:186 (I am near)
    {'surah': 2, 'ayah': 255}, // Ayatul Kursi
    {'surah': 2, 'ayah': 286}, // Al-Baqarah 2:286 (Burden)
    {'surah': 3, 'ayah': 8},   // Al-Imran 3:8 (Hearts deviate)
    {'surah': 3, 'ayah': 139}, // Al-Imran 3:139 (Do not weaken)
    {'surah': 3, 'ayah': 159}, // Al-Imran 3:159 (Trust in Allah)
    {'surah': 4, 'ayah': 135}, // An-Nisa 4:135 (Justice)
    {'surah': 6, 'ayah': 17},  // Al-An'am 6:17 (Touch you with harm)
    {'surah': 7, 'ayah': 156}, // Al-A'raf 7:156 (My mercy)
    {'surah': 8, 'ayah': 46},  // Al-Anfal 8:46 (Patience)
    {'surah': 9, 'ayah': 40},  // At-Tawbah 9:40 (Allah is with us)
    {'surah': 9, 'ayah': 51},  // At-Tawbah 9:51 (Nothing will strike us)
    {'surah': 9, 'ayah': 129}, // At-Tawbah 9:129 (Allah is sufficient)
    {'surah': 13, 'ayah': 28}, // Ar-Ra'd 13:28 (Hearts find rest)
    {'surah': 14, 'ayah': 7},  // Ibrahim 14:7 (If you are grateful)
    {'surah': 15, 'ayah': 9},  // Al-Hijr 15:9 (We preserve Quran)
    {'surah': 15, 'ayah': 85}, // Al-Hijr 15:85 (Forgive with grace)
    {'surah': 16, 'ayah': 128},// An-Nahl 16:128 (Allah is with those who fear Him)
    {'surah': 18, 'ayah': 10}, // Al-Kahf 18:10 (Mercy from You)
    {'surah': 18, 'ayah': 46}, // Al-Kahf 18:46 (Good deeds remain)
    {'surah': 20, 'ayah': 25}, // Ta-Ha 20:25 (Expand my chest)
    {'surah': 21, 'ayah': 87}, // Al-Anbya 21:87 (La ilaha illa anta)
    {'surah': 23, 'ayah': 118},// Al-Mu'minun 23:118 (Forgive and have mercy)
    {'surah': 24, 'ayah': 35}, // An-Nur 24:35 (Light verse)
    {'surah': 25, 'ayah': 63}, // Al-Furqan 25:63 (Walk gently)
    {'surah': 28, 'ayah': 24}, // Al-Qasas 28:24 (In need of good)
    {'surah': 29, 'ayah': 45}, // Al-Ankabut 29:45 (Prayer prohibits immorality)
    {'surah': 29, 'ayah': 69}, // Al-Ankabut 29:69 (Strive for Us)
    {'surah': 39, 'ayah': 53}, // Az-Zumar 39:53 (Despair not of mercy)
    {'surah': 40, 'ayah': 60}, // Ghafir 40:60 (Call upon Me)
    {'surah': 41, 'ayah': 34}, // Fussilat 41:34 (Repel with good)
    {'surah': 49, 'ayah': 10}, // Al-Hujurat 49:10 (Believers are brothers)
    {'surah': 49, 'ayah': 13}, // Al-Hujurat 49:13 (Know each other)
    {'surah': 57, 'ayah': 4},  // Al-Hadid 57:4 (He is with you)
    {'surah': 59, 'ayah': 21}, // Al-Hashr 59:21 (Quran on mountain)
    {'surah': 65, 'ayah': 2},  // At-Talaq 65:2-3 (Way out)
    {'surah': 67, 'ayah': 13}, // Al-Mulk 67:13 (Knower of chests)
    {'surah': 94, 'ayah': 5},  // Ash-Sharh 94:5 (With hardship comes ease)
    {'surah': 94, 'ayah': 6},  // Ash-Sharh 94:6 (With hardship comes ease)
  ];

  // ============================================================
  // ACCURATE BENGALI TRANSLITERATIONS (উচ্চারণ)
  // Professionally transliterated following standard Bengali Quran
  // ============================================================
  static const Map<String, String> _bengaliTransliterations = {
    // সূরা আল-ফাতিহা (Surah 1)
    '1:1': 'বিসমিল্লা-হির রাহমা-নির রাহীম',
    '1:2': 'আলহামদু লিল্লা-হি রাব্বিল আ-লামীন',
    '1:3': 'আর রাহমা-নির রাহীম',
    '1:4': 'মা-লিকি ইয়াওমিদ্দীন',
    '1:5': 'ইয়্যা-কা নাবুদু ওয়া ইয়্যা-কা নাসতাঈন',
    '1:6': 'ইহদিনাস সিরা-তাল মুসতাকীম',
    '1:7': 'সিরা-তাল্লাযীনা আনআমতা আলাইহিম গাইরিল মাগদূবি আলাইহিম ওয়ালাদ্দ্বা-ল্লীন',

    // সূরা আল-ইখলাস (Surah 112)
    '112:1': 'কুল হুওয়াল্লা-হু আহাদ',
    '112:2': 'আল্লা-হুস সামাদ',
    '112:3': 'লাম ইয়ালিদ ওয়া লাম ইউলাদ',
    '112:4': 'ওয়া লাম ইয়াকুল্লাহূ কুফুওয়ান আহাদ',

    // সূরা আল-ফালাক (Surah 113)
    '113:1': 'কুল আঊযু বিরাব্বিল ফালাক্ব',
    '113:2': 'মিন শাররি মা- খালাক্ব',
    '113:3': 'ওয়া মিন শাররি গা-সিক্বিন ইযা- ওয়াক্বাব',
    '113:4': 'ওয়া মিন শাররিন নাফফা-সা-তি ফিল উক্বাদ',
    '113:5': 'ওয়া মিন শাররি হা-সিদিন ইযা- হাসাদ',

    // সূরা আন-নাস (Surah 114)
    '114:1': 'কুল আঊযু বিরাব্বিন না-স',
    '114:2': 'মালিকিন না-স',
    '114:3': 'ইলা-হিন না-স',
    '114:4': 'মিন শাররিল ওয়াসওয়া-সিল খান্না-স',
    '114:5': 'আল্লাযী ইউওয়াসউইসু ফী সুদূরিন না-স',
    '114:6': 'মিনাল জিন্নাতি ওয়ান না-স',

    // সূরা আল-কাওসার (Surah 108)
    '108:1': 'ইন্না- আতাইনা-কাল কাওসার',
    '108:2': 'ফাসাল্লি লিরাব্বিকা ওয়ানহার',
    '108:3': 'ইন্না শা-নিয়াকা হুওয়াল আবতার',

    // সূরা আল-আসর (Surah 103)
    '103:1': 'ওয়াল আসর',
    '103:2': 'ইন্নাল ইনসা-না লাফী খুসর',
    '103:3': 'ইল্লাল্লাযীনা আ-মানূ ওয়া আমিলুস সা-লিহা-তি ওয়া তাওয়া-সাও বিলহাক্বক্বি ওয়া তাওয়া-সাও বিস সাবর',

    // সূরা আল-হুমাযা (Surah 104)
    '104:1': 'ওয়াইলুল্লিকুল্লি হুমাযাতিল লুমাযাহ',
    '104:2': 'আল্লাযী জামাআ মা-লাওঁ ওয়া আদ্দাদাহ',
    '104:3': 'ইয়াহসাবু আন্না মা-লাহূ আখলাদাহ',
    '104:4': 'কাল্লা- লাইউম্বাযান্না ফিল হুতামাহ',
    '104:5': 'ওয়ামা- আদরা-কা মাল হুতামাহ',
    '104:6': 'না-রুল্লা-হিল মূক্বাদাহ',
    '104:7': 'আল্লাতী তাত্তালিউ আলাল আফইদাহ',
    '104:8': 'ইন্নাহা- আলাইহিম মুসাদাহ',
    '104:9': 'ফী আমাদিম মুমাদ্দাদাহ',

    // সূরা আল-ফীল (Surah 105)
    '105:1': 'আলাম তারা কাইফা ফাআলা রাব্বুকা বিআসহা-বিল ফীল',
    '105:2': 'আলাম ইয়াজআল কাইদাহুম ফী তাদলীল',
    '105:3': 'ওয়া আরসালা আলাইহিম তাইরান আবা-বীল',
    '105:4': 'তারমীহিম বিহিজা-রাতিম মিন সিজ্জীল',
    '105:5': 'ফাজাআলাহুম কাআসফিম মাকূল',

    // সূরা কুরাইশ (Surah 106)
    '106:1': 'লিঈলা-ফি কুরাইশ',
    '106:2': 'ঈলা-ফিহিম রিহলাতাশ শিতা-য়ি ওয়াস সাইফ',
    '106:3': 'ফালইয়াবুদূ রাব্বা হা-যাল বাইত',
    '106:4': 'আল্লাযী আতআমাহুম মিন জূইওঁ ওয়া আ-মানাহুম মিন খাওফ',

    // সূরা আল-মাউন (Surah 107)
    '107:1': 'আরাআইতাল্লাযী ইউকাযযিবু বিদ্দীন',
    '107:2': 'ফাযা-লিকাল্লাযী ইয়াদুউল ইয়াতীম',
    '107:3': 'ওয়া লা- ইয়াহুদ্দু আলা- তাআ-মিল মিসকীন',
    '107:4': 'ফাওয়াইলুল্লিল মুসাল্লীন',
    '107:5': 'আল্লাযীনা হুম আন সালা-তিহিম সা-হূন',
    '107:6': 'আল্লাযীনা হুম ইউরা-ঊন',
    '107:7': 'ওয়া ইয়ামনাঊনাল মা-ঊন',

    // সূরা আল-কাফিরুন (Surah 109)
    '109:1': 'কুল ইয়া- আইয়্যুহাল কা-ফিরূন',
    '109:2': 'লা- আবুদু মা- তাবুদূন',
    '109:3': 'ওয়ালা- আনতুম আ-বিদূনা মা- আবুদ',
    '109:4': 'ওয়ালা- আনা আ-বিদুম মা- আবাত্তুম',
    '109:5': 'ওয়ালা- আনতুম আ-বিদূনা মা- আবুদ',
    '109:6': 'লাকুম দীনুকুম ওয়ালিয়া দীন',

    // সূরা আন-নাসর (Surah 110)
    '110:1': 'ইযা- জা-আ নাসরুল্লা-হি ওয়াল ফাতহ',
    '110:2': 'ওয়া রাআইতান্না-সা ইয়াদখুলূনা ফী দীনিল্লা-হি আফওয়া-জা-',
    '110:3': 'ফাসাব্বিহ বিহামদি রাব্বিকা ওয়াসতাগফিরহু ইন্নাহূ কা-না তাওওয়া-বা-',

    // সূরা আল-মাসাদ (Surah 111)
    '111:1': 'তাব্বাত ইয়াদা- আবী লাহাবিওঁ ওয়া তাব্ব',
    '111:2': 'মা- আগনা- আনহু মা-লুহূ ওয়ামা- কাসাব',
    '111:3': 'সাইয়াসলা- না-রান যা-তা লাহাব',
    '111:4': 'ওয়ামরাআতুহূ হাম্মা-লাতাল হাতাব',
    '111:5': 'ফী জীদিহা- হাবলুম মিম মাসাদ',

    // সূরা আত-তাকাসুর (Surah 102)
    '102:1': 'আলহা-কুমুত তাকা-সুর',
    '102:2': 'হাত্তা- যুরতুমুল মাক্বা-বির',
    '102:3': 'কাল্লা- সাওফা তালামূন',
    '102:4': 'সুম্মা কাল্লা- সাওফা তালামূন',
    '102:5': 'কাল্লা- লাও তালামূনা ইলমাল ইয়াক্বীন',
    '102:6': 'লাতারাউন্নাল জাহীম',
    '102:7': 'সুম্মা লাতারাউন্নাহা- আইনাল ইয়াক্বীন',
    '102:8': 'সুম্মা লাতুসআলুন্না ইয়াওমাইযিন আনিন নাঈম',

    // সূরা আল-ক্বারিয়া (Surah 101)
    '101:1': 'আল ক্বা-রিআহ',
    '101:2': 'মাল ক্বা-রিআহ',
    '101:3': 'ওয়ামা- আদরা-কা মাল ক্বা-রিআহ',
    '101:4': 'ইয়াওমা ইয়াকূনুন্না-সু কালফারা-শিল মাবসূস',
    '101:5': 'ওয়া তাকূনুল জিবা-লু কালইহনিল মানফূশ',
    '101:6': 'ফাআম্মা- মান সাক্বুলাত মাওয়া-যীনুহূ',
    '101:7': 'ফাহুওয়া ফী ঈশাতির রা-দিয়াহ',
    '101:8': 'ওয়া আম্মা- মান খাফফাত মাওয়া-যীনুহূ',
    '101:9': 'ফাউম্মুহূ হা-বিয়াহ',
    '101:10': 'ওয়ামা- আদরা-কা মা- হিয়াহ',
    '101:11': 'না-রুন হা-মিয়াহ',

    // সূরা আল-আদিয়াত (Surah 100)
    '100:1': 'ওয়াল আ-দিয়া-তি দাবহা-',
    '100:2': 'ফাল মূরিয়া-তি ক্বাদহা-',
    '100:3': 'ফাল মুগীরা-তি সুবহা-',
    '100:4': 'ফাআসারনা বিহী নাক্বআ-',
    '100:5': 'ফাওয়াসাতনা বিহী জামআ-',
    '100:6': 'ইন্নাল ইনসা-না লিরাব্বিহী লাকানূদ',
    '100:7': 'ওয়া ইন্নাহূ আলা- যা-লিকা লাশাহীদ',
    '100:8': 'ওয়া ইন্নাহূ লিহুব্বিল খাইরি লাশাদীদ',
    '100:9': 'আফালা- ইয়ালামু ইযা- বুসিরা মা- ফিল ক্বুবূর',
    '100:10': 'ওয়া হুসসিলা মা- ফিস সুদূর',
    '100:11': 'ইন্না রাব্বাহুম বিহিম ইয়াওমাইযিল লাখাবীর',

    // সূরা আয-যিলযাল (Surah 99)
    '99:1': 'ইযা- যুলযিলাতিল আরদু যিলযা-লাহা-',
    '99:2': 'ওয়া আখরাজাতিল আরদু আসক্বা-লাহা-',
    '99:3': 'ওয়া ক্বা-লাল ইনসা-নু মা-লাহা-',
    '99:4': 'ইয়াওমাইযিন তুহাদ্দিসু আখবা-রাহা-',
    '99:5': 'বিআন্না রাব্বাকা আওহা- লাহা-',
    '99:6': 'ইয়াওমাইযিই ইয়াসদুরুন্না-সু আশতা-তাল লিইউরাও আমা-লাহুম',
    '99:7': 'ফামাই ইয়ামাল মিসক্বা-লা যাররাতিন খাইরাই ইয়ারাহ',
    '99:8': 'ওয়া মাই ইয়ামাল মিসক্বা-লা যাররাতিন শাররাই ইয়ারাহ',

    // সূরা আল-বাইয়্যিনাহ (Surah 98)
    '98:1': 'লাম ইয়াকুনিল্লাযীনা কাফারূ মিন আহলিল কিতা-বি ওয়াল মুশরিকীনা মুনফাক্কীনা হাত্তা- তাতিয়াহুমুল বাইয়িনাহ',
    '98:2': 'রাসূলুম মিনাল্লা-হি ইয়াতলূ সুহুফাম মুতাহহারাহ',
    '98:3': 'ফীহা- কুতুবুন ক্বাইয়িমাহ',
    '98:4': 'ওয়ামা- তাফাররাক্বাল্লাযীনা ঊতুল কিতা-বা ইল্লা- মিম বাদি মা- জা-আতহুমুল বাইয়িনাহ',
    '98:5': 'ওয়ামা- উমিরূ ইল্লা- লিইয়াবুদুল্লা-হা মুখলিসীনা লাহুদ্দীনা হুনাফা-আ ওয়া ইউক্বীমুস সালা-তা ওয়া ইউতুয যাকা-তা ওয়া যা-লিকা দীনুল ক্বাইয়িমাহ',
    '98:6': 'ইন্নাল্লাযীনা কাফারূ মিন আহলিল কিতা-বি ওয়াল মুশরিকীনা ফী না-রি জাহান্নামা খা-লিদীনা ফীহা- উলা-ইকা হুম শাররুল বারিয়্যাহ',
    '98:7': 'ইন্নাল্লাযীনা আ-মানূ ওয়া আমিলুস সা-লিহা-তি উলা-ইকা হুম খাইরুল বারিয়্যাহ',
    '98:8': 'জাযা-উহুম ইনদা রাব্বিহিম জান্না-তু আদনিন তাজরী মিন তাহতিহাল আনহা-রু খা-লিদীনা ফীহা- আবাদা- রাদিয়াল্লা-হু আনহুম ওয়া রাদূ আনহু যা-লিকা লিমান খাশিয়া রাব্বাহ',

    // সূরা আল-ক্বদর (Surah 97)
    '97:1': 'ইন্না- আনযালনা-হু ফী লাইলাতিল ক্বাদর',
    '97:2': 'ওয়ামা- আদরা-কা মা- লাইলাতুল ক্বাদর',
    '97:3': 'লাইলাতুল ক্বাদরি খাইরুম মিন আলফি শাহর',
    '97:4': 'তানাযযালুল মালা-ইকাতু ওয়ার রূহু ফীহা- বিইযনি রাব্বিহিম মিন কুল্লি আমর',
    '97:5': 'সালা-মুন হিয়া হাত্তা- মাতলাইল ফাজর',

    // সূরা আল-আলাক (Surah 96)
    '96:1': 'ইক্বরা বিসমি রাব্বিকাল্লাযী খালাক্ব',
    '96:2': 'খালাক্বাল ইনসা-না মিন আলাক্ব',
    '96:3': 'ইক্বরা ওয়া রাব্বুকাল আকরাম',
    '96:4': 'আল্লাযী আল্লামা বিলক্বালাম',
    '96:5': 'আল্লামাল ইনসা-না মা-লাম ইয়ালাম',
    '96:6': 'কাল্লা- ইন্নাল ইনসা-না লাইয়াতগা-',
    '96:7': 'আর রাআ-হুসতাগনা-',
    '96:8': 'ইন্না ইলা- রাব্বিকার রুজআ-',
    '96:9': 'আরাআইতাল্লাযী ইয়ানহা-',
    '96:10': 'আবদান ইযা- সাল্লা-',
    '96:11': 'আরাআইতা ইন কা-না আলাল হুদা-',
    '96:12': 'আও আমারা বিত্তাক্বওয়া-',
    '96:13': 'আরাআইতা ইন কাযযাবা ওয়া তাওয়াল্লা-',
    '96:14': 'আলাম ইয়ালাম বিআন্নাল্লা-হা ইয়ারা-',
    '96:15': 'কাল্লা- লাইল্লাম ইয়ানতাহি লানাসফাআম বিন্না-সিয়াহ',
    '96:16': 'না-সিয়াতিন কা-যিবাতিন খা-তিআহ',
    '96:17': 'ফালইয়াদউ না-দিয়াহ',
    '96:18': 'সানাদউয যাবা-নিয়াহ',
    '96:19': 'কাল্লা- লা- তুতিহু ওয়াসজুদ ওয়াক্বতারিব',

    // সূরা আত-তীন (Surah 95)
    '95:1': 'ওয়াত্তীনি ওয়ায যাইতূন',
    '95:2': 'ওয়া তূরি সীনীন',
    '95:3': 'ওয়া হা-যাল বালাদিল আমীন',
    '95:4': 'লাক্বাদ খালাক্বনাল ইনসা-না ফী আহসানি তাক্বউয়ীম',
    '95:5': 'সুম্মা রাদাদনা-হু আসফালা সা-ফিলীন',
    '95:6': 'ইল্লাল্লাযীনা আ-মানূ ওয়া আমিলুস সা-লিহা-তি ফালাহুম আজরুন গাইরু মামনূন',
    '95:7': 'ফামা- ইউকাযযিবুকা বাদু বিদ্দীন',
    '95:8': 'আলাইসাল্লা-হু বিআহকামিল হা-কিমীন',

    // সূরা আশ-শারহ (Surah 94)
    '94:1': 'আলাম নাশরাহ লাকা সাদরাক',
    '94:2': 'ওয়া ওয়াদানা- আনকা উইযরাক',
    '94:3': 'আল্লাযী আনক্বাদা যাহরাক',
    '94:4': 'ওয়া রাফানা- লাকা যিকরাক',
    '94:5': 'ফাইন্না মাআল উসরি ইউসরা-',
    '94:6': 'ইন্না মাআল উসরি ইউসরা-',
    '94:7': 'ফাইযা- ফারাগতা ফানসাব',
    '94:8': 'ওয়া ইলা- রাব্বিকা ফারগাব',

    // সূরা আদ-দুহা (Surah 93)
    '93:1': 'ওয়াদ্দুহা-',
    '93:2': 'ওয়াল্লাইলি ইযা- সাজা-',
    '93:3': 'মা- ওয়াদ্দাআকা রাব্বুকা ওয়ামা- ক্বালা-',
    '93:4': 'ওয়ালাল আ-খিরাতু খাইরুল্লাকা মিনাল ঊলা-',
    '93:5': 'ওয়া লাসাওফা ইউতীকা রাব্বুকা ফাতারদা-',
    '93:6': 'আলাম ইয়াজিদকা ইয়াতীমান ফাআ-ওয়া-',
    '93:7': 'ওয়া ওয়াজাদাকা দা-ল্লান ফাহাদা-',
    '93:8': 'ওয়া ওয়াজাদাকা আ-ইলান ফাআগনা-',
    '93:9': 'ফাআম্মাল ইয়াতীমা ফালা- তাক্বহার',
    '93:10': 'ওয়া আম্মাস সা-ইলা ফালা- তানহার',
    '93:11': 'ওয়া আম্মা- বিনিমাতি রাব্বিকা ফাহাদ্দিস',

    // সূরা আল-লাইল (Surah 92)
    '92:1': 'ওয়াল্লাইলি ইযা- ইয়াগশা-',
    '92:2': 'ওয়ান্নাহা-রি ইযা- তাজাল্লা-',
    '92:3': 'ওয়ামা- খালাক্বায যাকারা ওয়াল উনসা-',
    '92:4': 'ইন্না সাইয়াকুম লাশাত্তা-',
    '92:5': 'ফাআম্মা- মান আতা- ওয়াত্তাক্বা-',
    '92:6': 'ওয়া সাদ্দাক্বা বিল হুসনা-',
    '92:7': 'ফাসানুইয়াসসিরুহূ লিল ইউসরা-',
    '92:8': 'ওয়া আম্মা- মাম বাখিলা ওয়াসতাগনা-',
    '92:9': 'ওয়া কাযযাবা বিল হুসনা-',
    '92:10': 'ফাসানুইয়াসসিরুহূ লিল উসরা-',
    '92:11': 'ওয়ামা- ইউগনী আনহু মা-লুহূ ইযা- তারাদ্দা-',
    '92:12': 'ইন্না আলাইনা- লালহুদা-',
    '92:13': 'ওয়া ইন্না লানা- লাল আ-খিরাতা ওয়াল ঊলা-',
    '92:14': 'ফাআনযারতুকুম না-রান তালাযযা-',
    '92:15': 'লা- ইয়াসলা-হা- ইল্লাল আশক্বা-',
    '92:16': 'আল্লাযী কাযযাবা ওয়া তাওয়াল্লা-',
    '92:17': 'ওয়া সাইউজান্নাবুহাল আতক্বা-',
    '92:18': 'আল্লাযী ইউতী মা-লাহূ ইয়াতাযাক্কা-',
    '92:19': 'ওয়ামা- লিআহাদিন ইনদাহূ মিন নিমাতিন তুজযা-',
    '92:20': 'ইল্লাবতিগা-আ ওয়াজহি রাব্বিহিল আলা-',
    '92:21': 'ওয়া লাসাওফা ইয়ারদা-',

    // সূরা আশ-শামস (Surah 91)
    '91:1': 'ওয়াশ শামসি ওয়া দুহা-হা-',
    '91:2': 'ওয়াল ক্বামারি ইযা- তালা-হা-',
    '91:3': 'ওয়ান্নাহা-রি ইযা- জাল্লা-হা-',
    '91:4': 'ওয়াল্লাইলি ইযা- ইয়াগশা-হা-',
    '91:5': 'ওয়াস সামা-ই ওয়ামা- বানা-হা-',
    '91:6': 'ওয়াল আরদি ওয়ামা- তাহা-হা-',
    '91:7': 'ওয়া নাফসিওঁ ওয়ামা- সাওওয়া-হা-',
    '91:8': 'ফাআলহামাহা- ফুজূরাহা- ওয়া তাক্বওয়া-হা-',
    '91:9': 'ক্বাদ আফলাহা মান যাক্কা-হা-',
    '91:10': 'ওয়া ক্বাদ খা-বা মান দাস্সা-হা-',
    '91:11': 'কাযযাবাত সামূদু বিতাগওয়া-হা-',
    '91:12': 'ইযিম বাআসা আশক্বা-হা-',
    '91:13': 'ফাক্বা-লা লাহুম রাসূলুল্লা-হি না-ক্বাতাল্লা-হি ওয়া সুক্বইয়া-হা-',
    '91:14': 'ফাকাযযাবূহু ফাআক্বারূহা- ফাদামদামা আলাইহিম রাব্বুহুম বিযামবিহিম ফাসাওওয়া-হা-',
    '91:15': 'ওয়ালা- ইয়াখা-ফু উক্ববা-হা-',
  };

  // ============================================================
  // ACCURATE ENGLISH TRANSLITERATIONS
  // ============================================================
  static const Map<String, String> _englishTransliterations = {
    // Surah Al-Fatihah (1)
    '1:1': 'Bismillahir Rahmanir Raheem',
    '1:2': 'Alhamdu lillahi Rabbil Aalameen',
    '1:3': 'Ar-Rahmanir Raheem',
    '1:4': 'Maliki Yawmid-Deen',
    '1:5': "Iyyaka na'budu wa iyyaka nasta'een",
    '1:6': 'Ihdinas-Siratal Mustaqeem',
    '1:7': "Siratal ladhina an'amta 'alayhim ghayril maghdubi 'alayhim wa lad-dalleen",

    // Surah Al-Ikhlas (112)
    '112:1': 'Qul Huwal-lahu Ahad',
    '112:2': 'Allahus-Samad',
    '112:3': 'Lam yalid wa lam yulad',
    '112:4': 'Wa lam yakul-lahu kufuwan ahad',

    // Surah Al-Falaq (113)
    '113:1': "Qul a'udhu bi-Rabbil-falaq",
    '113:2': 'Min sharri ma khalaq',
    '113:3': 'Wa min sharri ghasiqin idha waqab',
    '113:4': "Wa min sharrin-naffathati fil-'uqad",
    '113:5': 'Wa min sharri hasidin idha hasad',

    // Surah An-Nas (114)
    '114:1': "Qul a'udhu bi-Rabbin-nas",
    '114:2': 'Malikin-nas',
    '114:3': 'Ilahin-nas',
    '114:4': 'Min sharril-waswasil-khannas',
    '114:5': 'Alladhi yuwaswisu fi sudurin-nas',
    '114:6': 'Minal-jinnati wan-nas',

    // Surah Al-Kawthar (108)
    '108:1': "Inna a'taynakal Kawthar",
    '108:2': 'Fa-salli li-Rabbika wanhar',
    '108:3': 'Inna shani-aka huwal abtar',

    // Surah Al-Asr (103)
    '103:1': "Wal-'Asr",
    '103:2': 'Innal-insana lafi khusr',
    '103:3': "Illal-ladhina amanu wa 'amilus-salihati wa tawasau bil-haqqi wa tawasau bis-sabr",

    // Surah Al-Humazah (104)
    '104:1': 'Waylul-likulli humazatil-lumazah',
    '104:2': "Alladhi jama'a malaow wa 'addadah",
    '104:3': 'Yahsabu anna malahu akhladah',
    '104:4': 'Kalla la-yunbadhanna fil-hutamah',
    '104:5': 'Wa ma adraka mal-hutamah',
    '104:6': 'Narullahil-muqadah',
    '104:7': "Allati tattali'u 'alal-af'idah",
    '104:8': "Innaha 'alayhim mu'sadah",
    '104:9': "Fi 'amadim-mumaddadah",

    // Surah Al-Fil (105)
    '105:1': "Alam tara kayfa fa'ala Rabbuka bi-ashabil-fil",
    '105:2': "Alam yaj'al kaydahum fi tadlil",
    '105:3': "Wa arsala 'alayhim tayran ababil",
    '105:4': 'Tarmihim bi-hijaratim-min-sijjil',
    '105:5': "Faja'alahum ka'asfim-ma'kul",

    // Surah Quraysh (106)
    '106:1': "Li-ilafi Quraysh",
    '106:2': "Ilafihim rihlatash-shita'i was-sayf",
    '106:3': "Falya'budu Rabba hadhal-bayt",
    '106:4': "Alladhi at'amahum-min ju'iw wa amanahum-min khawf",

    // Surah Al-Ma'un (107)
    '107:1': "Ara'aytal-ladhi yukadh-dhibu bid-din",
    '107:2': 'Fadhalikallazhi yadu\'ul-yatim',
    '107:3': "Wa la yahuddu 'ala ta'amil-miskin",
    '107:4': 'Fa waylul-lil-musallin',
    '107:5': 'Alladhina hum an-salatihim sahun',
    '107:6': 'Alladhina hum yura-un',
    '107:7': "Wa yamna'unal-ma'un",

    // Surah Al-Kafirun (109)
    '109:1': 'Qul ya ayyuhal-kafirun',
    '109:2': "La a'budu ma ta'budun",
    '109:3': "Wa la antum 'abiduna ma a'bud",
    '109:4': "Wa la ana 'abidun-ma 'abadtum",
    '109:5': "Wa la antum 'abiduna ma a'bud",
    '109:6': 'Lakum dinukum wa liya din',

    // Surah An-Nasr (110)
    '110:1': 'Idha ja-a nasrullahi wal-fath',
    '110:2': "Wa ra-aitan-nasa yadkhuluna fi dinillahi afwaja",
    '110:3': 'Fa sabbih bi-hamdi Rabbika was-taghfirhu innahu kana tawwaba',

    // Surah Al-Masad (111)
    '111:1': 'Tabbat yada Abi Lahabiw-wa tabb',
    '111:2': "Ma aghna 'anhu maluhu wa ma kasab",
    '111:3': 'Sa-yasla naran dhata lahab',
    '111:4': "Wam-ra'atuhu hammalatal-hatab",
    '111:5': 'Fi jidiha hablum-mim-masad',

    // Surah Al-Qadr (97)
    '97:1': 'Inna anzalnahu fi laylatil-qadr',
    '97:2': 'Wa ma adraka ma laylatul-qadr',
    '97:3': 'Laylatul-qadri khayrum-min alfi shahr',
    '97:4': "Tanazzalul-mala'ikatu war-ruhu fiha bi-idhni Rabbihim-min kulli amr",
    '97:5': "Salamun hiya hatta matla'il-fajr",
  };
}

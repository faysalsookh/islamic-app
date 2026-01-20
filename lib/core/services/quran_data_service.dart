import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ayah.dart';
import '../data/shohoz_quran_transliterations.dart';
import 'transliteration_service.dart';

/// Service for fetching and caching Quran data from APIs
/// Uses Al-Quran Cloud API for comprehensive Quran data
/// Bengali translation: Muhiuddin Khan (bn.bengali)
/// English translation: Sahih International (en.sahih)
/// Bengali transliteration: Fetched from API and converted to Bengali script
class QuranDataService extends ChangeNotifier {
  static final QuranDataService _instance = QuranDataService._internal();
  factory QuranDataService() => _instance;
  QuranDataService._internal();

  // Transliteration service for API-based transliterations
  final TransliterationService _transliterationService = TransliterationService();

  // Cache for loaded surahs
  final Map<int, List<Ayah>> _ayahCache = {};
  bool _isLoading = false;
  String? _error;

  // API endpoints - Al-Quran Cloud API
  static const String _baseUrl = 'https://api.alquran.cloud/v1';

  // Bengali translation by Muhiuddin Khan - Most popular Bengali translation
  static const String _bengaliTranslationEdition = 'bn.bengali';

  // English translation - Sahih International
  static const String _englishTranslationEdition = 'en.sahih';

  // Arabic text - Uthmani script
  static const String _arabicEdition = 'quran-uthmani';

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

  /// Fetch surah data from API with Arabic, Bengali, English, and Transliteration
  Future<List<Ayah>> _fetchSurahFromApi(int surahNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all editions in parallel for better performance
      // Including English transliteration for conversion to Bengali
      final results = await Future.wait([
        _fetchEdition(surahNumber, _arabicEdition),
        _fetchEdition(surahNumber, _bengaliTranslationEdition),
        _fetchEdition(surahNumber, _englishTranslationEdition),
        _fetchEdition(surahNumber, 'en.transliteration'), // For Bengali transliteration
      ]);

      final arabicData = results[0];
      final bengaliData = results[1];
      final englishData = results[2];
      final transliterationData = results[3];

      if (arabicData == null) {
        throw Exception('Failed to fetch Arabic text');
      }

      // Build ayah list combining all editions
      final List<Ayah> ayahs = [];
      final arabicAyahs = arabicData['ayahs'] as List;

      for (int i = 0; i < arabicAyahs.length; i++) {
        final arabicAyah = arabicAyahs[i];
        final bengaliAyah = bengaliData != null && i < (bengaliData['ayahs'] as List).length
            ? (bengaliData['ayahs'] as List)[i]
            : null;
        final englishAyah = englishData != null && i < (englishData['ayahs'] as List).length
            ? (englishData['ayahs'] as List)[i]
            : null;
        final translitAyah = transliterationData != null && i < (transliterationData['ayahs'] as List).length
            ? (transliterationData['ayahs'] as List)[i]
            : null;

        final ayahNumberInSurah = arabicAyah['numberInSurah'] as int;

        // Get Bengali transliteration:
        // Priority 1: সহজ কুরআন (Shohoz Quran) - Most accurate
        // Priority 2: Pre-defined transliterations
        // Priority 3: API conversion (fallback)
        String? bengaliTranslit = ShohozQuranTransliterations.getTransliteration(surahNumber, ayahNumberInSurah);
        bengaliTranslit ??= _getAccurateBengaliTransliteration(surahNumber, ayahNumberInSurah);
        final englishTranslit = translitAyah?['text'] as String?;

        // If no pre-defined Bengali transliteration, convert from English API
        if (bengaliTranslit == null && englishTranslit != null) {
          bengaliTranslit = _transliterationService.convertToBengali(englishTranslit);
        }

        final ayah = Ayah(
          number: arabicAyah['number'] as int,
          numberInSurah: ayahNumberInSurah,
          surahNumber: surahNumber,
          textArabic: arabicAyah['text'] as String,
          textWithTajweed: _generateTajweedMarkup(arabicAyah['text'] as String),
          translationBengali: bengaliAyah?['text'] as String?,
          translationEnglish: englishAyah?['text'] as String?,
          transliterationBengali: bengaliTranslit,
          transliterationEnglish: englishTranslit ?? _getAccurateEnglishTransliteration(surahNumber, ayahNumberInSurah),
          juz: arabicAyah['juz'] as int? ?? 1,
          page: arabicAyah['page'] as int? ?? 1,
          hizbQuarter: arabicAyah['hizbQuarter'] as int? ?? 1,
        );
        ayahs.add(ayah);
      }

      // Cache the result
      _ayahCache[surahNumber] = ayahs;
      await _saveToLocalCache(surahNumber, ayahs);

      _isLoading = false;
      notifyListeners();
      return ayahs;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('Error fetching surah $surahNumber: $e');

      // Return fallback data for demo surahs
      return _getFallbackAyahs(surahNumber);
    }
  }

  /// Fetch a specific edition from the API
  Future<Map<String, dynamic>?> _fetchEdition(int surahNumber, String edition) async {
    try {
      final url = '$_baseUrl/surah/$surahNumber/$edition';
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

  /// Load ayahs from local cache
  Future<List<Ayah>?> _loadFromLocalCache(int surahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'surah_v4_$surahNumber'; // v3 for API-based transliterations
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
      final cacheKey = 'surah_v4_$surahNumber';
      final jsonList = ayahs.map((a) => a.toJson()).toList();
      await prefs.setString(cacheKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  /// Generate Tajweed markup for Arabic text
  String _generateTajweedMarkup(String arabicText) {
    String result = arabicText;

    // Ghunnah - noon and meem with shaddah
    result = result.replaceAllMapped(
      RegExp(r'(نّ|مّ)'),
      (m) => '<ghunnah>${m.group(0)}</ghunnah>',
    );

    // Qalqalah letters with sukoon (ق ط ب ج د)
    result = result.replaceAllMapped(
      RegExp(r'([قطبجد]ْ)'),
      (m) => '<qalqalah>${m.group(0)}</qalqalah>',
    );

    // Madd - elongation
    result = result.replaceAllMapped(
      RegExp(r'(َا|ُو|ِي|آ|ٰ)'),
      (m) => '<madd>${m.group(0)}</madd>',
    );

    // Ikhfa - noon sakinah before specific letters
    result = result.replaceAllMapped(
      RegExp(r'(نْ[تثجدذزسشصضطظفقك]|ً[تثجدذزسشصضطظفقك]|ٌ[تثجدذزسشصضطظفقك]|ٍ[تثجدذزسشصضطظفقك])'),
      (m) => '<ikhfa>${m.group(0)}</ikhfa>',
    );

    // Iqlab - noon sakinah or tanween before ba
    result = result.replaceAllMapped(
      RegExp(r'(نْب|ًب|ٌب|ٍب)'),
      (m) => '<iqlab>${m.group(0)}</iqlab>',
    );

    // Idgham - noon sakinah merging with ي ن م و ل ر
    result = result.replaceAllMapped(
      RegExp(r'(نْ[ينمولر]|ً[ينمولر]|ٌ[ينمولر]|ٍ[ينمولر])'),
      (m) => '<idgham>${m.group(0)}</idgham>',
    );

    // Izhar - noon sakinah before throat letters
    result = result.replaceAllMapped(
      RegExp(r'(نْ[ءهعحغخ]|ً[ءهعحغخ]|ٌ[ءهعحغخ]|ٍ[ءهعحغخ])'),
      (m) => '<izhar>${m.group(0)}</izhar>',
    );

    // Safir - whistling letters (ص ز س) with sukoon
    result = result.replaceAllMapped(
      RegExp(r'([صزس]ْ)'),
      (m) => '<safir>${m.group(0)}</safir>',
    );

    return result;
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

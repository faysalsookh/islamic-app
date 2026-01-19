import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ayah.dart';

/// Service for fetching and caching Quran data from APIs
/// Uses Al-Quran Cloud API for comprehensive Quran data
class QuranDataService extends ChangeNotifier {
  static final QuranDataService _instance = QuranDataService._internal();
  factory QuranDataService() => _instance;
  QuranDataService._internal();

  // Cache for loaded surahs
  final Map<int, List<Ayah>> _ayahCache = {};
  bool _isLoading = false;
  String? _error;

  // API endpoints
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const String _bengaliEdition = 'bn.bengali'; // Bengali translation
  static const String _englishEdition = 'en.sahih'; // Sahih International
  static const String _arabicEdition = 'quran-uthmani'; // Uthmani text

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

  /// Fetch surah data from API with Arabic, Bengali, and English
  Future<List<Ayah>> _fetchSurahFromApi(int surahNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all editions in parallel for better performance
      final results = await Future.wait([
        _fetchEdition(surahNumber, _arabicEdition),
        _fetchEdition(surahNumber, _bengaliEdition),
        _fetchEdition(surahNumber, _englishEdition),
      ]);

      final arabicData = results[0];
      final bengaliData = results[1];
      final englishData = results[2];

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

        final ayah = Ayah(
          number: arabicAyah['number'] as int,
          numberInSurah: arabicAyah['numberInSurah'] as int,
          surahNumber: surahNumber,
          textArabic: arabicAyah['text'] as String,
          textWithTajweed: _generateTajweedMarkup(arabicAyah['text'] as String),
          translationBengali: bengaliAyah?['text'] as String?,
          translationEnglish: englishAyah?['text'] as String?,
          transliterationBengali: _generateBengaliTransliteration(
            arabicAyah['text'] as String,
            arabicAyah['numberInSurah'] as int,
            surahNumber,
          ),
          transliterationEnglish: _generateEnglishTransliteration(
            arabicAyah['text'] as String,
            arabicAyah['numberInSurah'] as int,
            surahNumber,
          ),
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
      final cacheKey = 'surah_$surahNumber';
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
      final cacheKey = 'surah_$surahNumber';
      final jsonList = ayahs.map((a) => a.toJson()).toList();
      await prefs.setString(cacheKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  /// Generate Tajweed markup for Arabic text
  /// This applies basic Tajweed color rules based on letter patterns
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

    // Madd - elongation (alif, waw, ya with preceding fatha, damma, kasra)
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

  /// Generate Bengali transliteration from Arabic text
  /// This provides basic phonetic mapping
  String _generateBengaliTransliteration(String arabicText, int ayahNumber, int surahNumber) {
    // Return pre-defined transliterations for known surahs
    final transliteration = _getBengaliTransliterationData(surahNumber, ayahNumber);
    if (transliteration != null) return transliteration;

    // For other verses, return a placeholder indicating transliteration is loading
    return _arabicToBengaliBasic(arabicText);
  }

  /// Generate English transliteration from Arabic text
  String _generateEnglishTransliteration(String arabicText, int ayahNumber, int surahNumber) {
    final transliteration = _getEnglishTransliterationData(surahNumber, ayahNumber);
    if (transliteration != null) return transliteration;

    return _arabicToEnglishBasic(arabicText);
  }

  /// Basic Arabic to Bengali phonetic mapping
  String _arabicToBengaliBasic(String arabic) {
    final Map<String, String> mapping = {
      'ا': 'আ', 'أ': 'আ', 'إ': 'ই', 'آ': 'আ',
      'ب': 'ব', 'ت': 'ত', 'ث': 'স',
      'ج': 'জ', 'ح': 'হ', 'خ': 'খ',
      'د': 'দ', 'ذ': 'য', 'ر': 'র',
      'ز': 'য', 'س': 'স', 'ش': 'শ',
      'ص': 'স', 'ض': 'দ', 'ط': 'ত',
      'ظ': 'য', 'ع': 'আ', 'غ': 'গ',
      'ف': 'ফ', 'ق': 'ক', 'ك': 'ক',
      'ل': 'ল', 'م': 'ম', 'ن': 'ন',
      'ه': 'হ', 'و': 'ও', 'ي': 'ই',
      'ء': '', 'ئ': 'ই', 'ؤ': 'উ',
      'ى': 'আ', 'ة': 'হ',
      'َ': 'া', 'ُ': 'ু', 'ِ': 'ি',
      'ْ': '', 'ّ': '', 'ً': 'ন', 'ٌ': 'ন', 'ٍ': 'ন',
      ' ': ' ',
    };

    StringBuffer result = StringBuffer();
    for (int i = 0; i < arabic.length; i++) {
      final char = arabic[i];
      result.write(mapping[char] ?? char);
    }
    return result.toString();
  }

  /// Basic Arabic to English phonetic mapping
  String _arabicToEnglishBasic(String arabic) {
    final Map<String, String> mapping = {
      'ا': 'a', 'أ': 'a', 'إ': 'i', 'آ': 'aa',
      'ب': 'b', 'ت': 't', 'ث': 'th',
      'ج': 'j', 'ح': 'h', 'خ': 'kh',
      'د': 'd', 'ذ': 'dh', 'ر': 'r',
      'ز': 'z', 'س': 's', 'ش': 'sh',
      'ص': 's', 'ض': 'd', 'ط': 't',
      'ظ': 'z', 'ع': "'", 'غ': 'gh',
      'ف': 'f', 'ق': 'q', 'ك': 'k',
      'ل': 'l', 'م': 'm', 'ن': 'n',
      'ه': 'h', 'و': 'w', 'ي': 'y',
      'ء': "'", 'ئ': 'i', 'ؤ': 'u',
      'ى': 'a', 'ة': 'h',
      'َ': 'a', 'ُ': 'u', 'ِ': 'i',
      'ْ': '', 'ّ': '', 'ً': 'an', 'ٌ': 'un', 'ٍ': 'in',
      ' ': ' ',
    };

    StringBuffer result = StringBuffer();
    for (int i = 0; i < arabic.length; i++) {
      final char = arabic[i];
      result.write(mapping[char] ?? '');
    }
    return result.toString();
  }

  /// Get pre-defined Bengali transliteration for known verses
  String? _getBengaliTransliterationData(int surahNumber, int ayahNumber) {
    final key = '$surahNumber:$ayahNumber';
    return _bengaliTransliterations[key];
  }

  /// Get pre-defined English transliteration for known verses
  String? _getEnglishTransliterationData(int surahNumber, int ayahNumber) {
    final key = '$surahNumber:$ayahNumber';
    return _englishTransliterations[key];
  }

  /// Get fallback ayahs for demo when API fails
  List<Ayah> _getFallbackAyahs(int surahNumber) {
    if (surahNumber == 1) return AyahData.alFatihah;
    if (surahNumber == 112) return AyahData.alIkhlas;
    // Return Al-Fatihah as default fallback
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

  /// Pre-defined Bengali transliterations for common verses
  static const Map<String, String> _bengaliTransliterations = {
    // Al-Fatihah
    '1:1': 'বিসমিল্লাহির রাহমানির রাহীম',
    '1:2': 'আলহামদু লিল্লাহি রাব্বিল আলামীন',
    '1:3': 'আর-রাহমানির রাহীম',
    '1:4': 'মালিকি ইয়াওমিদ্দীন',
    '1:5': 'ইয়্যাকা না\'বুদু ওয়া ইয়্যাকা নাসতাঈন',
    '1:6': 'ইহদিনাস সিরাতাল মুস্তাকীম',
    '1:7': 'সিরাতাল লাযীনা আন\'আমতা আলাইহিম গাইরিল মাগদূবি আলাইহিম ওয়ালাদ দ্বাল্লীন',
    // Al-Ikhlas
    '112:1': 'কুল হুওয়াল্লাহু আহাদ',
    '112:2': 'আল্লাহুস সামাদ',
    '112:3': 'লাম ইয়ালিদ ওয়া লাম ইউলাদ',
    '112:4': 'ওয়া লাম ইয়াকুন লাহু কুফুওয়ান আহাদ',
    // Al-Falaq
    '113:1': 'কুল আউযু বিরাব্বিল ফালাক্ব',
    '113:2': 'মিন শাররি মা খালাক্ব',
    '113:3': 'ওয়া মিন শাররি গাসিক্বিন ইযা ওয়াক্বাব',
    '113:4': 'ওয়া মিন শাররিন নাফফাসাতি ফিল উক্বাদ',
    '113:5': 'ওয়া মিন শাররি হাসিদিন ইযা হাসাদ',
    // An-Nas
    '114:1': 'কুল আউযু বিরাব্বিন নাস',
    '114:2': 'মালিকিন নাস',
    '114:3': 'ইলাহিন নাস',
    '114:4': 'মিন শাররিল ওয়াসওয়াসিল খান্নাস',
    '114:5': 'আল্লাযী ইউওয়াসউইসু ফী সুদুরিন নাস',
    '114:6': 'মিনাল জিন্নাতি ওয়ান নাস',
    // Al-Kawthar
    '108:1': 'ইন্না আ\'তাইনাকাল কাওসার',
    '108:2': 'ফাসাল্লি লিরাব্বিকা ওয়ানহার',
    '108:3': 'ইন্না শানিআকা হুওয়াল আবতার',
    // Al-Asr
    '103:1': 'ওয়াল আসর',
    '103:2': 'ইন্নাল ইনসানা লাফী খুসর',
    '103:3': 'ইল্লাল্লাযীনা আমানু ওয়া আমিলুস সালিহাতি ওয়া তাওয়াসাও বিল হাক্কি ওয়া তাওয়াসাও বিস সাবর',
  };

  /// Pre-defined English transliterations for common verses
  static const Map<String, String> _englishTransliterations = {
    // Al-Fatihah
    '1:1': 'Bismillahir Rahmanir Raheem',
    '1:2': 'Alhamdu lillahi Rabbil Aalameen',
    '1:3': 'Ar-Rahmanir Raheem',
    '1:4': 'Maliki Yawmid-Deen',
    '1:5': "Iyyaka na'budu wa iyyaka nasta'een",
    '1:6': 'Ihdinas-Siratal Mustaqeem',
    '1:7': "Siratal lazeena an'amta alaihim, ghairil maghdoobi alaihim wa lad-daalleen",
    // Al-Ikhlas
    '112:1': 'Qul Huwal-lahu Ahad',
    '112:2': 'Allahus-Samad',
    '112:3': 'Lam yalid wa lam yoolad',
    '112:4': 'Wa lam yakun lahu kufuwan ahad',
    // Al-Falaq
    '113:1': "Qul a'udhu bi-Rabbil-falaq",
    '113:2': 'Min sharri ma khalaq',
    '113:3': 'Wa min sharri ghasiqin idha waqab',
    '113:4': "Wa min sharrin-naffathati fil-'uqad",
    '113:5': 'Wa min sharri hasidin idha hasad',
    // An-Nas
    '114:1': "Qul a'udhu bi-Rabbin-nas",
    '114:2': 'Malikin-nas',
    '114:3': 'Ilahin-nas',
    '114:4': 'Min sharril-waswasil-khannas',
    '114:5': 'Alladhi yuwaswisu fi sudurin-nas',
    '114:6': 'Minal-jinnati wan-nas',
    // Al-Kawthar
    '108:1': "Inna a'taynakal Kawthar",
    '108:2': 'Fa-salli li-Rabbika wanhar',
    '108:3': 'Inna shani-aka huwal abtar',
    // Al-Asr
    '103:1': "Wal-'Asr",
    '103:2': 'Innal-insana lafi khusr',
    '103:3': "Illal-ladhina amanu wa 'amilus-salihati wa tawasau bil-haqqi wa tawasau bis-sabr",
  };
}

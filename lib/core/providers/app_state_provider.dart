import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../models/bookmark.dart';
import '../models/reading_progress.dart';
import '../services/audio_service.dart';
import '../services/quran_data_service.dart';

/// Available Arabic font styles
enum ArabicFontStyle {
  amiri,
  scheherazade,
  lateef,
  uthmani,
  indopak,
}

extension ArabicFontStyleExtension on ArabicFontStyle {
  String get displayName {
    switch (this) {
      case ArabicFontStyle.amiri:
        return 'Amiri';
      case ArabicFontStyle.scheherazade:
        return 'Scheherazade';
      case ArabicFontStyle.lateef:
        return 'Lateef';
      case ArabicFontStyle.uthmani:
        return 'Uthmani';
      case ArabicFontStyle.indopak:
        return 'IndoPak (Naskh)';
    }
  }

  String get fontFamily {
    switch (this) {
      case ArabicFontStyle.amiri:
        return 'Amiri';
      case ArabicFontStyle.scheherazade:
        return 'Scheherazade';
      case ArabicFontStyle.lateef:
        return 'Lateef';
      case ArabicFontStyle.uthmani:
        return 'Amiri'; // Fallback to Amiri for now
      case ArabicFontStyle.indopak:
        return 'Scheherazade'; // Fallback for now
    }
  }
}

/// Available translation languages
enum TranslationLanguage {
  english,
  bengali,
  both,
  none,
}

extension TranslationLanguageExtension on TranslationLanguage {
  String get displayName {
    switch (this) {
      case TranslationLanguage.english:
        return 'English';
      case TranslationLanguage.bengali:
        return 'Bengali (বাংলা)';
      case TranslationLanguage.both:
        return 'Both';
      case TranslationLanguage.none:
        return 'None';
    }
  }
}

/// Available transliteration languages
enum TransliterationLanguage {
  english,
  bengali,
  both,
  none,
}

extension TransliterationLanguageExtension on TransliterationLanguage {
  String get displayName {
    switch (this) {
      case TransliterationLanguage.english:
        return 'English';
      case TransliterationLanguage.bengali:
        return 'Bengali (বাংলা)';
      case TransliterationLanguage.both:
        return 'Both';
      case TransliterationLanguage.none:
        return 'None';
    }
  }
}

/// Main app state provider
class AppStateProvider extends ChangeNotifier {
  // ============== THEME STATE ==============
  AppThemeMode _themeMode = AppThemeMode.light;
  AppThemeMode get themeMode => _themeMode;

  // ============== FONT SETTINGS ==============
  double _quranFontSize = QuranFontSizes.medium;
  double get quranFontSize => _quranFontSize;

  double _quranLineHeight = QuranLineHeights.normal;
  double get quranLineHeight => _quranLineHeight;

  ArabicFontStyle _arabicFontStyle = ArabicFontStyle.amiri;
  ArabicFontStyle get arabicFontStyle => _arabicFontStyle;

  // ============== READING SETTINGS ==============
  TranslationLanguage _translationLanguage = TranslationLanguage.bengali;
  TranslationLanguage get translationLanguage => _translationLanguage;

  TransliterationLanguage _transliterationLanguage = TransliterationLanguage.bengali;
  TransliterationLanguage get transliterationLanguage => _transliterationLanguage;

  int _selectedBengaliTranslationId = 161; // Default to Taisirul Quran
  int get selectedBengaliTranslationId => _selectedBengaliTranslationId;

  bool _showTranslation = true;
  bool get showTranslation => _showTranslation;

  bool _showTransliteration = true;
  bool get showTransliteration => _showTransliteration;

  bool _isMushafView = false; // false = Ayah list view, true = Mushaf view
  bool get isMushafView => _isMushafView;

  bool _isLeftHanded = false;
  bool get isLeftHanded => _isLeftHanded;

  // ============== TAJWEED SETTINGS ==============
  bool _showTajweedColors = true;
  bool get showTajweedColors => _showTajweedColors;

  bool _tajweedLearningMode = true;
  bool get tajweedLearningMode => _tajweedLearningMode;

  // ============== USER STATE ==============
  String _userName = '';
  String get userName => _userName;

  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  // ============== READING PROGRESS ==============
  ReadingProgress _readingProgress = ReadingProgress.sampleProgress;
  ReadingProgress get readingProgress => _readingProgress;

  // ============== BOOKMARKS ==============
  List<Bookmark> _bookmarks = BookmarkData.sampleBookmarks;
  List<Bookmark> get bookmarks => _bookmarks;

  // ============== AUDIO SETTINGS ==============
  Reciter _selectedReciter = Reciter.misharyRashidAlafasy;
  Reciter get selectedReciter => _selectedReciter;

  BengaliAudioSource _bengaliAudioSource = BengaliAudioSource.humanVoice;
  BengaliAudioSource get bengaliAudioSource => _bengaliAudioSource;

  double _defaultPlaybackSpeed = 1.0;
  double get defaultPlaybackSpeed => _defaultPlaybackSpeed;

  bool _autoPlayOnPageOpen = false;
  bool get autoPlayOnPageOpen => _autoPlayOnPageOpen;

  AudioRepeatMode _defaultRepeatMode = AudioRepeatMode.none;
  AudioRepeatMode get defaultRepeatMode => _defaultRepeatMode;

  // Legacy audio state (keeping for backward compatibility)
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  int _currentPlayingAyah = -1;
  int get currentPlayingAyah => _currentPlayingAyah;

  // ============== NAVIGATION STATE ==============
  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  // ============== INITIALIZATION ==============
  Future<void> initialize() async {
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _hasCompletedOnboarding =
        prefs.getBool('has_completed_onboarding') ?? false;
    _userName = prefs.getString('user_name') ?? '';
    _themeMode =
        AppThemeMode.values[prefs.getInt('theme_mode') ?? 0];
    _quranFontSize = prefs.getDouble('quran_font_size') ?? QuranFontSizes.medium;
    _quranLineHeight =
        prefs.getDouble('quran_line_height') ?? QuranLineHeights.normal;
    _arabicFontStyle =
        ArabicFontStyle.values[prefs.getInt('arabic_font_style') ?? 0];
    _translationLanguage =
        TranslationLanguage.values[prefs.getInt('translation_language') ?? 1]; // Default: Bengali
    _transliterationLanguage =
        TransliterationLanguage.values[prefs.getInt('transliteration_language') ?? 1]; // Default: Bengali
    _showTranslation = prefs.getBool('show_translation') ?? true;
    _showTransliteration = prefs.getBool('show_transliteration') ?? true;
    _isMushafView = prefs.getBool('is_mushaf_view') ?? false;
    _isLeftHanded = prefs.getBool('is_left_handed') ?? false;

    // Tajweed settings
    _showTajweedColors = prefs.getBool('show_tajweed_colors') ?? true;
    _tajweedLearningMode = prefs.getBool('tajweed_learning_mode') ?? true;

    // Audio settings
    _selectedReciter = Reciter.values[prefs.getInt('selected_reciter') ?? 0];
    _bengaliAudioSource = BengaliAudioSource.values[prefs.getInt('bengali_audio_source') ?? 1]; // Default to humanVoice
    _defaultPlaybackSpeed = prefs.getDouble('default_playback_speed') ?? 1.0;
    _autoPlayOnPageOpen = prefs.getBool('auto_play_on_page_open') ?? false;
    _defaultRepeatMode = AudioRepeatMode.values[prefs.getInt('default_repeat_mode') ?? 0];

    // Bengali Translation settings
    _selectedBengaliTranslationId = prefs.getInt('selected_bengali_translation_id') ?? 161; // Default to Taisirul

    // Sync external services
    AudioService().setReciter(_selectedReciter);
    AudioService().setBengaliAudioSource(_bengaliAudioSource);
    AudioService().setPlaybackSpeed(_defaultPlaybackSpeed);
    AudioService().setRepeatMode(_defaultRepeatMode);
    
    // Sync QuranDataService
    QuranDataService().setBengaliTranslationId(_selectedBengaliTranslationId);

    notifyListeners();
  }

  // ============== THEME METHODS ==============
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  // ============== FONT METHODS ==============
  Future<void> setQuranFontSize(double size) async {
    _quranFontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quran_font_size', size);
    notifyListeners();
  }

  Future<void> setQuranLineHeight(double height) async {
    _quranLineHeight = height;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quran_line_height', height);
    notifyListeners();
  }

  Future<void> setArabicFontStyle(ArabicFontStyle style) async {
    _arabicFontStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('arabic_font_style', style.index);
    notifyListeners();
  }

  // ============== READING SETTINGS METHODS ==============
  Future<void> setTranslationLanguage(TranslationLanguage language) async {
    _translationLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('translation_language', language.index);
    notifyListeners();
  }

  Future<void> setTransliterationLanguage(TransliterationLanguage language) async {
    _transliterationLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('transliteration_language', language.index);
    notifyListeners();
  }

  Future<void> setSelectedBengaliTranslationId(int id) async {
    _selectedBengaliTranslationId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_bengali_translation_id', id);
    
    // Update service and clear cache to force re-fetch
    QuranDataService().setBengaliTranslationId(id);
    await QuranDataService().clearCache();
    
    notifyListeners();
  }

  Future<void> toggleShowTranslation() async {
    _showTranslation = !_showTranslation;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_translation', _showTranslation);
    notifyListeners();
  }

  Future<void> setShowTranslation(bool value) async {
    _showTranslation = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_translation', value);
    notifyListeners();
  }

  Future<void> toggleShowTransliteration() async {
    _showTransliteration = !_showTransliteration;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_transliteration', _showTransliteration);
    notifyListeners();
  }

  Future<void> setShowTransliteration(bool value) async {
    _showTransliteration = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_transliteration', value);
    notifyListeners();
  }

  Future<void> setMushafView(bool value) async {
    _isMushafView = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_mushaf_view', value);
    notifyListeners();
  }

  Future<void> setLeftHanded(bool value) async {
    _isLeftHanded = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_left_handed', value);
    notifyListeners();
  }

  // ============== TAJWEED SETTINGS METHODS ==============
  Future<void> setShowTajweedColors(bool value) async {
    _showTajweedColors = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_tajweed_colors', value);
    notifyListeners();
  }

  Future<void> toggleShowTajweedColors() async {
    await setShowTajweedColors(!_showTajweedColors);
  }

  Future<void> setTajweedLearningMode(bool value) async {
    _tajweedLearningMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tajweed_learning_mode', value);
    notifyListeners();
  }

  Future<void> toggleTajweedLearningMode() async {
    await setTajweedLearningMode(!_tajweedLearningMode);
  }

  // ============== USER METHODS ==============
  Future<void> setUserName(String name) async {
    _userName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    notifyListeners();
  }

  // ============== BOOKMARK METHODS ==============
  void addBookmark(Bookmark bookmark) {
    _bookmarks.add(bookmark);
    notifyListeners();
    // TODO: Persist to local storage
  }

  void removeBookmark(String id) {
    _bookmarks.removeWhere((b) => b.id == id);
    notifyListeners();
    // TODO: Persist to local storage
  }

  void updateBookmark(Bookmark bookmark) {
    final index = _bookmarks.indexWhere((b) => b.id == bookmark.id);
    if (index != -1) {
      _bookmarks[index] = bookmark;
      notifyListeners();
      // TODO: Persist to local storage
    }
  }

  List<Bookmark> getBookmarksByLabel(String? label) {
    if (label == null) return _bookmarks;
    return _bookmarks.where((b) => b.label == label).toList();
  }

  bool isAyahBookmarked(int surahNumber, int ayahNumber) {
    return _bookmarks.any(
      (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
    );
  }

  // ============== READING PROGRESS METHODS ==============
  void updateReadingProgress(ReadingProgress progress) {
    _readingProgress = progress;
    notifyListeners();
    // TODO: Persist to local storage
  }

  // ============== AUDIO METHODS ==============
  Future<void> setSelectedReciter(Reciter reciter) async {
    _selectedReciter = reciter;
    // Also update the AudioService so playback uses the new reciter
    AudioService().setReciter(reciter);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_reciter', reciter.index);
    notifyListeners();
  }

  Future<void> setBengaliAudioSource(BengaliAudioSource source) async {
    _bengaliAudioSource = source;
    // Also update the AudioService
    AudioService().setBengaliAudioSource(source);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bengali_audio_source', source.index);
    notifyListeners();
  }

  Future<void> setDefaultPlaybackSpeed(double speed) async {
    _defaultPlaybackSpeed = speed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('default_playback_speed', speed);
    notifyListeners();
  }

  Future<void> setAutoPlayOnPageOpen(bool value) async {
    _autoPlayOnPageOpen = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_play_on_page_open', value);
    notifyListeners();
  }

  Future<void> setDefaultRepeatMode(AudioRepeatMode mode) async {
    _defaultRepeatMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('default_repeat_mode', mode.index);
    notifyListeners();
  }

  // Legacy methods for backward compatibility
  void setIsPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  void setCurrentPlayingAyah(int ayahNumber) {
    _currentPlayingAyah = ayahNumber;
    notifyListeners();
  }
}

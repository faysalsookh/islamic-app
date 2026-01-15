import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../models/bookmark.dart';
import '../models/reading_progress.dart';

/// Available Arabic font styles
enum ArabicFontStyle {
  amiri,
  scheherazade,
  lateef,
}

/// Available translation languages
enum TranslationLanguage {
  english,
  bengali,
  both,
  none,
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
  TranslationLanguage _translationLanguage = TranslationLanguage.english;
  TranslationLanguage get translationLanguage => _translationLanguage;

  bool _showTranslation = true;
  bool get showTranslation => _showTranslation;

  bool _isMushafView = false; // false = Ayah list view, true = Mushaf view
  bool get isMushafView => _isMushafView;

  bool _isLeftHanded = false;
  bool get isLeftHanded => _isLeftHanded;

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
  String _selectedReciter = 'Mishary Rashid Alafasy';
  String get selectedReciter => _selectedReciter;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  int _currentPlayingAyah = -1;
  int get currentPlayingAyah => _currentPlayingAyah;

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
        TranslationLanguage.values[prefs.getInt('translation_language') ?? 0];
    _showTranslation = prefs.getBool('show_translation') ?? true;
    _isMushafView = prefs.getBool('is_mushaf_view') ?? false;
    _isLeftHanded = prefs.getBool('is_left_handed') ?? false;

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

  Future<void> toggleShowTranslation() async {
    _showTranslation = !_showTranslation;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_translation', _showTranslation);
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

  // ============== READING PROGRESS METHODS ==============
  void updateReadingProgress(ReadingProgress progress) {
    _readingProgress = progress;
    notifyListeners();
    // TODO: Persist to local storage
  }

  // ============== AUDIO METHODS ==============
  void setSelectedReciter(String reciter) {
    _selectedReciter = reciter;
    notifyListeners();
  }

  void setIsPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  void setCurrentPlayingAyah(int ayahNumber) {
    _currentPlayingAyah = ayahNumber;
    notifyListeners();
  }
}

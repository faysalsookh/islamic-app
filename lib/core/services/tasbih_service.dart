import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dhikr preset with name and Arabic text
class Dhikr {
  final String id;
  final String name;
  final String arabic;
  final String transliteration;
  final String meaning;
  final int recommendedCount;

  const Dhikr({
    required this.id,
    required this.name,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.recommendedCount,
  });
}

/// Tasbih bead style
enum TasbihBeadStyle {
  wooden,
  gold,
  silver,
  jade,
  ruby,
  amber,
  pearl,
  obsidian,
}

/// Service for managing Tasbih counter state and persistence
class TasbihService extends ChangeNotifier {
  static final TasbihService _instance = TasbihService._internal();
  factory TasbihService() => _instance;
  TasbihService._internal();

  // State
  int _count = 0;
  int _loop = 1;
  int _target = 33;
  int _totalCount = 0;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  TasbihBeadStyle _beadStyle = TasbihBeadStyle.wooden;
  Dhikr? _selectedDhikr;

  // Getters
  int get count => _count;
  int get loop => _loop;
  int get target => _target;
  int get totalCount => _totalCount;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  TasbihBeadStyle get beadStyle => _beadStyle;
  Dhikr? get selectedDhikr => _selectedDhikr;

  // Preset dhikrs
  static const List<Dhikr> presetDhikrs = [
    Dhikr(
      id: 'subhanallah',
      name: 'SubhanAllah',
      arabic: 'سُبْحَانَ اللهِ',
      transliteration: 'SubhanAllah',
      meaning: 'Glory be to Allah',
      recommendedCount: 33,
    ),
    Dhikr(
      id: 'alhamdulillah',
      name: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'Alhamdulillah',
      meaning: 'All praise is due to Allah',
      recommendedCount: 33,
    ),
    Dhikr(
      id: 'allahuakbar',
      name: 'Allahu Akbar',
      arabic: 'اللهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      meaning: 'Allah is the Greatest',
      recommendedCount: 33,
    ),
    Dhikr(
      id: 'lailahaillallah',
      name: 'La ilaha illallah',
      arabic: 'لَا إِلٰهَ إِلَّا اللهُ',
      transliteration: 'La ilaha illallah',
      meaning: 'There is no god but Allah',
      recommendedCount: 100,
    ),
    Dhikr(
      id: 'astaghfirullah',
      name: 'Astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللهَ',
      transliteration: 'Astaghfirullah',
      meaning: 'I seek forgiveness from Allah',
      recommendedCount: 100,
    ),
    Dhikr(
      id: 'salawat',
      name: 'Salawat',
      arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      transliteration: 'Allahumma salli ala Muhammad',
      meaning: 'O Allah, send blessings upon Muhammad',
      recommendedCount: 100,
    ),
    Dhikr(
      id: 'hawqala',
      name: 'Hawqala',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
      transliteration: 'La hawla wala quwwata illa billah',
      meaning: 'There is no power nor strength except with Allah',
      recommendedCount: 100,
    ),
    Dhikr(
      id: 'tahlil',
      name: 'Tahlil',
      arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      transliteration: 'SubhanAllahi wa bihamdihi',
      meaning: 'Glory be to Allah and His praise',
      recommendedCount: 100,
    ),
  ];

  // Common targets
  static const List<int> commonTargets = [33, 99, 100, 500, 1000];

  /// Initialize service and load saved state
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _count = prefs.getInt('tasbih_count') ?? 0;
    _loop = prefs.getInt('tasbih_loop') ?? 1;
    _target = prefs.getInt('tasbih_target') ?? 33;
    _totalCount = prefs.getInt('tasbih_total_count') ?? 0;
    _soundEnabled = prefs.getBool('tasbih_sound') ?? true;
    _vibrationEnabled = prefs.getBool('tasbih_vibration') ?? true;
    _beadStyle = TasbihBeadStyle.values[prefs.getInt('tasbih_bead_style') ?? 0];

    final dhikrId = prefs.getString('tasbih_dhikr_id');
    if (dhikrId != null) {
      _selectedDhikr = presetDhikrs.where((d) => d.id == dhikrId).firstOrNull;
    }

    notifyListeners();
  }

  /// Increment counter
  void increment() {
    _count++;
    _totalCount++;

    // Check if target reached
    if (_count >= _target) {
      _loop++;
      _count = 0;
    }

    _saveState();
    notifyListeners();
  }

  /// Decrement counter
  void decrement() {
    if (_count > 0) {
      _count--;
      _totalCount = (_totalCount > 0) ? _totalCount - 1 : 0;
      _saveState();
      notifyListeners();
    } else if (_loop > 1) {
      // Go back to previous loop
      _loop--;
      _count = _target - 1;
      _totalCount = (_totalCount > 0) ? _totalCount - 1 : 0;
      _saveState();
      notifyListeners();
    }
  }

  /// Reset counter
  void reset() {
    _count = 0;
    _loop = 1;
    _saveState();
    notifyListeners();
  }

  /// Reset all including total
  void resetAll() {
    _count = 0;
    _loop = 1;
    _totalCount = 0;
    _saveState();
    notifyListeners();
  }

  /// Set target count
  void setTarget(int newTarget) {
    _target = newTarget;
    if (_count >= _target) {
      _count = 0;
      _loop++;
    }
    _saveState();
    notifyListeners();
  }

  /// Set bead style
  void setBeadStyle(TasbihBeadStyle style) {
    _beadStyle = style;
    _saveBeadStyle();
    notifyListeners();
  }

  /// Toggle sound
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _saveSettings();
    notifyListeners();
  }

  /// Toggle vibration
  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    _saveSettings();
    notifyListeners();
  }

  /// Select a dhikr
  void selectDhikr(Dhikr? dhikr) {
    _selectedDhikr = dhikr;
    if (dhikr != null) {
      _target = dhikr.recommendedCount;
      if (_count >= _target) {
        _count = 0;
        _loop++;
      }
    }
    _saveDhikr();
    _saveState();
    notifyListeners();
  }

  /// Save state to preferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', _count);
    await prefs.setInt('tasbih_loop', _loop);
    await prefs.setInt('tasbih_target', _target);
    await prefs.setInt('tasbih_total_count', _totalCount);
  }

  /// Save settings
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tasbih_sound', _soundEnabled);
    await prefs.setBool('tasbih_vibration', _vibrationEnabled);
  }

  /// Save bead style
  Future<void> _saveBeadStyle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_bead_style', _beadStyle.index);
  }

  /// Save selected dhikr
  Future<void> _saveDhikr() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedDhikr != null) {
      await prefs.setString('tasbih_dhikr_id', _selectedDhikr!.id);
    } else {
      await prefs.remove('tasbih_dhikr_id');
    }
  }

  /// Get bead color for style
  static int getBeadColorValue(TasbihBeadStyle style) {
    switch (style) {
      case TasbihBeadStyle.wooden:
        return 0xFF8B5A2B;
      case TasbihBeadStyle.gold:
        return 0xFFD4A853;
      case TasbihBeadStyle.silver:
        return 0xFFC0C0C0;
      case TasbihBeadStyle.jade:
        return 0xFF00A86B;
      case TasbihBeadStyle.ruby:
        return 0xFFE0115F;
      case TasbihBeadStyle.amber:
        return 0xFFFFBF00;
      case TasbihBeadStyle.pearl:
        return 0xFFFDEEF4;
      case TasbihBeadStyle.obsidian:
        return 0xFF1C1C1C;
    }
  }

  /// Get bead gradient colors for style
  static List<int> getBeadGradientValues(TasbihBeadStyle style) {
    switch (style) {
      case TasbihBeadStyle.wooden:
        return [0xFFCD853F, 0xFF8B5A2B, 0xFF654321];
      case TasbihBeadStyle.gold:
        return [0xFFFFD700, 0xFFD4A853, 0xFFB8860B];
      case TasbihBeadStyle.silver:
        return [0xFFE8E8E8, 0xFFC0C0C0, 0xFFA8A8A8];
      case TasbihBeadStyle.jade:
        return [0xFF50C878, 0xFF00A86B, 0xFF006B3C];
      case TasbihBeadStyle.ruby:
        return [0xFFFF4D6D, 0xFFE0115F, 0xFFAB0D43];
      case TasbihBeadStyle.amber:
        return [0xFFFFD54F, 0xFFFFBF00, 0xFFFF8F00];
      case TasbihBeadStyle.pearl:
        return [0xFFFFFFFF, 0xFFFDEEF4, 0xFFEAD5DC];
      case TasbihBeadStyle.obsidian:
        return [0xFF3D3D3D, 0xFF1C1C1C, 0xFF0D0D0D];
    }
  }

  /// Get style display name
  static String getStyleName(TasbihBeadStyle style) {
    switch (style) {
      case TasbihBeadStyle.wooden:
        return 'Wooden';
      case TasbihBeadStyle.gold:
        return 'Gold';
      case TasbihBeadStyle.silver:
        return 'Silver';
      case TasbihBeadStyle.jade:
        return 'Jade';
      case TasbihBeadStyle.ruby:
        return 'Ruby';
      case TasbihBeadStyle.amber:
        return 'Amber';
      case TasbihBeadStyle.pearl:
        return 'Pearl';
      case TasbihBeadStyle.obsidian:
        return 'Obsidian';
    }
  }
}

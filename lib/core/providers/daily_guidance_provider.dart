import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/daily_guidance/data/daily_guidance_model.dart';
import '../../features/daily_guidance/data/daily_guidance_data.dart';

class DailyGuidanceProvider with ChangeNotifier {
  static const String _streakKey = 'daily_guidance_streak';
  static const String _lastViewedKey = 'daily_guidance_last_viewed';
  static const String _bookmarksKey = 'daily_guidance_bookmarks';
  static const String _viewedDaysKey = 'daily_guidance_viewed_days';

  int _currentStreak = 0;
  int _longestStreak = 0;
  String _lastViewedDate = '';
  List<DailyGuidanceItem> _bookmarks = [];
  Set<String> _viewedDays = {};
  bool _isLoading = false;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  String get lastViewedDate => _lastViewedDate;
  List<DailyGuidanceItem> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;

  /// Get today's guidance items
  List<DailyGuidanceItem> get todayItems => DailyGuidanceData.getTodayItems();

  /// Get current day number (1-30)
  int get currentDayNumber => DailyGuidanceData.currentDayNumber;

  /// Check if today's guidance has been viewed
  bool get hasViewedToday => _lastViewedDate == _todayKey;

  /// Total days viewed
  int get totalDaysViewed => _viewedDays.length;

  /// Initialize and load saved data
  Future<void> initialize() async {
    await _loadData();
  }

  /// Mark today as viewed and update streak
  Future<void> markTodayViewed() async {
    final today = _todayKey;
    if (_lastViewedDate == today) return;

    final yesterday = _getDateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (_lastViewedDate == yesterday) {
      _currentStreak++;
    } else if (_lastViewedDate != today) {
      _currentStreak = 1;
    }

    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }

    _lastViewedDate = today;
    _viewedDays.add(today);
    await _saveData();
    notifyListeners();
  }

  /// Toggle bookmark for an item
  Future<void> toggleBookmark(DailyGuidanceItem item) async {
    final existingIndex = _bookmarks.indexWhere(
      (b) => b.dayNumber == item.dayNumber && b.type == item.type,
    );

    if (existingIndex >= 0) {
      _bookmarks.removeAt(existingIndex);
    } else {
      _bookmarks.add(item);
    }

    await _saveData();
    notifyListeners();
  }

  /// Check if an item is bookmarked
  bool isBookmarked(DailyGuidanceItem item) {
    return _bookmarks.any(
      (b) => b.dayNumber == item.dayNumber && b.type == item.type,
    );
  }

  /// Get date key for today
  String get _todayKey => _getDateKey(DateTime.now());

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load streak data
      final streakJson = prefs.getString(_streakKey);
      if (streakJson != null) {
        final data = json.decode(streakJson) as Map<String, dynamic>;
        _currentStreak = data['current'] as int? ?? 0;
        _longestStreak = data['longest'] as int? ?? 0;
      }

      // Load last viewed date
      _lastViewedDate = prefs.getString(_lastViewedKey) ?? '';

      // Load viewed days
      final viewedJson = prefs.getString(_viewedDaysKey);
      if (viewedJson != null) {
        final viewedList = (json.decode(viewedJson) as List).cast<String>();
        _viewedDays = viewedList.toSet();
      }

      // Load bookmarks
      final bookmarksJson = prefs.getString(_bookmarksKey);
      if (bookmarksJson != null) {
        final bookmarksList = json.decode(bookmarksJson) as List;
        _bookmarks = bookmarksList
            .map((e) => DailyGuidanceItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading daily guidance data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save streak
      await prefs.setString(_streakKey, json.encode({
        'current': _currentStreak,
        'longest': _longestStreak,
      }));

      // Save last viewed
      await prefs.setString(_lastViewedKey, _lastViewedDate);

      // Save viewed days
      await prefs.setString(_viewedDaysKey, json.encode(_viewedDays.toList()));

      // Save bookmarks
      await prefs.setString(
        _bookmarksKey,
        json.encode(_bookmarks.map((b) => b.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving daily guidance data: $e');
    }
  }
}

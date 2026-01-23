import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_tracker_data.dart';

/// Provider for managing daily tracker state
class DailyTrackerProvider with ChangeNotifier {
  static const String _storageKey = 'ramadan_daily_tracker';
  
  Map<String, DailyTrackerData> _trackerData = {};
  bool _isLoading = false;

  Map<String, DailyTrackerData> get trackerData => _trackerData;
  bool get isLoading => _isLoading;

  /// Initialize and load saved data
  Future<void> initialize() async {
    await _loadData();
  }

  /// Get tracker data for a specific date
  DailyTrackerData getDataForDate(DateTime date) {
    final key = _getDateKey(date);
    return _trackerData[key] ?? DailyTrackerData.empty(date);
  }

  /// Get tracker data for today
  DailyTrackerData get todayData {
    return getDataForDate(DateTime.now());
  }

  /// Update tracker data for a specific date
  Future<void> updateData(DailyTrackerData data) async {
    _trackerData[data.dateKey] = data;
    await _saveData();
    notifyListeners();
  }

  /// Toggle fasting status
  Future<void> toggleFasting(DateTime date) async {
    final data = getDataForDate(date);
    await updateData(data.copyWith(fasting: !data.fasting));
  }

  /// Toggle prayer status
  Future<void> togglePrayer(DateTime date, String prayer) async {
    final data = getDataForDate(date);
    final prayers = Map<String, bool>.from(data.prayers);
    prayers[prayer] = !(prayers[prayer] ?? false);
    await updateData(data.copyWith(prayers: prayers));
  }

  /// Toggle Taraweeh status
  Future<void> toggleTaraweeh(DateTime date) async {
    final data = getDataForDate(date);
    await updateData(data.copyWith(taraweeh: !data.taraweeh));
  }

  /// Update Quran pages
  Future<void> updateQuranPages(DateTime date, int pages) async {
    final data = getDataForDate(date);
    await updateData(data.copyWith(quranPages: pages));
  }

  /// Toggle Sadaqah status
  Future<void> toggleSadaqah(DateTime date) async {
    final data = getDataForDate(date);
    await updateData(data.copyWith(sadaqah: !data.sadaqah));
  }

  /// Update notes
  Future<void> updateNotes(DateTime date, String notes) async {
    final data = getDataForDate(date);
    await updateData(data.copyWith(notes: notes.isEmpty ? null : notes));
  }

  /// Get statistics for a date range
  RamadanTrackerStats getStats({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    int totalDays = 0;
    int completedDays = 0;
    int fastingDays = 0;
    int totalPrayers = 0;
    int completedPrayers = 0;
    int taraweehDays = 0;
    int totalQuranPages = 0;
    int sadaqahDays = 0;

    // Calculate stats for each day in range
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Only count days up to today
      if (currentDate.isAfter(DateTime.now())) break;

      totalDays++;
      final data = getDataForDate(currentDate);

      if (data.isFullyCompleted) completedDays++;
      if (data.fasting) fastingDays++;
      if (data.taraweeh) taraweehDays++;
      if (data.sadaqah) sadaqahDays++;
      
      totalPrayers += 5;
      completedPrayers += data.completedPrayers;
      totalQuranPages += data.quranPages;

      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Calculate streaks
    final streaks = _calculateStreaks(startDate, endDate);

    return RamadanTrackerStats(
      totalDays: totalDays,
      completedDays: completedDays,
      fastingDays: fastingDays,
      totalPrayers: totalPrayers,
      completedPrayers: completedPrayers,
      taraweehDays: taraweehDays,
      totalQuranPages: totalQuranPages,
      sadaqahDays: sadaqahDays,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
    );
  }

  /// Calculate current and longest streaks
  Map<String, int> _calculateStreaks(DateTime startDate, DateTime endDate) {
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    DateTime currentDate = startDate;
    DateTime today = DateTime.now();
    bool streakBroken = false;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Only count days up to today
      if (currentDate.isAfter(today)) break;

      final data = getDataForDate(currentDate);
      
      // Consider day complete if completion >= 80%
      if (data.completionPercentage >= 80) {
        tempStreak++;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        if (!streakBroken && currentDate.isBefore(today)) {
          streakBroken = true;
        }
        tempStreak = 0;
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Current streak is only valid if not broken
    currentStreak = streakBroken ? 0 : tempStreak;

    return {
      'current': currentStreak,
      'longest': longestStreak,
    };
  }

  /// Get date key for storage
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Load data from SharedPreferences
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        _trackerData = jsonData.map(
          (key, value) => MapEntry(
            key,
            DailyTrackerData.fromJson(value as Map<String, dynamic>),
          ),
        );
      }
    } catch (e) {
      print('Error loading tracker data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save data to SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = _trackerData.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await prefs.setString(_storageKey, json.encode(jsonData));
    } catch (e) {
      print('Error saving tracker data: $e');
    }
  }

  /// Clear all data (for testing)
  Future<void> clearAllData() async {
    _trackerData.clear();
    await _saveData();
    notifyListeners();
  }
}

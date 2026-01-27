import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_plan.dart';

/// Provider for managing Quran reading plan (Juz-based tracking)
class QuranPlanProvider with ChangeNotifier {
  static const String _storageKey = 'quran_reading_plan';

  QuranPlan? _plan;
  bool _isLoading = false;

  QuranPlan? get plan => _plan;
  bool get isLoading => _isLoading;
  bool get hasPlan => _plan != null;

  /// Initialize and load saved plan
  Future<void> initialize() async {
    await _loadPlan();
  }

  /// Create a new plan
  Future<void> createPlan({
    required int targetDays,
    required DateTime startDate,
  }) async {
    _plan = QuranPlan(
      targetDays: targetDays,
      startDate: startDate,
    );
    await _savePlan();
    notifyListeners();
  }

  /// Toggle a Juz as completed or not completed
  Future<void> toggleJuz(int juzNumber) async {
    if (_plan == null) return;
    if (juzNumber < 1 || juzNumber > 30) return;

    final currentCompleted = List<int>.from(_plan!.completedJuz);

    if (currentCompleted.contains(juzNumber)) {
      currentCompleted.remove(juzNumber);
    } else {
      currentCompleted.add(juzNumber);
      currentCompleted.sort();
    }

    final isCompleted = currentCompleted.length >= _plan!.totalJuz;

    _plan = _plan!.copyWith(
      completedJuz: currentCompleted,
      isCompleted: isCompleted,
    );

    await _savePlan();
    notifyListeners();
  }

  /// Mark a specific Juz as completed
  Future<void> markJuzComplete(int juzNumber) async {
    if (_plan == null) return;
    if (_plan!.isJuzCompleted(juzNumber)) return;

    final currentCompleted = List<int>.from(_plan!.completedJuz)
      ..add(juzNumber)
      ..sort();

    final isCompleted = currentCompleted.length >= _plan!.totalJuz;

    _plan = _plan!.copyWith(
      completedJuz: currentCompleted,
      isCompleted: isCompleted,
    );

    await _savePlan();
    notifyListeners();
  }

  /// Mark a specific Juz as incomplete
  Future<void> markJuzIncomplete(int juzNumber) async {
    if (_plan == null) return;
    if (!_plan!.isJuzCompleted(juzNumber)) return;

    final currentCompleted = List<int>.from(_plan!.completedJuz)
      ..remove(juzNumber);

    _plan = _plan!.copyWith(
      completedJuz: currentCompleted,
      isCompleted: false,
    );

    await _savePlan();
    notifyListeners();
  }

  /// Update plan settings
  Future<void> updatePlanSettings({
    int? targetDays,
    DateTime? startDate,
  }) async {
    if (_plan == null) return;

    _plan = _plan!.copyWith(
      targetDays: targetDays,
      startDate: startDate,
    );

    await _savePlan();
    notifyListeners();
  }

  /// Delete current plan
  Future<void> deletePlan() async {
    _plan = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  /// Load plan from SharedPreferences
  Future<void> _loadPlan() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        _plan = QuranPlan.fromJson(jsonData);
      }
    } catch (e) {
      print('Error loading Quran plan: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save plan to SharedPreferences
  Future<void> _savePlan() async {
    if (_plan == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, json.encode(_plan!.toJson()));
    } catch (e) {
      print('Error saving Quran plan: $e');
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_plan.dart';
import '../models/ramadan_settings.dart';

/// Provider for managing Quran reading plan
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

  /// Update current page progress
  Future<void> updateProgress(int page) async {
    if (_plan == null) return;
    
    // Ensure page is valid
    int newPage = page;
    if (newPage < 0) newPage = 0;
    if (newPage > _plan!.completeQuranPages) newPage = _plan!.completeQuranPages;
    
    final isCompleted = newPage >= _plan!.completeQuranPages;
    
    _plan = _plan!.copyWith(
      currentPage: newPage,
      isCompleted: isCompleted,
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

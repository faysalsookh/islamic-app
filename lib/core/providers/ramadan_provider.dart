import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/prayer_times_data.dart';
import '../services/prayer_time_service.dart';

/// Provider for managing Ramadan-related state and countdown timers
class RamadanProvider with ChangeNotifier {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  
  PrayerTimesData? _todayPrayerTimes;
  Timer? _countdownTimer;
  bool _isLoading = false;
  String? _errorMessage;

  // Ramadan configuration
  DateTime? _ramadanStartDate;
  List<PrayerTimesData> _ramadanCalendar = [];

  // Getters
  PrayerTimesData? get todayPrayerTimes => _todayPrayerTimes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get ramadanStartDate => _ramadanStartDate;
  List<PrayerTimesData> get ramadanCalendar => _ramadanCalendar;

  /// Check if we're currently in Ramadan
  bool get isRamadan {
    if (_ramadanStartDate == null) return false;
    final now = DateTime.now();
    final ramadanEnd = _ramadanStartDate!.add(const Duration(days: 30));
    return now.isAfter(_ramadanStartDate!) && now.isBefore(ramadanEnd);
  }

  /// Get current Ramadan day (1-30)
  int? get currentRamadanDay {
    if (!isRamadan || _ramadanStartDate == null) return null;
    final now = DateTime.now();
    final difference = now.difference(_ramadanStartDate!).inDays;
    return difference + 1; // Days are 1-indexed
  }

  /// Get time until Sehri ends (Fajr)
  Duration? get timeUntilSehriEnds => _todayPrayerTimes?.getTimeUntilSehriEnds();

  /// Get time until Iftar (Maghrib)
  Duration? get timeUntilIftar => _todayPrayerTimes?.getTimeUntilIftar();

  /// Check if currently fasting
  bool get isCurrentlyFasting => _todayPrayerTimes?.isCurrentlyFasting() ?? false;

  /// Initialize and load prayer times
  Future<void> initialize() async {
    await loadTodayPrayerTimes();
    _startCountdownTimer();
  }

  /// Load today's prayer times
  Future<void> loadTodayPrayerTimes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayPrayerTimes = await _prayerTimeService.getTodayPrayerTimes();
      if (_todayPrayerTimes == null) {
        _errorMessage = 'Unable to calculate prayer times. Please check location permissions.';
      }
    } catch (e) {
      _errorMessage = 'Error loading prayer times: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set Ramadan start date and generate calendar
  Future<void> setRamadanStartDate(DateTime startDate) async {
    _ramadanStartDate = startDate;
    _isLoading = true;
    notifyListeners();

    try {
      _ramadanCalendar = await _prayerTimeService.getRamadanCalendar(startDate);
    } catch (e) {
      _errorMessage = 'Error generating Ramadan calendar: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start countdown timer that updates every second
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Just notify listeners to update the UI
      // The actual countdown is calculated from prayer times
      notifyListeners();
    });
  }

  /// Refresh prayer times (useful when location changes)
  Future<void> refresh() async {
    _prayerTimeService.clearCache();
    await loadTodayPrayerTimes();
    
    if (_ramadanStartDate != null) {
      await setRamadanStartDate(_ramadanStartDate!);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

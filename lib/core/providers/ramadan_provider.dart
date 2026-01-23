import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_data.dart';
import '../models/ramadan_settings.dart';
import '../services/prayer_time_service.dart';
import '../services/ramadan_notification_scheduler.dart';

/// Provider for managing Ramadan-related state and countdown timers
class RamadanProvider with ChangeNotifier {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  final RamadanNotificationScheduler _notificationScheduler = RamadanNotificationScheduler();
  
  PrayerTimesData? _todayPrayerTimes;
  Timer? _countdownTimer;
  bool _isLoading = false;
  String? _errorMessage;

  // Ramadan configuration
  DateTime? _ramadanStartDate;
  List<PrayerTimesData> _ramadanCalendar = [];
  
  // Settings
  RamadanSettings _settings = RamadanSettings.defaults();
  static const String _settingsKey = 'ramadan_settings';

  // Getters
  PrayerTimesData? get todayPrayerTimes => _todayPrayerTimes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get ramadanStartDate => _ramadanStartDate;
  List<PrayerTimesData> get ramadanCalendar => _ramadanCalendar;
  RamadanSettings get settings => _settings;

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
    await _loadSettings();
    _ramadanStartDate = _settings.ramadanStartDate;
    await loadTodayPrayerTimes();
    _startCountdownTimer();
  }

  /// Load today's prayer times
  Future<void> loadTodayPrayerTimes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todayPrayerTimes = await _prayerTimeService.getTodayPrayerTimes(settings: _settings);
      if (_todayPrayerTimes == null) {
        _errorMessage = 'Unable to calculate prayer times. Please check location permissions.';
      } else {
        // Schedule notifications if in Ramadan
        await _scheduleNotificationsIfNeeded();
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
      _ramadanCalendar = await _prayerTimeService.getRamadanCalendar(startDate, settings: _settings);
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

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        _settings = RamadanSettings.fromJson(json);
      } else {
        _settings = RamadanSettings.defaults();
        await _saveSettings();
      }
    } catch (e) {
      print('Error loading Ramadan settings: $e');
      _settings = RamadanSettings.defaults();
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving Ramadan settings: $e');
    }
  }

  /// Update settings and save
  Future<void> updateSettings(RamadanSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    
    // Update ramadan start date if changed
    if (_ramadanStartDate != newSettings.ramadanStartDate) {
      _ramadanStartDate = newSettings.ramadanStartDate;
      if (_ramadanStartDate != null) {
        await setRamadanStartDate(_ramadanStartDate!);
      }
    }
    
    // Refresh prayer times with new calculation method
    _prayerTimeService.clearCache();
    await loadTodayPrayerTimes();
    
    notifyListeners();
  }

  /// Schedule notifications if in Ramadan and settings allow
  Future<void> _scheduleNotificationsIfNeeded() async {
    if (!isRamadan || _todayPrayerTimes == null) return;
    
    final day = currentRamadanDay;
    if (day == null) return;

    try {
      await _notificationScheduler.scheduleNotificationsForToday(
        prayerTimes: _todayPrayerTimes!,
        settings: _settings,
        ramadanDay: day,
      );
    } catch (e) {
      print('Error scheduling notifications: $e');
    }
  }

  /// Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    return await _notificationScheduler.requestPermissions();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _notificationScheduler.areNotificationsEnabled();
  }

  /// Show test notification
  Future<void> showTestNotification() async {
    await _notificationScheduler.showTestNotification();
  }

  /// Manually schedule notifications (useful for testing)
  Future<void> scheduleNotifications() async {
    await _scheduleNotificationsIfNeeded();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

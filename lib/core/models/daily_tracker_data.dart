import 'package:intl/intl.dart';

/// Model for tracking daily Ramadan activities
class DailyTrackerData {
  final DateTime date;
  final bool fasting;
  final Map<String, bool> prayers; // fajr, dhuhr, asr, maghrib, isha
  final bool taraweeh;
  final int quranPages;
  final bool sadaqah;
  final String? notes;

  DailyTrackerData({
    required this.date,
    this.fasting = false,
    Map<String, bool>? prayers,
    this.taraweeh = false,
    this.quranPages = 0,
    this.sadaqah = false,
    this.notes,
  }) : prayers = prayers ?? {
          'fajr': false,
          'dhuhr': false,
          'asr': false,
          'maghrib': false,
          'isha': false,
        };

  /// Get date key for storage (YYYY-MM-DD)
  String get dateKey => DateFormat('yyyy-MM-dd').format(date);

  /// Get completed prayer count
  int get completedPrayers {
    return prayers.values.where((completed) => completed).length;
  }

  /// Get total prayer count
  int get totalPrayers => 5;

  /// Check if all prayers are completed
  bool get allPrayersCompleted => completedPrayers == totalPrayers;

  /// Calculate completion percentage (0-100)
  int get completionPercentage {
    int total = 0;
    int completed = 0;

    // Fasting (20%)
    total += 20;
    if (fasting) completed += 20;

    // Prayers (50% - 10% each)
    total += 50;
    completed += (completedPrayers * 10);

    // Taraweeh (15%)
    total += 15;
    if (taraweeh) completed += 15;

    // Quran (10% - at least 4 pages)
    total += 10;
    if (quranPages >= 4) completed += 10;

    // Sadaqah (5%)
    total += 5;
    if (sadaqah) completed += 5;

    return completed;
  }

  /// Check if day is fully completed
  bool get isFullyCompleted => completionPercentage == 100;

  /// Copy with method
  DailyTrackerData copyWith({
    DateTime? date,
    bool? fasting,
    Map<String, bool>? prayers,
    bool? taraweeh,
    int? quranPages,
    bool? sadaqah,
    String? notes,
  }) {
    return DailyTrackerData(
      date: date ?? this.date,
      fasting: fasting ?? this.fasting,
      prayers: prayers ?? Map.from(this.prayers),
      taraweeh: taraweeh ?? this.taraweeh,
      quranPages: quranPages ?? this.quranPages,
      sadaqah: sadaqah ?? this.sadaqah,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': dateKey,
      'fasting': fasting,
      'prayers': prayers,
      'taraweeh': taraweeh,
      'quranPages': quranPages,
      'sadaqah': sadaqah,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory DailyTrackerData.fromJson(Map<String, dynamic> json) {
    return DailyTrackerData(
      date: DateFormat('yyyy-MM-dd').parse(json['date'] as String),
      fasting: json['fasting'] as bool? ?? false,
      prayers: Map<String, bool>.from(json['prayers'] as Map? ?? {}),
      taraweeh: json['taraweeh'] as bool? ?? false,
      quranPages: json['quranPages'] as int? ?? 0,
      sadaqah: json['sadaqah'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Create empty tracker for a date
  factory DailyTrackerData.empty(DateTime date) {
    return DailyTrackerData(date: date);
  }
}

/// Statistics for Ramadan tracker
class RamadanTrackerStats {
  final int totalDays;
  final int completedDays;
  final int fastingDays;
  final int totalPrayers;
  final int completedPrayers;
  final int taraweehDays;
  final int totalQuranPages;
  final int sadaqahDays;
  final int currentStreak;
  final int longestStreak;

  RamadanTrackerStats({
    required this.totalDays,
    required this.completedDays,
    required this.fastingDays,
    required this.totalPrayers,
    required this.completedPrayers,
    required this.taraweehDays,
    required this.totalQuranPages,
    required this.sadaqahDays,
    required this.currentStreak,
    required this.longestStreak,
  });

  /// Get fasting percentage
  double get fastingPercentage {
    if (totalDays == 0) return 0;
    return (fastingDays / totalDays) * 100;
  }

  /// Get prayer percentage
  double get prayerPercentage {
    if (totalPrayers == 0) return 0;
    return (completedPrayers / totalPrayers) * 100;
  }

  /// Get taraweeh percentage
  double get taraweehPercentage {
    if (totalDays == 0) return 0;
    return (taraweehDays / totalDays) * 100;
  }

  /// Get average Quran pages per day
  double get averageQuranPages {
    if (totalDays == 0) return 0;
    return totalQuranPages / totalDays;
  }

  /// Empty stats
  factory RamadanTrackerStats.empty() {
    return RamadanTrackerStats(
      totalDays: 0,
      completedDays: 0,
      fastingDays: 0,
      totalPrayers: 0,
      completedPrayers: 0,
      taraweehDays: 0,
      totalQuranPages: 0,
      sadaqahDays: 0,
      currentStreak: 0,
      longestStreak: 0,
    );
  }
}

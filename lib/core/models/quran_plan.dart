/// Model for Quran reading plan - tracks by Juz (30 parts)
class QuranPlan {
  final int targetDays; // 15, 20, or 30 days
  final DateTime startDate;
  final int totalJuz; // Always 30
  final List<int> completedJuz; // List of completed Juz numbers (1-30)
  final bool isCompleted;

  QuranPlan({
    required this.targetDays,
    required this.startDate,
    this.totalJuz = 30,
    this.completedJuz = const [],
    this.isCompleted = false,
  });

  /// Number of completed Juz
  int get completedCount => completedJuz.length;

  /// Progress percentage (0.0 to 100.0)
  double get progressPercentage => (completedCount / totalJuz * 100).clamp(0.0, 100.0);

  /// Calculate Juz to read per day
  double get juzPerDay => totalJuz / targetDays;

  /// Calculate days elapsed since start
  int get daysElapsed {
    final now = DateTime.now();
    final difference = now.difference(startDate).inDays;
    return difference < 0 ? 0 : difference + 1;
  }

  /// Calculate expected completed Juz for today
  int get expectedJuz {
    final expected = (daysElapsed * juzPerDay).ceil();
    return expected > totalJuz ? totalJuz : expected;
  }

  /// Calculate remaining Juz
  int get remainingJuz => totalJuz - completedCount;

  /// Calculate remaining days based on target date
  int get remainingDays {
    final endDate = startDate.add(Duration(days: targetDays));
    final difference = endDate.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Calculate adjusted Juz per day based on remaining progress and days
  double get adjustedJuzPerDay {
    if (remainingDays <= 0) return remainingJuz.toDouble();
    return remainingJuz / remainingDays;
  }

  /// Check if user is on track
  bool get isOnTrack => completedCount >= expectedJuz;

  /// Check if a specific Juz is completed
  bool isJuzCompleted(int juzNumber) => completedJuz.contains(juzNumber);

  /// Get status message
  String get statusMessage {
    if (isCompleted || completedCount >= totalJuz) {
      return 'Khatam Completed! Alhamdulillah!';
    }

    final diff = completedCount - expectedJuz;
    if (diff >= 0) {
      if (diff == 0) return 'You are on track! Keep going!';
      return 'You are $diff Juz ahead! MashaAllah!';
    } else {
      return 'You are ${diff.abs()} Juz behind. Try to catch up!';
    }
  }

  /// Copy with method
  QuranPlan copyWith({
    int? targetDays,
    DateTime? startDate,
    int? totalJuz,
    List<int>? completedJuz,
    bool? isCompleted,
  }) {
    return QuranPlan(
      targetDays: targetDays ?? this.targetDays,
      startDate: startDate ?? this.startDate,
      totalJuz: totalJuz ?? this.totalJuz,
      completedJuz: completedJuz ?? this.completedJuz,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'targetDays': targetDays,
      'startDate': startDate.toIso8601String(),
      'totalJuz': totalJuz,
      'completedJuz': completedJuz,
      'isCompleted': isCompleted,
    };
  }

  /// Create from JSON
  factory QuranPlan.fromJson(Map<String, dynamic> json) {
    return QuranPlan(
      targetDays: json['targetDays'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      totalJuz: json['totalJuz'] as int? ?? 30,
      completedJuz: (json['completedJuz'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

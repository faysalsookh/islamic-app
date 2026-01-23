import 'package:intl/intl.dart';

/// Model for Quran reading plan
class QuranPlan {
  final int targetDays; // 15, 20, or 30 days
  final DateTime startDate;
  final int completeQuranPages; // Standard Madani Mushaf is 604 pages
  final int startPage; // Usually 1
  final int currentPage; // Current progress
  final bool isCompleted;

  QuranPlan({
    required this.targetDays,
    required this.startDate,
    this.completeQuranPages = 604,
    this.startPage = 1,
    this.currentPage = 0,
    this.isCompleted = false,
  });

  /// Calculate pages to read per day
  int get pagesPerDay => (completeQuranPages / targetDays).ceil();

  /// Calculate days elapsed since start
  int get daysElapsed {
    final now = DateTime.now();
    final difference = now.difference(startDate).inDays;
    return difference < 0 ? 0 : difference + 1;
  }

  /// Calculate expected progress (page number) for today
  int get expectedPage {
    final expected = daysElapsed * pagesPerDay;
    return expected > completeQuranPages ? completeQuranPages : expected;
  }

  /// Calculate remaining pages
  int get remainingPages => completeQuranPages - currentPage;

  /// Calculate remaining days based on target date
  int get remainingDays {
    final endDate = startDate.add(Duration(days: targetDays));
    final difference = endDate.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Calculate adjusted pages per day based on remaining progress and days
  int get adjustedPagesPerDay {
    if (remainingDays <= 0) return remainingPages;
    return (remainingPages / remainingDays).ceil();
  }

  /// Check if user is on track
  bool get isOnTrack => currentPage >= expectedPage;

  /// Get status message
  String get statusMessage {
    if (isCompleted) return 'Khatam Completed! Alhamdulillah!';
    if (remainingPages <= 0) return 'Completed! MashaAllah!';
    
    final diff = currentPage - expectedPage;
    if (diff >= 0) {
      if (diff == 0) return 'You are on track!';
      return 'You are $diff pages ahead! MashaAllah!';
    } else {
      return 'You are ${diff.abs()} pages behind. Try to catch up!';
    }
  }

  /// Copy with method
  QuranPlan copyWith({
    int? targetDays,
    DateTime? startDate,
    int? completeQuranPages,
    int? startPage,
    int? currentPage,
    bool? isCompleted,
  }) {
    return QuranPlan(
      targetDays: targetDays ?? this.targetDays,
      startDate: startDate ?? this.startDate,
      completeQuranPages: completeQuranPages ?? this.completeQuranPages,
      startPage: startPage ?? this.startPage,
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'targetDays': targetDays,
      'startDate': startDate.toIso8601String(),
      'completeQuranPages': completeQuranPages,
      'startPage': startPage,
      'currentPage': currentPage,
      'isCompleted': isCompleted,
    };
  }

  /// Create from JSON
  factory QuranPlan.fromJson(Map<String, dynamic> json) {
    return QuranPlan(
      targetDays: json['targetDays'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      completeQuranPages: json['completeQuranPages'] as int? ?? 604,
      startPage: json['startPage'] as int? ?? 1,
      currentPage: json['currentPage'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

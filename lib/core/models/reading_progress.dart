/// Model representing the user's reading progress
class ReadingProgress {
  final int lastSurahNumber;
  final String lastSurahNameArabic;
  final String lastSurahNameEnglish;
  final int lastAyahNumber;
  final int totalAyahsRead;
  final DateTime lastReadAt;
  final double progressPercentage;

  const ReadingProgress({
    required this.lastSurahNumber,
    required this.lastSurahNameArabic,
    required this.lastSurahNameEnglish,
    required this.lastAyahNumber,
    required this.totalAyahsRead,
    required this.lastReadAt,
    required this.progressPercentage,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      lastSurahNumber: json['last_surah_number'] as int,
      lastSurahNameArabic: json['last_surah_name_arabic'] as String,
      lastSurahNameEnglish: json['last_surah_name_english'] as String,
      lastAyahNumber: json['last_ayah_number'] as int,
      totalAyahsRead: json['total_ayahs_read'] as int,
      lastReadAt: DateTime.parse(json['last_read_at'] as String),
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_surah_number': lastSurahNumber,
      'last_surah_name_arabic': lastSurahNameArabic,
      'last_surah_name_english': lastSurahNameEnglish,
      'last_ayah_number': lastAyahNumber,
      'total_ayahs_read': totalAyahsRead,
      'last_read_at': lastReadAt.toIso8601String(),
      'progress_percentage': progressPercentage,
    };
  }

  /// Creates a default empty progress
  factory ReadingProgress.empty() {
    return ReadingProgress(
      lastSurahNumber: 1,
      lastSurahNameArabic: 'الفاتحة',
      lastSurahNameEnglish: 'Al-Fatihah',
      lastAyahNumber: 1,
      totalAyahsRead: 0,
      lastReadAt: DateTime.now(),
      progressPercentage: 0.0,
    );
  }

  /// Sample progress for demonstration
  static ReadingProgress sampleProgress = ReadingProgress(
    lastSurahNumber: 2,
    lastSurahNameArabic: 'البقرة',
    lastSurahNameEnglish: 'Al-Baqarah',
    lastAyahNumber: 142,
    totalAyahsRead: 149, // 7 from Al-Fatihah + 142 from Al-Baqarah
    lastReadAt: DateTime.now().subtract(const Duration(hours: 3)),
    progressPercentage: 2.4, // 149/6236 * 100
  );
}

/// Model representing a bookmark/saved position in the Quran
class Bookmark {
  final String id;
  final int surahNumber;
  final String surahNameArabic;
  final String surahNameEnglish;
  final int ayahNumber;
  final String ayahSnippet;
  final DateTime createdAt;
  final String? label; // e.g., "Daily Read", "Memorization", "Review"
  final String? note;

  const Bookmark({
    required this.id,
    required this.surahNumber,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.ayahNumber,
    required this.ayahSnippet,
    required this.createdAt,
    this.label,
    this.note,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      surahNumber: json['surah_number'] as int,
      surahNameArabic: json['surah_name_arabic'] as String,
      surahNameEnglish: json['surah_name_english'] as String,
      ayahNumber: json['ayah_number'] as int,
      ayahSnippet: json['ayah_snippet'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      label: json['label'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah_number': surahNumber,
      'surah_name_arabic': surahNameArabic,
      'surah_name_english': surahNameEnglish,
      'ayah_number': ayahNumber,
      'ayah_snippet': ayahSnippet,
      'created_at': createdAt.toIso8601String(),
      'label': label,
      'note': note,
    };
  }

  Bookmark copyWith({
    String? id,
    int? surahNumber,
    String? surahNameArabic,
    String? surahNameEnglish,
    int? ayahNumber,
    String? ayahSnippet,
    DateTime? createdAt,
    String? label,
    String? note,
  }) {
    return Bookmark(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      surahNameArabic: surahNameArabic ?? this.surahNameArabic,
      surahNameEnglish: surahNameEnglish ?? this.surahNameEnglish,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      ayahSnippet: ayahSnippet ?? this.ayahSnippet,
      createdAt: createdAt ?? this.createdAt,
      label: label ?? this.label,
      note: note ?? this.note,
    );
  }
}

/// Predefined bookmark labels
class BookmarkLabels {
  static const String dailyRead = 'Daily Read';
  static const String memorization = 'Memorization';
  static const String review = 'Review';
  static const String favorite = 'Favorite';
  static const String study = 'Study';

  static const List<String> all = [
    dailyRead,
    memorization,
    review,
    favorite,
    study,
  ];
}

/// Sample bookmark data for demonstration
class BookmarkData {
  static final List<Bookmark> sampleBookmarks = [
    Bookmark(
      id: '1',
      surahNumber: 2,
      surahNameArabic: 'البقرة',
      surahNameEnglish: 'Al-Baqarah',
      ayahNumber: 255,
      ayahSnippet: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      label: BookmarkLabels.dailyRead,
    ),
    Bookmark(
      id: '2',
      surahNumber: 36,
      surahNameArabic: 'يس',
      surahNameEnglish: 'Ya-Sin',
      ayahNumber: 1,
      ayahSnippet: 'يس',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      label: BookmarkLabels.memorization,
    ),
    Bookmark(
      id: '3',
      surahNumber: 55,
      surahNameArabic: 'الرحمن',
      surahNameEnglish: 'Ar-Rahman',
      ayahNumber: 13,
      ayahSnippet: 'فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      label: BookmarkLabels.favorite,
    ),
  ];
}

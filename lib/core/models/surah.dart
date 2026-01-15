/// Model representing a Surah (chapter) of the Quran
class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTransliteration;
  final int ayahCount;
  final String revelationType; // 'Meccan' or 'Medinan'
  final int juzStart;

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTransliteration,
    required this.ayahCount,
    required this.revelationType,
    required this.juzStart,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      nameArabic: json['name_arabic'] as String,
      nameEnglish: json['name_english'] as String,
      nameTransliteration: json['name_transliteration'] as String,
      ayahCount: json['ayah_count'] as int,
      revelationType: json['revelation_type'] as String,
      juzStart: json['juz_start'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name_arabic': nameArabic,
      'name_english': nameEnglish,
      'name_transliteration': nameTransliteration,
      'ayah_count': ayahCount,
      'revelation_type': revelationType,
      'juz_start': juzStart,
    };
  }
}

/// Sample data for demonstration - first few surahs
class SurahData {
  static const List<Surah> surahs = [
    Surah(
      number: 1,
      nameArabic: 'الفاتحة',
      nameEnglish: 'The Opening',
      nameTransliteration: 'Al-Fatihah',
      ayahCount: 7,
      revelationType: 'Meccan',
      juzStart: 1,
    ),
    Surah(
      number: 2,
      nameArabic: 'البقرة',
      nameEnglish: 'The Cow',
      nameTransliteration: 'Al-Baqarah',
      ayahCount: 286,
      revelationType: 'Medinan',
      juzStart: 1,
    ),
    Surah(
      number: 3,
      nameArabic: 'آل عمران',
      nameEnglish: 'The Family of Imran',
      nameTransliteration: 'Ali \'Imran',
      ayahCount: 200,
      revelationType: 'Medinan',
      juzStart: 3,
    ),
    Surah(
      number: 4,
      nameArabic: 'النساء',
      nameEnglish: 'The Women',
      nameTransliteration: 'An-Nisa',
      ayahCount: 176,
      revelationType: 'Medinan',
      juzStart: 4,
    ),
    Surah(
      number: 5,
      nameArabic: 'المائدة',
      nameEnglish: 'The Table Spread',
      nameTransliteration: 'Al-Ma\'idah',
      ayahCount: 120,
      revelationType: 'Medinan',
      juzStart: 6,
    ),
    Surah(
      number: 36,
      nameArabic: 'يس',
      nameEnglish: 'Ya-Sin',
      nameTransliteration: 'Ya-Sin',
      ayahCount: 83,
      revelationType: 'Meccan',
      juzStart: 22,
    ),
    Surah(
      number: 55,
      nameArabic: 'الرحمن',
      nameEnglish: 'The Most Merciful',
      nameTransliteration: 'Ar-Rahman',
      ayahCount: 78,
      revelationType: 'Medinan',
      juzStart: 27,
    ),
    Surah(
      number: 67,
      nameArabic: 'الملك',
      nameEnglish: 'The Sovereignty',
      nameTransliteration: 'Al-Mulk',
      ayahCount: 30,
      revelationType: 'Meccan',
      juzStart: 29,
    ),
    Surah(
      number: 112,
      nameArabic: 'الإخلاص',
      nameEnglish: 'The Sincerity',
      nameTransliteration: 'Al-Ikhlas',
      ayahCount: 4,
      revelationType: 'Meccan',
      juzStart: 30,
    ),
    Surah(
      number: 113,
      nameArabic: 'الفلق',
      nameEnglish: 'The Daybreak',
      nameTransliteration: 'Al-Falaq',
      ayahCount: 5,
      revelationType: 'Meccan',
      juzStart: 30,
    ),
    Surah(
      number: 114,
      nameArabic: 'الناس',
      nameEnglish: 'Mankind',
      nameTransliteration: 'An-Nas',
      ayahCount: 6,
      revelationType: 'Meccan',
      juzStart: 30,
    ),
  ];
}

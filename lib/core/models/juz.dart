/// Model representing a Juz (part) of the Quran
/// The Quran is divided into 30 Juz for ease of reading
class Juz {
  /// The Juz number (1-30)
  final int number;

  /// Arabic name of the Juz (first word of the Juz)
  final String nameArabic;

  /// Transliteration of the Juz name
  final String nameTransliteration;

  /// The surah number where this Juz starts
  final int startSurah;

  /// The ayah number within the start surah where this Juz begins
  final int startAyah;

  /// The surah number where this Juz ends
  final int endSurah;

  /// The ayah number within the end surah where this Juz ends
  final int endAyah;

  const Juz({
    required this.number,
    required this.nameArabic,
    required this.nameTransliteration,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
  });

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      number: json['number'] as int,
      nameArabic: json['name_arabic'] as String,
      nameTransliteration: json['name_transliteration'] as String,
      startSurah: json['start_surah'] as int,
      startAyah: json['start_ayah'] as int,
      endSurah: json['end_surah'] as int,
      endAyah: json['end_ayah'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name_arabic': nameArabic,
      'name_transliteration': nameTransliteration,
      'start_surah': startSurah,
      'start_ayah': startAyah,
      'end_surah': endSurah,
      'end_ayah': endAyah,
    };
  }

  /// Get a formatted string showing the range of this Juz
  String get rangeDescription {
    return 'Surah $startSurah:$startAyah - Surah $endSurah:$endAyah';
  }
}

/// Static data containing all 30 Juz of the Quran
class JuzData {
  static const List<Juz> allJuz = [
    Juz(
      number: 1,
      nameArabic: 'الم',
      nameTransliteration: 'Alif Lam Meem',
      startSurah: 1,
      startAyah: 1,
      endSurah: 2,
      endAyah: 141,
    ),
    Juz(
      number: 2,
      nameArabic: 'سَيَقُولُ',
      nameTransliteration: 'Sayaqool',
      startSurah: 2,
      startAyah: 142,
      endSurah: 2,
      endAyah: 252,
    ),
    Juz(
      number: 3,
      nameArabic: 'تِلْكَ الرُّسُلُ',
      nameTransliteration: 'Tilkal Rusul',
      startSurah: 2,
      startAyah: 253,
      endSurah: 3,
      endAyah: 92,
    ),
    Juz(
      number: 4,
      nameArabic: 'لَن تَنَالُوا',
      nameTransliteration: 'Lan Tanaloo',
      startSurah: 3,
      startAyah: 93,
      endSurah: 4,
      endAyah: 23,
    ),
    Juz(
      number: 5,
      nameArabic: 'وَالْمُحْصَنَاتُ',
      nameTransliteration: 'Wal Muhsanaat',
      startSurah: 4,
      startAyah: 24,
      endSurah: 4,
      endAyah: 147,
    ),
    Juz(
      number: 6,
      nameArabic: 'لَا يُحِبُّ اللَّهُ',
      nameTransliteration: 'La Yuhibbullah',
      startSurah: 4,
      startAyah: 148,
      endSurah: 5,
      endAyah: 81,
    ),
    Juz(
      number: 7,
      nameArabic: 'وَإِذَا سَمِعُوا',
      nameTransliteration: 'Wa Iza Samiu',
      startSurah: 5,
      startAyah: 82,
      endSurah: 6,
      endAyah: 110,
    ),
    Juz(
      number: 8,
      nameArabic: 'وَلَوْ أَنَّنَا',
      nameTransliteration: 'Wa Law Annana',
      startSurah: 6,
      startAyah: 111,
      endSurah: 7,
      endAyah: 87,
    ),
    Juz(
      number: 9,
      nameArabic: 'قَالَ الْمَلَأُ',
      nameTransliteration: 'Qalal Malau',
      startSurah: 7,
      startAyah: 88,
      endSurah: 8,
      endAyah: 40,
    ),
    Juz(
      number: 10,
      nameArabic: 'وَاعْلَمُوا',
      nameTransliteration: 'Wa A\'lamu',
      startSurah: 8,
      startAyah: 41,
      endSurah: 9,
      endAyah: 92,
    ),
    Juz(
      number: 11,
      nameArabic: 'يَعْتَذِرُونَ',
      nameTransliteration: 'Ya\'taziroon',
      startSurah: 9,
      startAyah: 93,
      endSurah: 11,
      endAyah: 5,
    ),
    Juz(
      number: 12,
      nameArabic: 'وَمَا مِن دَابَّةٍ',
      nameTransliteration: 'Wa Ma Min Dabbah',
      startSurah: 11,
      startAyah: 6,
      endSurah: 12,
      endAyah: 52,
    ),
    Juz(
      number: 13,
      nameArabic: 'وَمَا أُبَرِّئُ',
      nameTransliteration: 'Wa Ma Ubarriu',
      startSurah: 12,
      startAyah: 53,
      endSurah: 14,
      endAyah: 52,
    ),
    Juz(
      number: 14,
      nameArabic: 'رُبَمَا',
      nameTransliteration: 'Rubama',
      startSurah: 15,
      startAyah: 1,
      endSurah: 16,
      endAyah: 128,
    ),
    Juz(
      number: 15,
      nameArabic: 'سُبْحَانَ الَّذِي',
      nameTransliteration: 'Subhanallazi',
      startSurah: 17,
      startAyah: 1,
      endSurah: 18,
      endAyah: 74,
    ),
    Juz(
      number: 16,
      nameArabic: 'قَالَ أَلَمْ',
      nameTransliteration: 'Qala Alam',
      startSurah: 18,
      startAyah: 75,
      endSurah: 20,
      endAyah: 135,
    ),
    Juz(
      number: 17,
      nameArabic: 'اقْتَرَبَ لِلنَّاسِ',
      nameTransliteration: 'Iqtaraba Linnas',
      startSurah: 21,
      startAyah: 1,
      endSurah: 22,
      endAyah: 78,
    ),
    Juz(
      number: 18,
      nameArabic: 'قَدْ أَفْلَحَ',
      nameTransliteration: 'Qad Aflaha',
      startSurah: 23,
      startAyah: 1,
      endSurah: 25,
      endAyah: 20,
    ),
    Juz(
      number: 19,
      nameArabic: 'وَقَالَ الَّذِينَ',
      nameTransliteration: 'Wa Qalallazina',
      startSurah: 25,
      startAyah: 21,
      endSurah: 27,
      endAyah: 55,
    ),
    Juz(
      number: 20,
      nameArabic: 'أَمَّنْ خَلَقَ',
      nameTransliteration: 'Amman Khalaq',
      startSurah: 27,
      startAyah: 56,
      endSurah: 29,
      endAyah: 45,
    ),
    Juz(
      number: 21,
      nameArabic: 'اتْلُ مَا أُوحِيَ',
      nameTransliteration: 'Utlu Ma Uhiya',
      startSurah: 29,
      startAyah: 46,
      endSurah: 33,
      endAyah: 30,
    ),
    Juz(
      number: 22,
      nameArabic: 'وَمَن يَقْنُتْ',
      nameTransliteration: 'Wa Man Yaqnut',
      startSurah: 33,
      startAyah: 31,
      endSurah: 36,
      endAyah: 27,
    ),
    Juz(
      number: 23,
      nameArabic: 'وَمَا لِيَ',
      nameTransliteration: 'Wa Mali',
      startSurah: 36,
      startAyah: 28,
      endSurah: 39,
      endAyah: 31,
    ),
    Juz(
      number: 24,
      nameArabic: 'فَمَنْ أَظْلَمُ',
      nameTransliteration: 'Faman Azlam',
      startSurah: 39,
      startAyah: 32,
      endSurah: 41,
      endAyah: 46,
    ),
    Juz(
      number: 25,
      nameArabic: 'إِلَيْهِ يُرَدُّ',
      nameTransliteration: 'Ilaihi Yurad',
      startSurah: 41,
      startAyah: 47,
      endSurah: 45,
      endAyah: 37,
    ),
    Juz(
      number: 26,
      nameArabic: 'حم',
      nameTransliteration: 'Ha Meem',
      startSurah: 46,
      startAyah: 1,
      endSurah: 51,
      endAyah: 30,
    ),
    Juz(
      number: 27,
      nameArabic: 'قَالَ فَمَا خَطْبُكُمْ',
      nameTransliteration: 'Qala Fama Khatbukum',
      startSurah: 51,
      startAyah: 31,
      endSurah: 57,
      endAyah: 29,
    ),
    Juz(
      number: 28,
      nameArabic: 'قَدْ سَمِعَ اللَّهُ',
      nameTransliteration: 'Qad Sami Allah',
      startSurah: 58,
      startAyah: 1,
      endSurah: 66,
      endAyah: 12,
    ),
    Juz(
      number: 29,
      nameArabic: 'تَبَارَكَ الَّذِي',
      nameTransliteration: 'Tabarakallazi',
      startSurah: 67,
      startAyah: 1,
      endSurah: 77,
      endAyah: 50,
    ),
    Juz(
      number: 30,
      nameArabic: 'عَمَّ',
      nameTransliteration: 'Amma',
      startSurah: 78,
      startAyah: 1,
      endSurah: 114,
      endAyah: 6,
    ),
  ];

  /// Get a Juz by its number
  static Juz? getJuz(int number) {
    if (number < 1 || number > 30) return null;
    return allJuz[number - 1];
  }

  /// Get the Juz that contains a specific surah and ayah
  static Juz? getJuzForAyah(int surahNumber, int ayahNumber) {
    for (final juz in allJuz) {
      // Check if ayah is within this Juz range
      if (_isAyahInJuz(surahNumber, ayahNumber, juz)) {
        return juz;
      }
    }
    return null;
  }

  /// Helper method to check if an ayah is within a Juz
  static bool _isAyahInJuz(int surahNumber, int ayahNumber, Juz juz) {
    // If surah is before start surah, not in this Juz
    if (surahNumber < juz.startSurah) return false;

    // If surah is after end surah, not in this Juz
    if (surahNumber > juz.endSurah) return false;

    // If in start surah, check ayah number
    if (surahNumber == juz.startSurah && ayahNumber < juz.startAyah) {
      return false;
    }

    // If in end surah, check ayah number
    if (surahNumber == juz.endSurah && ayahNumber > juz.endAyah) {
      return false;
    }

    return true;
  }
}

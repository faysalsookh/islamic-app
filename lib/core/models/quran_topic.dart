import 'package:flutter/material.dart';

/// Model representing a thematic topic in Quran
class QuranTopic {
  final String id;
  final String nameBengali;
  final String nameEnglish;
  final String nameArabic;
  final String descriptionBengali;
  final String descriptionEnglish;
  final IconData icon;
  final Color color;
  final List<QuranTopicCategory> categories;
  final int totalVerses;

  const QuranTopic({
    required this.id,
    required this.nameBengali,
    required this.nameEnglish,
    required this.nameArabic,
    required this.descriptionBengali,
    required this.descriptionEnglish,
    required this.icon,
    required this.color,
    required this.categories,
    required this.totalVerses,
  });
}

/// Model representing a sub-category within a topic
class QuranTopicCategory {
  final String id;
  final String nameBengali;
  final String nameEnglish;
  final String? descriptionBengali;
  final String? descriptionEnglish;
  final List<VerseReference> verses;

  const QuranTopicCategory({
    required this.id,
    required this.nameBengali,
    required this.nameEnglish,
    this.descriptionBengali,
    this.descriptionEnglish,
    required this.verses,
  });
}

/// Model representing a reference to a Quran verse
class VerseReference {
  final int surahNumber;
  final int startAyah;
  final int? endAyah; // null if single ayah

  const VerseReference({
    required this.surahNumber,
    required this.startAyah,
    this.endAyah,
  });

  /// Returns display string like "2:255" or "2:1-5"
  String get displayReference {
    if (endAyah != null && endAyah != startAyah) {
      return '$surahNumber:$startAyah-$endAyah';
    }
    return '$surahNumber:$startAyah';
  }

  /// Returns the number of verses in this reference
  int get verseCount {
    if (endAyah == null) return 1;
    return (endAyah! - startAyah + 1);
  }
}

/// Model for word frequency statistics in Quran
class QuranWordStat {
  final String wordBengali;
  final String wordArabic;
  final String? wordEnglish;
  final int count;

  const QuranWordStat({
    required this.wordBengali,
    required this.wordArabic,
    this.wordEnglish,
    required this.count,
  });
}

/// Model for Sajdah (Prostration) verses
class SajdahVerse {
  final int number;
  final String nameBengali;
  final int juzNumber;
  final String surahNameBengali;
  final String surahNameArabic;
  final int surahNumber;
  final int ayahNumber;

  const SajdahVerse({
    required this.number,
    required this.nameBengali,
    required this.juzNumber,
    required this.surahNameBengali,
    required this.surahNameArabic,
    required this.surahNumber,
    required this.ayahNumber,
  });
}

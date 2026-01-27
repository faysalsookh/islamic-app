/// Types of daily guidance content
enum DailyGuidanceType {
  ayah,
  hadith,
  dua,
  dhikr,
  reflection,
  dailyDeed,
}

/// Extension for display properties
extension DailyGuidanceTypeExtension on DailyGuidanceType {
  String get label {
    switch (this) {
      case DailyGuidanceType.ayah:
        return 'Ayah';
      case DailyGuidanceType.hadith:
        return 'Hadith';
      case DailyGuidanceType.dua:
        return 'Dua';
      case DailyGuidanceType.dhikr:
        return 'Dhikr';
      case DailyGuidanceType.reflection:
        return 'Reflection';
      case DailyGuidanceType.dailyDeed:
        return 'Daily Deed';
    }
  }

  String get emoji {
    switch (this) {
      case DailyGuidanceType.ayah:
        return 'Quran';
      case DailyGuidanceType.hadith:
        return 'Hadith';
      case DailyGuidanceType.dua:
        return 'Dua';
      case DailyGuidanceType.dhikr:
        return 'Dhikr';
      case DailyGuidanceType.reflection:
        return 'Reflect';
      case DailyGuidanceType.dailyDeed:
        return 'Deed';
    }
  }
}

/// A single daily guidance content item
class DailyGuidanceItem {
  final int dayNumber;
  final DailyGuidanceType type;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String reference;
  final String? subtitle;

  const DailyGuidanceItem({
    required this.dayNumber,
    required this.type,
    required this.arabicText,
    this.transliteration = '',
    required this.translation,
    required this.reference,
    this.subtitle,
  });

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'type': type.index,
        'arabicText': arabicText,
        'transliteration': transliteration,
        'translation': translation,
        'reference': reference,
        'subtitle': subtitle,
      };

  factory DailyGuidanceItem.fromJson(Map<String, dynamic> json) {
    return DailyGuidanceItem(
      dayNumber: json['dayNumber'] as int,
      type: DailyGuidanceType.values[json['type'] as int],
      arabicText: json['arabicText'] as String,
      transliteration: (json['transliteration'] as String?) ?? '',
      translation: json['translation'] as String,
      reference: json['reference'] as String,
      subtitle: json['subtitle'] as String?,
    );
  }
}

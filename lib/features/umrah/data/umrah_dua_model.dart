/// Model class for Umrah Dua
class UmrahDua {
  final int id;
  final String titleEnglish;
  final String titleArabic;
  final String arabicText;
  final String transliteration;
  final String translationEnglish;
  final String? translationBengali;
  final String? reference;
  final String category;

  const UmrahDua({
    required this.id,
    required this.titleEnglish,
    this.titleArabic = '',
    required this.arabicText,
    required this.transliteration,
    required this.translationEnglish,
    this.translationBengali,
    this.reference,
    required this.category,
  });
}

/// Categories for Umrah duas
class UmrahDuaCategory {
  static const String preparation = 'Preparation';
  static const String journey = 'Journey';
  static const String ihram = 'Ihram';
  static const String tawaf = 'Tawaf';
  static const String sai = "Sa'i";
  static const String zamzam = 'Zamzam';
  static const String general = 'General';
}

/// Model representing an Ayah (verse) of the Quran
class Ayah {
  final int number;
  final int numberInSurah;
  final int surahNumber;
  final String textArabic;
  final String? translationEnglish;
  final String? translationBengali;
  final int juz;
  final int page;
  final int hizbQuarter;

  const Ayah({
    required this.number,
    required this.numberInSurah,
    required this.surahNumber,
    required this.textArabic,
    this.translationEnglish,
    this.translationBengali,
    required this.juz,
    required this.page,
    required this.hizbQuarter,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] as int,
      numberInSurah: json['number_in_surah'] as int,
      surahNumber: json['surah_number'] as int,
      textArabic: json['text_arabic'] as String,
      translationEnglish: json['translation_english'] as String?,
      translationBengali: json['translation_bengali'] as String?,
      juz: json['juz'] as int,
      page: json['page'] as int,
      hizbQuarter: json['hizb_quarter'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'number_in_surah': numberInSurah,
      'surah_number': surahNumber,
      'text_arabic': textArabic,
      'translation_english': translationEnglish,
      'translation_bengali': translationBengali,
      'juz': juz,
      'page': page,
      'hizb_quarter': hizbQuarter,
    };
  }
}

/// Sample Ayah data for Al-Fatihah (Surah 1) for demonstration
class AyahData {
  static const List<Ayah> alFatihah = [
    Ayah(
      number: 1,
      numberInSurah: 1,
      surahNumber: 1,
      textArabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      translationEnglish: 'In the name of Allah, the Most Gracious, the Most Merciful.',
      translationBengali: 'পরম করুণাময় অতি দয়ালু আল্লাহর নামে।',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 2,
      numberInSurah: 2,
      surahNumber: 1,
      textArabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      translationEnglish: 'All praise is due to Allah, Lord of all the worlds.',
      translationBengali: 'যাবতীয় প্রশংসা আল্লাহ তাআলার যিনি সকল সৃষ্টি জগতের পালনকর্তা।',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 3,
      numberInSurah: 3,
      surahNumber: 1,
      textArabic: 'الرَّحْمَٰنِ الرَّحِيمِ',
      translationEnglish: 'The Most Gracious, the Most Merciful.',
      translationBengali: 'দয়াময়, পরম দয়ালু।',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 4,
      numberInSurah: 4,
      surahNumber: 1,
      textArabic: 'مَالِكِ يَوْمِ الدِّينِ',
      translationEnglish: 'Master of the Day of Judgment.',
      translationBengali: 'বিচার দিনের মালিক।',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 5,
      numberInSurah: 5,
      surahNumber: 1,
      textArabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      translationEnglish: 'You alone we worship, and You alone we ask for help.',
      translationBengali: 'আমরা একমাত্র তোমারই ইবাদত করি এবং শুধুমাত্র তোমারই সাহায্য প্রার্থনা করি।',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 6,
      numberInSurah: 6,
      surahNumber: 1,
      textArabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      translationEnglish: 'Guide us to the straight path.',
      translationBengali: 'আমাদের সরল পথ দেখাও।',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 7,
      numberInSurah: 7,
      surahNumber: 1,
      textArabic: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      translationEnglish: 'The path of those upon whom You have bestowed favor, not of those who have earned [Your] anger or of those who are astray.',
      translationBengali: 'সে সমস্ত লোকের পথ, যাদেরকে তুমি নেয়ামত দান করেছ। তাদের পথ নয়, যাদের প্রতি তোমার গজব নাযিল হয়েছে এবং যারা পথভ্রষ্ট হয়েছে।',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
  ];

  /// Sample ayahs for Surah Al-Ikhlas (112)
  static const List<Ayah> alIkhlas = [
    Ayah(
      number: 6222,
      numberInSurah: 1,
      surahNumber: 112,
      textArabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      translationEnglish: 'Say, "He is Allah, [who is] One.',
      translationBengali: 'বলুন, তিনি আল্লাহ, এক।',
      juz: 30,
      page: 604,
      hizbQuarter: 240,
    ),
    Ayah(
      number: 6223,
      numberInSurah: 2,
      surahNumber: 112,
      textArabic: 'اللَّهُ الصَّمَدُ',
      translationEnglish: 'Allah, the Eternal Refuge.',
      translationBengali: 'আল্লাহ অমুখাপেক্ষী।',
      juz: 30,
      page: 604,
      hizbQuarter: 240,
    ),
    Ayah(
      number: 6224,
      numberInSurah: 3,
      surahNumber: 112,
      textArabic: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
      translationEnglish: 'He neither begets nor is born.',
      translationBengali: 'তিনি কাউকে জন্ম দেননি এবং কেউ তাঁকে জন্ম দেয়নি।',
      juz: 30,
      page: 604,
      hizbQuarter: 240,
    ),
    Ayah(
      number: 6225,
      numberInSurah: 4,
      surahNumber: 112,
      textArabic: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      translationEnglish: 'Nor is there to Him any equivalent.',
      translationBengali: 'এবং তাঁর সমতুল্য কেউ নেই।',
      juz: 30,
      page: 604,
      hizbQuarter: 240,
    ),
  ];
}

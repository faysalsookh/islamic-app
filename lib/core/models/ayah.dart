/// Model representing an Ayah (verse) of the Quran
class Ayah {
  final int number;
  final int numberInSurah;
  final int surahNumber;
  final String textArabic;
  final String? textWithTajweed; // Arabic text with Tajweed markup
  final String? translationEnglish;
  final String? translationBengali;
  final String? transliterationEnglish;
  final String? transliterationBengali;
  final String? tafsir; // Explanation/interpretation
  final String? shaniNuzul; // Context of revelation
  final String? audioUrl; // URL to ayah audio file
  final int juz;
  final int page;
  final int hizbQuarter;

  const Ayah({
    required this.number,
    required this.numberInSurah,
    required this.surahNumber,
    required this.textArabic,
    this.textWithTajweed,
    this.translationEnglish,
    this.translationBengali,
    this.transliterationEnglish,
    this.transliterationBengali,
    this.tafsir,
    this.shaniNuzul,
    this.audioUrl,
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
      textWithTajweed: json['text_with_tajweed'] as String?,
      translationEnglish: json['translation_english'] as String?,
      translationBengali: json['translation_bengali'] as String?,
      transliterationEnglish: json['transliteration_english'] as String?,
      transliterationBengali: json['transliteration_bengali'] as String?,
      tafsir: json['tafsir'] as String?,
      shaniNuzul: json['shani_nuzul'] as String?,
      audioUrl: json['audio_url'] as String?,
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
      'text_with_tajweed': textWithTajweed,
      'translation_english': translationEnglish,
      'translation_bengali': translationBengali,
      'transliteration_english': transliterationEnglish,
      'transliteration_bengali': transliterationBengali,
      'tafsir': tafsir,
      'shani_nuzul': shaniNuzul,
      'audio_url': audioUrl,
      'juz': juz,
      'page': page,
      'hizb_quarter': hizbQuarter,
    };
  }

  /// Create a copy with updated fields
  Ayah copyWith({
    int? number,
    int? numberInSurah,
    int? surahNumber,
    String? textArabic,
    String? textWithTajweed,
    String? translationEnglish,
    String? translationBengali,
    String? transliterationEnglish,
    String? transliterationBengali,
    String? tafsir,
    String? shaniNuzul,
    String? audioUrl,
    int? juz,
    int? page,
    int? hizbQuarter,
  }) {
    return Ayah(
      number: number ?? this.number,
      numberInSurah: numberInSurah ?? this.numberInSurah,
      surahNumber: surahNumber ?? this.surahNumber,
      textArabic: textArabic ?? this.textArabic,
      textWithTajweed: textWithTajweed ?? this.textWithTajweed,
      translationEnglish: translationEnglish ?? this.translationEnglish,
      translationBengali: translationBengali ?? this.translationBengali,
      transliterationEnglish: transliterationEnglish ?? this.transliterationEnglish,
      transliterationBengali: transliterationBengali ?? this.transliterationBengali,
      tafsir: tafsir ?? this.tafsir,
      shaniNuzul: shaniNuzul ?? this.shaniNuzul,
      audioUrl: audioUrl ?? this.audioUrl,
      juz: juz ?? this.juz,
      page: page ?? this.page,
      hizbQuarter: hizbQuarter ?? this.hizbQuarter,
    );
  }
}

/// Sample Ayah data for Al-Fatihah (Surah 1) with Tajweed markup
/// Tajweed colors follow the Bengali Quran standard:
/// - Red (ghunnah): غُنَّة - Nasalization
/// - Blue (ikhfa): إخفاء - Concealment
/// - Brown (qalqalah): قلقلة - Echoing
/// - Green (idgham): إدغام - Assimilation
/// - Purple (iqlab): إقلاب - Conversion
/// - Dark Blue (izhar): إظهار - Clear pronunciation
/// - Orange (safir): صفير - Whistling sound (ص ز س)
/// - Pink (madd): مد - Elongation
class AyahData {
  static const List<Ayah> alFatihah = [
    Ayah(
      number: 1,
      numberInSurah: 1,
      surahNumber: 1,
      textArabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      textWithTajweed: 'بِ<safir>سْ</safir>مِ اللَّهِ <ghunnah>ال</ghunnah>رَّحْ<madd>مَٰ</madd>نِ الرَّحِيمِ',
      translationEnglish: 'In the name of Allah, the Most Gracious, the Most Merciful.',
      translationBengali: 'পরম করুণাময় অতি দয়ালু আল্লাহর নামে।',
      transliterationEnglish: 'Bismillahir Rahmanir Raheem',
      transliterationBengali: 'বিসমিল্লাহির রাহমানির রাহীম',
      tafsir: 'This verse is known as Basmalah (بسملة). It is recommended to begin every action with this phrase, seeking Allah\'s blessings. The verse contains three of Allah\'s beautiful names: Allah (الله) - the proper name of God, Ar-Rahman (الرحمن) - The Most Gracious, and Ar-Raheem (الرحيم) - The Most Merciful.',
      shaniNuzul: 'Surah Al-Fatihah was revealed in Makkah and is one of the earliest surahs. It is also called "The Opening" as it opens the Quran, and "The Mother of the Book" (Umm al-Kitab) due to its comprehensive nature.',
      audioUrl: 'audio/001001.mp3',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 2,
      numberInSurah: 2,
      surahNumber: 1,
      textArabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      textWithTajweed: 'الْحَمْ<qalqalah>دُ</qalqalah> لِلَّهِ رَ<qalqalah>بِّ</qalqalah> الْعَ<madd>ا</madd>لَمِينَ',
      translationEnglish: 'All praise is due to Allah, Lord of all the worlds.',
      translationBengali: 'যাবতীয় প্রশংসা আল্লাহ তাআলার যিনি সকল সৃষ্টি জগতের পালনকর্তা।',
      transliterationEnglish: 'Alhamdu lillahi Rabbil Aalameen',
      transliterationBengali: 'আলহামদু লিল্লাহি রাব্বিল আলামীন',
      tafsir: 'This verse establishes that all praise and gratitude belong exclusively to Allah. "Rabb" means Lord, Sustainer, and Nurturer. "Aalameen" refers to all worlds - humans, jinn, angels, animals, and all creation.',
      shaniNuzul: 'This verse teaches Muslims to begin with praising Allah before making any request, establishing the proper etiquette of supplication.',
      audioUrl: 'audio/001002.mp3',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 3,
      numberInSurah: 3,
      surahNumber: 1,
      textArabic: 'الرَّحْمَٰنِ الرَّحِيمِ',
      textWithTajweed: '<ghunnah>ال</ghunnah>رَّحْ<madd>مَٰ</madd>نِ الرَّحِيمِ',
      translationEnglish: 'The Most Gracious, the Most Merciful.',
      translationBengali: 'দয়াময়, পরম দয়ালু।',
      transliterationEnglish: 'Ar-Rahmanir Raheem',
      transliterationBengali: 'আর-রাহমানির রাহীম',
      tafsir: 'Ar-Rahman indicates Allah\'s mercy that encompasses all creation in this world. Ar-Raheem indicates His special mercy reserved for believers in the Hereafter. Both names derive from "rahmah" (mercy).',
      shaniNuzul: 'The repetition of these attributes after the Basmalah emphasizes the central role of mercy in Islam.',
      audioUrl: 'audio/001003.mp3',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 4,
      numberInSurah: 4,
      surahNumber: 1,
      textArabic: 'مَالِكِ يَوْمِ الدِّينِ',
      textWithTajweed: '<madd>مَا</madd>لِكِ يَوْمِ ال<qalqalah>دِّ</qalqalah>ينِ',
      translationEnglish: 'Master of the Day of Judgment.',
      translationBengali: 'বিচার দিনের মালিক।',
      transliterationEnglish: 'Maliki Yawmid-Deen',
      transliterationBengali: 'মালিকি ইয়াওমিদ্দীন',
      tafsir: 'This verse affirms that Allah alone is the Master and Owner of the Day of Judgment. On that day, no one will have any authority except by His permission. "Deen" here means recompense or judgment.',
      shaniNuzul: 'This verse instills awareness of accountability and reminds believers that all will return to Allah for judgment.',
      audioUrl: 'audio/001004.mp3',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 5,
      numberInSurah: 5,
      surahNumber: 1,
      textArabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      textWithTajweed: 'إِيَّاكَ <ikhfa>نَ</ikhfa>عْ<qalqalah>بُ</qalqalah>دُ وَإِيَّاكَ <ikhfa>نَ</ikhfa><safir>سْ</safir>تَعِينُ',
      translationEnglish: 'You alone we worship, and You alone we ask for help.',
      translationBengali: 'আমরা একমাত্র তোমারই ইবাদত করি এবং শুধুমাত্র তোমারই সাহায্য প্রার্থনা করি।',
      transliterationEnglish: 'Iyyaka na\'budu wa iyyaka nasta\'een',
      transliterationBengali: 'ইয়্যাকা না\'বুদু ওয়া ইয়্যাকা নাসতাঈন',
      tafsir: 'This is the central verse of the surah, establishing Tawheed (monotheism). Worship and seeking help are directed only to Allah. The plural "we" indicates the collective nature of Muslim worship.',
      shaniNuzul: 'This verse marks the transition from praise to supplication, teaching proper etiquette: praise Allah first, then make requests.',
      audioUrl: 'audio/001005.mp3',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 6,
      numberInSurah: 6,
      surahNumber: 1,
      textArabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      textWithTajweed: 'اهْ<qalqalah>دِ</qalqalah><izhar>نَا</izhar> ال<safir>صِّ</safir>رَ<madd>ا</madd><qalqalah>طَ</qalqalah> الْمُ<safir>سْ</safir>تَ<ikhfa>قِ</ikhfa>يمَ',
      translationEnglish: 'Guide us to the straight path.',
      translationBengali: 'আমাদের সরল পথ দেখাও।',
      transliterationEnglish: 'Ihdinas-Siratal Mustaqeem',
      transliterationBengali: 'ইহদিনাস সিরাতাল মুস্তাকীম',
      tafsir: 'This is the main supplication of the surah. "Sirat al-Mustaqeem" is the straight path of Islam - the path of truth, righteousness, and submission to Allah.',
      shaniNuzul: 'Muslims recite this prayer in every unit of prayer, constantly asking Allah for guidance, recognizing their need for divine direction.',
      audioUrl: 'audio/001006.mp3',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
    Ayah(
      number: 7,
      numberInSurah: 7,
      surahNumber: 1,
      textArabic: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      textWithTajweed: '<safir>صِ</safir>رَ<madd>ا</madd><qalqalah>طَ</qalqalah> الَّذِينَ <izhar>أَ</izhar><ikhfa>نْ</ikhfa>عَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْ<ikhfa>ضُ</ikhfa>وبِ عَلَيْهِمْ وَلَا ال<ikhfa>ضَّ</ikhfa><madd>ا</madd>لِّينَ',
      translationEnglish: 'The path of those upon whom You have bestowed favor, not of those who have earned [Your] anger or of those who are astray.',
      translationBengali: 'সে সমস্ত লোকের পথ, যাদেরকে তুমি নেয়ামত দান করেছ। তাদের পথ নয়, যাদের প্রতি তোমার গজব নাযিল হয়েছে এবং যারা পথভ্রষ্ট হয়েছে।',
      transliterationEnglish: 'Siratal lazeena an\'amta alaihim, ghairil maghdoobi alaihim wa lad-daalleen',
      transliterationBengali: 'সিরাতাল লাযীনা আন\'আমতা আলাইহিম গাইরিল মাগদূবি আলাইহিম ওয়ালাদ দ্বাল্লীন',
      tafsir: 'Those favored are the prophets, truthful ones, martyrs, and righteous. The surah concludes by asking to avoid the paths of those who knew the truth but rejected it, and those who went astray due to ignorance.',
      shaniNuzul: 'This verse teaches Muslims to seek role models among the righteous and to avoid the mistakes of previous nations.',
      audioUrl: 'audio/001007.mp3',
      juz: 1,
      page: 1,
      hizbQuarter: 1,
    ),
  ];

  /// Sample ayahs for Surah Al-Ikhlas (112) with Tajweed markup
  static const List<Ayah> alIkhlas = [
    Ayah(
      number: 6222,
      numberInSurah: 1,
      surahNumber: 112,
      textArabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      textWithTajweed: '<qalqalah>قُلْ</qalqalah> هُوَ اللَّهُ <izhar>أَ</izhar>حَ<qalqalah>دٌ</qalqalah>',
      translationEnglish: 'Say, "He is Allah, [who is] One.',
      translationBengali: 'বলুন, তিনি আল্লাহ, এক।',
      transliterationEnglish: 'Qul Huwal-lahu Ahad',
      transliterationBengali: 'কুল হুওয়াল্লাহু আহাদ',
      tafsir: 'This surah affirms the absolute oneness of Allah (Tawheed). "Ahad" means unique, one without any partner or equal. This is the fundamental belief of Islam.',
      shaniNuzul: 'This surah was revealed when the polytheists asked Prophet Muhammad (peace be upon him) to describe Allah. It is said to be equivalent to one-third of the Quran in reward.',
      audioUrl: 'audio/112001.mp3',
      juz: 30,
      page: 604,
      hizbQuarter: 240,
    ),
    Ayah(
      number: 6223,
      numberInSurah: 2,
      surahNumber: 112,
      textArabic: 'اللَّهُ الصَّمَدُ',
      textWithTajweed: 'اللَّهُ ال<safir>صَّ</safir>مَ<qalqalah>دُ</qalqalah>',
      translationEnglish: 'Allah, the Eternal Refuge.',
      translationBengali: 'আল্লাহ অমুখাপেক্ষী।',
      transliterationEnglish: 'Allahus-Samad',
      transliterationBengali: 'আল্লাহুস সামাদ',
      tafsir: 'As-Samad means the Self-Sufficient Master whom all creatures need. He neither eats nor drinks, is not in need of anything, while everything is in need of Him.',
      shaniNuzul: 'This attribute distinguishes Allah from all creation, as every created being has needs and dependencies.',
      audioUrl: 'audio/112002.mp3',
      juz: 30,
      page: 604,
      hizbQuarter: 240,
    ),
    Ayah(
      number: 6224,
      numberInSurah: 3,
      surahNumber: 112,
      textArabic: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
      textWithTajweed: 'لَمْ يَلِ<qalqalah>دْ</qalqalah> وَلَمْ <madd>يُو</madd>لَ<qalqalah>دْ</qalqalah>',
      translationEnglish: 'He neither begets nor is born.',
      translationBengali: 'তিনি কাউকে জন্ম দেননি এবং কেউ তাঁকে জন্ম দেয়নি।',
      transliterationEnglish: 'Lam yalid wa lam yoolad',
      transliterationBengali: 'লাম ইয়ালিদ ওয়া লাম ইউলাদ',
      tafsir: 'This verse negates any biological relationship for Allah. He has no children, parents, or family. This refutes beliefs that attribute offspring to Allah.',
      shaniNuzul: 'This was revealed to clarify Islamic monotheism against beliefs that attributed children or parents to God.',
      audioUrl: 'audio/112003.mp3',
      juz: 30,
      page: 604,
      hizbQuarter: 240,
    ),
    Ayah(
      number: 6225,
      numberInSurah: 4,
      surahNumber: 112,
      textArabic: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      textWithTajweed: 'وَلَمْ يَ<idgham>كُن لَّ</idgham>هُ <ghunnah>كُفُوً</ghunnah>ا <izhar>أَ</izhar>حَ<qalqalah>دٌ</qalqalah>',
      translationEnglish: 'Nor is there to Him any equivalent.',
      translationBengali: 'এবং তাঁর সমতুল্য কেউ নেই।',
      transliterationEnglish: 'Wa lam yakun lahu kufuwan ahad',
      transliterationBengali: 'ওয়া লাম ইয়াকুন লাহু কুফুওয়ান আহাদ',
      tafsir: 'No one is comparable or equal to Allah in His essence, attributes, or actions. This completes the description of pure monotheism.',
      shaniNuzul: 'This verse concludes the surah by establishing that nothing in creation can be compared to Allah.',
      audioUrl: 'audio/112004.mp3',
      juz: 30,
      page: 604,
      hizbQuarter: 240,
    ),
  ];
}

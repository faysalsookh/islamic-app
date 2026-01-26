import 'umrah_dua_model.dart';

/// Complete collection of Umrah Duas
class UmrahDuasData {
  static const List<UmrahDua> duas = [
    // 01 - Leaving Home
    UmrahDua(
      id: 1,
      titleEnglish: 'Leaving Home',
      titleArabic: 'دعاء الخروج من المنزل',
      arabicText:
          'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ',
      transliteration:
          "Bismillaahi, tawakkaltu 'alallaahi, wa laa hawla wa laa quwwata 'illaa billaah.",
      translationEnglish:
          'In the name of Allah, I place my trust in Allah, and there is no might nor power except with Allah.',
      translationBengali:
          'আল্লাহর নামে, আমি আল্লাহর উপর ভরসা করলাম, আল্লাহ ছাড়া কোনো শক্তি ও ক্ষমতা নেই।',
      reference: 'Abu Dawud, Tirmidhi',
      category: UmrahDuaCategory.preparation,
    ),

    // 02 - Intention/Niyyah
    UmrahDua(
      id: 2,
      titleEnglish: 'Intention/Niyyah',
      titleArabic: 'النية',
      arabicText:
          'لَبَّيْكَ اللَّهُمَّ عُمْرَةً اللَّهُمَّ إِنِّي أُرِيدُ الْعُمْرَةَ اللَّهُمَّ إِنِّي أُرِيدُ الْعُمْرَةَ فَيَسِّرْهَا لِي وَتَقَبَّلْهَا مِنِّي',
      transliteration:
          'Labbayk Allahumma Umrah. Allahumma Innee Ureedul Umrah. Allahumma Innee Ureedul Umrata fa-Yassir haa.',
      translationEnglish:
          'O Allah, here I am to perform Umrah. O Allah, I intend to perform Umrah. O Allah, I intend to perform Umrah, so accept it from me and make it easy for me.',
      translationBengali:
          'হে আল্লাহ, আমি উমরাহ পালন করতে হাজির। হে আল্লাহ, আমি উমরাহ করার নিয়ত করছি। হে আল্লাহ, আমি উমরাহ করতে চাই, তাই এটি আমার জন্য সহজ করুন এবং আমার কাছ থেকে এটি কবুল করুন।',
      reference: 'Bukhari, Muslim',
      category: UmrahDuaCategory.ihram,
    ),

    // 03 - Talbiyah
    UmrahDua(
      id: 3,
      titleEnglish: 'Talbiyah',
      titleArabic: 'التلبية',
      arabicText:
          'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ لَا شَرِيكَ لَكَ',
      transliteration:
          "Labbayka llāhumma labbayk(a), labbayka lā sharīka laka labbayk(a), inna l-hamda wa n-ni'mata, laka wa l-mulk(a), lā sharīka lak.",
      translationEnglish:
          'At Your service, Allah, at Your service. At Your service, You have no partner, at Your service. Truly all praise, favour and sovereignty is Yours. You have no partner.',
      translationBengali:
          'আমি হাজির, হে আল্লাহ, আমি হাজির। আমি হাজির, আপনার কোনো শরীক নেই, আমি হাজির। নিশ্চয়ই সমস্ত প্রশংসা, নিয়ামত ও রাজত্ব আপনারই। আপনার কোনো শরীক নেই।',
      reference: 'Bukhari, Muslim',
      category: UmrahDuaCategory.ihram,
    ),

    // 04 - Seeing the Ka'abah
    UmrahDua(
      id: 4,
      titleEnglish: "Seeing the Ka'abah",
      titleArabic: 'رؤية الكعبة',
      arabicText:
          'اللَّهُمَّ زِدْ هَذَا الْبَيْتَ تَشْرِيفًا وَتَعْظِيمًا وَتَكْرِيمًا وَمَهَابَةً، وَزِدْ مِنْ شَرَّفَهُ وَكَرَّمَهُ مِمَّنْ حَجَّهُ أَوْ اعْتَمَرَهُ تَشْرِيفًا وَتَكْرِيمًا وَتَعْظِيمًا وَبِرًّا',
      transliteration:
          "Allāhumma zid hādha l-bayta tashrīfan wa ta'żiman wa takrīman wa mahābatan, wa zid man sharra-fahū wa karramahū mimman Hajjahū wa'tamarahū tashrīfan wa ta'żiman wa takrīman wa birran.",
      translationEnglish:
          'O Allah! Increase this House in honour and reverence and nobility and awe, and increase those who honour and revere it as pilgrims for Hajj and Umrah in nobility and goodness and status and righteousness.',
      translationBengali:
          'হে আল্লাহ! এই ঘরের সম্মান, মর্যাদা, সম্ভ্রম ও ভয় বাড়িয়ে দিন। এবং যারা হজ্জ ও উমরাহকারী হিসেবে এর সম্মান করে ও মর্যাদা দেয় তাদের সম্মান, মর্যাদা ও পূণ্য বাড়িয়ে দিন।',
      reference: "Ibn Abd al-Barr, Ibn Taymiyyah",
      category: UmrahDuaCategory.tawaf,
    ),

    // 05 - Entering Masjid al-Haram
    UmrahDua(
      id: 5,
      titleEnglish: 'Entering Masjid al-Haram',
      titleArabic: 'دخول المسجد الحرام',
      arabicText:
          'بِسْمِ اللَّهِ، اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ. اللَّهُمَّ اغْفِرْ لِي وَافْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      transliteration:
          'Bismi-llāh, Allāhumma salli alā Muhammad. Allāhumma-ghfir lī wa-ftah lī abwāba rahmatik.',
      translationEnglish:
          'In the name of Allah, send prayers upon Muhammad. O Allah, forgive me and open for me the doors of Your Mercy.',
      translationBengali:
          'আল্লাহর নামে, হে আল্লাহ মুহাম্মদের উপর রহমত বর্ষণ করুন। হে আল্লাহ, আমাকে ক্ষমা করুন এবং আমার জন্য আপনার রহমতের দরজাগুলো খুলে দিন।',
      reference: 'Muslim, Ibn Majah',
      category: UmrahDuaCategory.tawaf,
    ),

    // 06 - Starting Tawaf at Black Stone
    UmrahDua(
      id: 6,
      titleEnglish: 'At the Black Stone',
      titleArabic: 'عند الحجر الأسود',
      arabicText: 'بِسْمِ اللَّهِ، اللَّهُ أَكْبَرُ',
      transliteration: 'Bismillāhi, Allāhu Akbar.',
      translationEnglish: 'In the name of Allah, Allah is the Greatest.',
      translationBengali: 'আল্লাহর নামে, আল্লাহ সবচেয়ে মহান।',
      reference: 'Bukhari',
      category: UmrahDuaCategory.tawaf,
    ),

    // 07 - Between Rukn Yamani and Black Stone
    UmrahDua(
      id: 7,
      titleEnglish: 'Between Rukn Yamani & Black Stone',
      titleArabic: 'بين الركن اليماني والحجر الأسود',
      arabicText:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      transliteration:
          "Rabbanā ātinā fi d-dunyā hasanatan wa fi l-ākhirati hasanatan wa qinā 'adhāba n-nār.",
      translationEnglish:
          'Our Lord, give us good in this world and good in the Hereafter, and save us from the punishment of the Fire.',
      translationBengali:
          'হে আমাদের রব, আমাদের দুনিয়াতে কল্যাণ দিন এবং আখিরাতেও কল্যাণ দিন এবং আমাদের জাহান্নামের আযাব থেকে রক্ষা করুন।',
      reference: 'Quran 2:201',
      category: UmrahDuaCategory.tawaf,
    ),

    // 08 - After Completing Tawaf
    UmrahDua(
      id: 8,
      titleEnglish: 'After Completing Tawaf',
      titleArabic: 'بعد إتمام الطواف',
      arabicText:
          'وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّى',
      transliteration: "Wattakhidhū min maqāmi Ibrāhīma musallā.",
      translationEnglish:
          'And take the Station of Ibrahim as a place of prayer.',
      translationBengali:
          'এবং ইবরাহিমের দাঁড়ানোর স্থানকে সালাতের স্থান হিসেবে গ্রহণ করো।',
      reference: 'Quran 2:125',
      category: UmrahDuaCategory.tawaf,
    ),

    // 09 - At Safa
    UmrahDua(
      id: 9,
      titleEnglish: "Starting Sa'i at Safa",
      titleArabic: 'بداية السعي عند الصفا',
      arabicText:
          'إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ، أَبْدَأُ بِمَا بَدَأَ اللَّهُ بِهِ',
      transliteration:
          "Inna ṣ-ṣafā wa l-marwata min sha'ā'iri llāh. Abda'u bimā bada'a llāhu bih.",
      translationEnglish:
          "Indeed, Safa and Marwah are among the symbols of Allah. I begin with what Allah began with.",
      translationBengali:
          'নিশ্চয়ই সাফা ও মারওয়া আল্লাহর নিদর্শনসমূহের অন্তর্ভুক্ত। আমি তা দিয়ে শুরু করছি যা দিয়ে আল্লাহ শুরু করেছেন।',
      reference: 'Quran 2:158, Muslim',
      category: UmrahDuaCategory.sai,
    ),

    // 10 - Dua at Safa and Marwah
    UmrahDua(
      id: 10,
      titleEnglish: "Dua at Safa & Marwah",
      titleArabic: 'الدعاء عند الصفا والمروة',
      arabicText:
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ، أَنْجَزَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَهَزَمَ الْأَحْزَابَ وَحْدَهُ',
      transliteration:
          "Lā ilāha illa llāhu waḥdahu lā sharīka lah, lahu l-mulku wa lahu l-ḥamdu wa huwa 'alā kulli shay'in qadīr. Lā ilāha illa llāhu waḥdah, anjaza wa'dah, wa naṣara 'abdah, wa hazama l-aḥzāba waḥdah.",
      translationEnglish:
          'There is no god but Allah alone, without partner. His is the dominion, His is the praise, and He is capable of all things. There is no god but Allah alone. He fulfilled His promise, granted victory to His servant, and defeated the confederates alone.',
      translationBengali:
          'আল্লাহ ছাড়া কোনো ইলাহ নেই, তিনি একক, তাঁর কোনো শরীক নেই। রাজত্ব তাঁরই, প্রশংসা তাঁরই এবং তিনি সব কিছুর উপর ক্ষমতাবান। আল্লাহ ছাড়া কোনো ইলাহ নেই, তিনি একক। তিনি তাঁর প্রতিশ্রুতি পূর্ণ করেছেন, তাঁর বান্দাকে সাহায্য করেছেন এবং একাই সম্মিলিত বাহিনীকে পরাজিত করেছেন।',
      reference: 'Muslim',
      category: UmrahDuaCategory.sai,
    ),

    // 11 - Drinking Zamzam
    UmrahDua(
      id: 11,
      titleEnglish: 'Drinking Zamzam',
      titleArabic: 'شرب ماء زمزم',
      arabicText:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا وَاسِعًا، وَشِفَاءً مِنْ كُلِّ دَاءٍ',
      transliteration:
          "Allāhumma innī as'aluka 'ilman nāfi'an, wa rizqan wāsi'an, wa shifā'an min kulli dā'.",
      translationEnglish:
          'O Allah, I ask You for beneficial knowledge, abundant provision, and healing from every disease.',
      translationBengali:
          'হে আল্লাহ, আমি আপনার কাছে উপকারী জ্ঞান, প্রশস্ত রিজিক এবং সকল রোগ থেকে আরোগ্য চাই।',
      reference: 'Hakim, Daraqutni',
      category: UmrahDuaCategory.zamzam,
    ),

    // 12 - Exiting Masjid al-Haram
    UmrahDua(
      id: 12,
      titleEnglish: 'Exiting Masjid al-Haram',
      titleArabic: 'الخروج من المسجد الحرام',
      arabicText:
          'بِسْمِ اللَّهِ وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      transliteration:
          "Bismillāhi wa ṣ-ṣalātu wa s-salāmu 'alā rasūli llāh. Allāhumma innī as'aluka min faḍlik.",
      translationEnglish:
          'In the name of Allah, and peace and blessings be upon the Messenger of Allah. O Allah, I ask You of Your bounty.',
      translationBengali:
          'আল্লাহর নামে এবং আল্লাহর রাসূলের উপর সালাত ও সালাম। হে আল্লাহ, আমি আপনার অনুগ্রহ থেকে প্রার্থনা করছি।',
      reference: 'Muslim, Ibn Majah',
      category: UmrahDuaCategory.general,
    ),

    // 13 - General Dua during Umrah
    UmrahDua(
      id: 13,
      titleEnglish: 'General Supplication',
      titleArabic: 'دعاء عام',
      arabicText:
          'اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي وَعَافِنِي وَارْزُقْنِي',
      transliteration:
          "Allāhumma-ghfir lī wa-rḥamnī wa-hdinī wa 'āfinī wa-rzuqnī.",
      translationEnglish:
          'O Allah, forgive me, have mercy on me, guide me, grant me well-being, and provide for me.',
      translationBengali:
          'হে আল্লাহ, আমাকে ক্ষমা করুন, আমার প্রতি রহম করুন, আমাকে হেদায়েত দিন, আমাকে সুস্থতা দিন এবং আমাকে রিজিক দিন।',
      reference: 'Muslim',
      category: UmrahDuaCategory.general,
    ),

    // 14 - Dua for Acceptance
    UmrahDua(
      id: 14,
      titleEnglish: 'Dua for Acceptance',
      titleArabic: 'دعاء القبول',
      arabicText:
          'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ وَتُبْ عَلَيْنَا إِنَّكَ أَنتَ التَّوَّابُ الرَّحِيمُ',
      transliteration:
          "Rabbanā taqabbal minnā innaka anta s-samī'u l-'alīm. Wa tub 'alaynā innaka anta t-tawwābu r-raḥīm.",
      translationEnglish:
          'Our Lord, accept from us. Indeed, You are the All-Hearing, the All-Knowing. And turn to us in forgiveness. Indeed, You are the Accepting of repentance, the Merciful.',
      translationBengali:
          'হে আমাদের রব, আমাদের থেকে কবুল করুন। নিশ্চয়ই আপনি সর্বশ্রোতা, সর্বজ্ঞ। এবং আমাদের তওবা কবুল করুন। নিশ্চয়ই আপনি তওবা কবুলকারী, পরম দয়ালু।',
      reference: 'Quran 2:127-128',
      category: UmrahDuaCategory.general,
    ),

    // 15 - Returning Home Safely
    UmrahDua(
      id: 15,
      titleEnglish: 'Returning Home',
      titleArabic: 'العودة إلى الوطن',
      arabicText:
          'آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
      transliteration: "Āyibūna tā'ibūna 'ābidūna li-rabbinā ḥāmidūn.",
      translationEnglish:
          'We return, repenting, worshipping, and praising our Lord.',
      translationBengali:
          'আমরা ফিরে আসছি তওবাকারী, ইবাদতকারী এবং আমাদের রবের প্রশংসাকারী হয়ে।',
      reference: 'Bukhari, Muslim',
      category: UmrahDuaCategory.journey,
    ),
  ];

  /// Get duas by category
  static List<UmrahDua> getByCategory(String category) {
    return duas.where((dua) => dua.category == category).toList();
  }

  /// Get all categories
  static List<String> get categories {
    return duas.map((dua) => dua.category).toSet().toList();
  }
}

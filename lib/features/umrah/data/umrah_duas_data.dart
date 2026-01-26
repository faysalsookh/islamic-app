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

    // 06 - First Sight of the Kaaba
    UmrahDua(
      id: 6,
      titleEnglish: 'First Sight of the Kaaba',
      titleArabic: 'أول رؤية للكعبة',
      arabicText:
          'اَللَّهُمَّ أَنْتَ السَّلاَمُ وَمِنْكَ السَّلاَمُ، حَيِّنَا رَبَّنَا بِالسَّلاَمِ',
      transliteration:
          'Allāhumma Anta-s-Salāmu wa minka-s-salām, hayyinā Rabbanā bi-s-salām.',
      translationEnglish:
          'O Allah, You are Peace and from You is peace. Make us live, Lord, in peace.',
      translationBengali:
          'হে আল্লাহ, আপনিই শান্তি এবং আপনার কাছ থেকেই শান্তি আসে। হে আমাদের রব, আমাদের শান্তিতে বাঁচান।',
      category: UmrahDuaCategory.tawaf,
    ),

    // 07 - Intention for Tawaf
    UmrahDua(
      id: 7,
      titleEnglish: 'Intention for Tawaf',
      titleArabic: 'نية الطواف',
      arabicText:
          'اللَّهُمَّ إِنِّي أُرِيدُ طَوَافَ بَيْتِكَ الْحَرَامِ فَيَسِّرْهُ لِي وَتَقَبَّلْهُ مِنِّي',
      transliteration:
          'Allāhumma innī urīdu l-tawwafa baytika l-ḥarāmi fa yassirhu lī wa taqabbalhu minnī.',
      translationEnglish:
          'O Allah, I intend to perform Tawaf of your Sacred House, so make it easy for me and accept it from me.',
      translationBengali:
          'হে আল্লাহ, আমি আপনার পবিত্র ঘরের তাওয়াফ করতে চাই, তাই এটি আমার জন্য সহজ করুন এবং আমার কাছ থেকে কবুল করুন।',
      category: UmrahDuaCategory.tawaf,
    ),

    // 08 - At Hajar Al-Aswad (The Black Stone) Istilam
    UmrahDua(
      id: 8,
      titleEnglish: 'At Hajar Al-Aswad (The Black Stone) Istilam',
      titleArabic: 'عند الحجر الأسود - الاستلام',
      arabicText: 'بِسْمِ اللَّهِ وَاللَّهُ أَكْبَرُ',
      transliteration: "Bismillâh, wallâhu 'Akbar.",
      translationEnglish: 'In the Name of Allah, Allah is most Great.',
      translationBengali: 'আল্লাহর নামে, আল্লাহ সবচেয়ে মহান।',
      category: UmrahDuaCategory.tawaf,
    ),

    // 09 - Between the Rukn Al-Yamani & Hajar Al-Aswad
    UmrahDua(
      id: 9,
      titleEnglish: 'Between the Rukn Al-Yamani & Hajar Al-Aswad',
      titleArabic: 'بين الركن اليماني والحجر الأسود',
      arabicText:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَّفِي الآخِرَةِ حَسَنَةً وَّقِنَا عَذَابَ النَّارِ',
      transliteration:
          "Rabbanā ātināfid-dunyā hasanatan wa fi l-ākhirati hasanatan wa qinā 'adhāba n-nār.",
      translationEnglish:
          'O our Lord, give us good in this world and good in the next world and guard us against the torment of the Fire.',
      translationBengali:
          'হে আমাদের রব, আমাদের দুনিয়াতে কল্যাণ দিন এবং আখিরাতেও কল্যাণ দিন এবং আমাদের জাহান্নামের আযাব থেকে রক্ষা করুন।',
      reference: 'Surah Al-Baqarah, 2:201',
      category: UmrahDuaCategory.tawaf,
    ),

    // 10 - Zamzam
    UmrahDua(
      id: 10,
      titleEnglish: 'Zamzam',
      titleArabic: 'زمزم',
      arabicText:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا وَاسِعًا وَعَمَلًا مُتَقَبَّلًا وَشِفَاءً مِنْ كُلِّ دَاءٍ',
      transliteration:
          "Allahumma innī as'aluka 'ilman nāfi'an, wa rizqan wāsi'an, wa 'amalan mutaqabbalan, wa shifā'an min kulli dā'.",
      translationEnglish:
          'O Allah, I ask You for knowledge that is beneficial, provision that is abundant and a cure for every illness.',
      translationBengali:
          'হে আল্লাহ, আমি আপনার কাছে উপকারী জ্ঞান, প্রশস্ত রিজিক, কবুলযোগ্য আমল এবং সকল রোগ থেকে আরোগ্য চাই।',
      category: UmrahDuaCategory.zamzam,
    ),

    // 11 - Make Dua at Safa
    UmrahDua(
      id: 11,
      titleEnglish: 'Make Dua at Safa',
      titleArabic: 'الدعاء عند الصفا',
      arabicText:
          'اَللَّهُ أَكْبَرُ، اَللَّهُ أَكْبَرُ، اَللَّهُ أَكْبَرُ، وَلِلَّهِ الْحَمْدُ',
      transliteration: 'Allāhu akbar, Allāhu akbar, Allāhu akbar, wa lillāhi l-hamd.',
      translationEnglish:
          'Allah is the greatest; Allah is the greatest; Allah is the greatest, and to Allah belongs all praise.',
      translationBengali:
          'আল্লাহ সবচেয়ে মহান; আল্লাহ সবচেয়ে মহান; আল্লাহ সবচেয়ে মহান, এবং সমস্ত প্রশংসা আল্লাহর জন্য।',
      category: UmrahDuaCategory.sai,
    ),

    // 12 - At Maqaam-e-Ibrahim
    UmrahDua(
      id: 12,
      titleEnglish: 'At Maqaam-e-Ibrahim',
      titleArabic: 'عند مقام إبراهيم',
      arabicText:
          'وَاتَّخِذُوا مِنْ مَقَامِ إِبْرَاهِيمَ مُصَلَّى',
      transliteration: 'Wattakhidhu min maqāmi Ibrāhīma musalla.',
      translationEnglish:
          'And take, [O Believers], from the standing place of Abraham a place of prayer.',
      translationBengali:
          'এবং [হে মুমিনগণ], ইবরাহিমের দাঁড়ানোর স্থানকে সালাতের স্থান হিসেবে গ্রহণ করো।',
      category: UmrahDuaCategory.tawaf,
    ),

    // 13 - Sa'i between Safa and Marwah
    UmrahDua(
      id: 13,
      titleEnglish: "Sa'i between Safa and Marwah",
      titleArabic: 'السعي بين الصفا والمروة',
      arabicText:
          'إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ ۖ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَن يَطَّوَّفَ بِهِمَا ۚ وَمَن تَطَوَّعَ خَيْرًا فَإِنَّ اللَّهَ شَاكِرٌ عَلِيمٌ',
      transliteration:
          "Inna ṣ-ṣafā wa l-marwata min sha'ā'iri llāh. Faman ḥajja l-bayta awi 'tamara falā junāḥa 'alayhi an yaṭṭawwafa bihimā. Wa man taṭawwa'a khayran fa inna llāha shākirun 'alīm.",
      translationEnglish:
          "Indeed, Safa and Marwah are among the symbols of Allah. So whoever makes Hajj to the House or performs Umrah – there is no blame upon him for walking between them. And whoever volunteers good – then indeed, Allah is appreciative and Knowing.",
      translationBengali:
          'নিশ্চয়ই সাফা ও মারওয়া আল্লাহর নিদর্শনসমূহের অন্তর্ভুক্ত। সুতরাং যে ব্যক্তি বায়তুল্লাহর হজ্জ বা উমরাহ করে, তার জন্য এ দুটির মধ্যে তাওয়াফ করায় কোনো দোষ নেই। আর যে স্বেচ্ছায় কল্যাণ করে, নিশ্চয়ই আল্লাহ গুণগ্রাহী, সর্বজ্ঞ।',
      reference: 'Surah Al-Baqarah, 2:158',
      category: UmrahDuaCategory.sai,
    ),

    // 14 - Leave the Haram
    UmrahDua(
      id: 14,
      titleEnglish: 'Leave the Haram',
      titleArabic: 'الخروج من الحرم',
      arabicText:
          'بِسْمِ اللَّهِ وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      transliteration:
          "Bismi llāhi, wa s-salātu wa s-salāmu 'ala rasūli llāh. Allāhumma innī as'aluka min fadlik.",
      translationEnglish:
          'In the name of Allah, and peace and blessings be upon the Messenger of Allah. O Allah, I ask of you from Your bounty.',
      translationBengali:
          'আল্লাহর নামে, এবং আল্লাহর রাসূলের উপর শান্তি ও রহমত বর্ষিত হোক। হে আল্লাহ, আমি আপনার অনুগ্রহ থেকে প্রার্থনা করছি।',
      category: UmrahDuaCategory.general,
    ),

    // 15 - Du'a after Every Prayer
    UmrahDua(
      id: 15,
      titleEnglish: "Du'a after Every Prayer",
      titleArabic: 'دعاء بعد كل صلاة',
      arabicText:
          'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ',
      transliteration:
          "Allāhumma a'innī 'alā dhikrika wa shukrika wa husni 'ibādatika.",
      translationEnglish:
          'O Allah! Help me to remember You and thank You and help me to the best manner of worshipping You.',
      translationBengali:
          'হে আল্লাহ! আমাকে আপনার যিকির করতে, আপনার শুকরিয়া আদায় করতে এবং সুন্দরভাবে আপনার ইবাদত করতে সাহায্য করুন।',
      reference: 'Al-Adab Al-Mufrad',
      category: UmrahDuaCategory.general,
    ),

    // 16 - Greeting other Pilgrims
    UmrahDua(
      id: 16,
      titleEnglish: 'Greeting other Pilgrims',
      titleArabic: 'تحية الحجاج الآخرين',
      arabicText:
          'قَبِلَ اللَّهُ حَجَّكَ وَكَفَّرَ ذَنْبَكَ وَأَخْلَفَ نَفَقَتَكَ',
      transliteration:
          'Qabila l-lāhu hajjaka wa kaffara dhambaka wa akhlafa nafaqata.',
      translationEnglish:
          'May Allah accept your Hajj, and erase your sins, and replenish your provisions.',
      translationBengali:
          'আল্লাহ আপনার হজ্জ কবুল করুন, আপনার গুনাহ মাফ করুন এবং আপনার ব্যয় পূরণ করে দিন।',
      reference: 'Al-Tabarani',
      category: UmrahDuaCategory.general,
    ),

    // 17 - Entering Madinah
    UmrahDua(
      id: 17,
      titleEnglish: 'Entering Madinah',
      titleArabic: 'دخول المدينة المنورة',
      arabicText:
          'اَللّٰهُمَّ هٰذَا حَرَمُ نَبِيِّكَ فَاجْعَلْهُ وِقَايَةً لِيْ مِنَ النَّارِ وَآمِنًّا مِنْ الْعَذَابِ وَسُوْءِ الْحِسَابِ',
      transliteration:
          "Allāhumma hādhā haramu nabiyyika fa j-'alhu wiqāyatan lī mina n-nāri wa āminnā mina l-'adhābi wa sū'i l-hisābi.",
      translationEnglish:
          'O Allah! This is the Sacred Precinct of Your Prophet, so make it a protection for me from the Fire and a security from punishment and a bad reckoning.',
      translationBengali:
          'হে আল্লাহ! এটি আপনার নবীর পবিত্র হারাম, তাই এটিকে আমার জন্য জাহান্নামের আগুন থেকে রক্ষাকবচ বানিয়ে দিন এবং শাস্তি ও খারাপ হিসাব থেকে নিরাপত্তা দিন।',
      reference: 'Al-Ikhtiyar',
      category: UmrahDuaCategory.madinah,
    ),

    // 18 - Shaving Head/Trimming
    UmrahDua(
      id: 18,
      titleEnglish: 'Shaving Head/Trimming',
      titleArabic: 'حلق الرأس / التقصير',
      arabicText:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      transliteration:
          "Allahumma innee 'as'aluka min fadhlika.",
      translationEnglish:
          'O Allah, send prayers and peace upon Muhammad. O Allah, verily I ask You from Your Favor.',
      translationBengali:
          'হে আল্লাহ, মুহাম্মদের উপর দরূদ ও সালাম বর্ষণ করুন। হে আল্লাহ, আমি আপনার অনুগ্রহ থেকে প্রার্থনা করছি।',
      category: UmrahDuaCategory.completion,
    ),

    // 19 - Third Kalima
    UmrahDua(
      id: 19,
      titleEnglish: 'Third Kalima',
      titleArabic: 'الكلمة الثالثة - التمجيد',
      arabicText:
          'سُبْحَان اللّٰهِ وَالْحَمْدُلِلّٰهِ الْعَظِيْم وَلَا إِلٰهَ إِلَّااللّٰهُ وَاللّٰهُ أَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ الْعَلِيِّ الْعَظِيْمِ',
      transliteration:
          'Subhanallahe Wal Hamdulillahe Wa Laa ilaha illal Laho Wallahooakbar. Wala Haola Wala Quwwata illa billahil AliYil Azeem.',
      translationEnglish:
          'Glory (is for) Allah. And all praises for Allah. And (there is) none worthy of worship except Allah. And Allah is the Greatest. And (there is) no power and no strength except from Allah, the Most High, the Most Great.',
      translationBengali:
          'আল্লাহর মহিমা। এবং সমস্ত প্রশংসা আল্লাহর জন্য। এবং আল্লাহ ছাড়া কোনো উপাস্য নেই। এবং আল্লাহ সবচেয়ে মহান। এবং কোনো শক্তি ও ক্ষমতা নেই আল্লাহ ছাড়া, যিনি সর্বোচ্চ, সর্বমহান।',
      category: UmrahDuaCategory.general,
    ),

    // 20 - Returning Home
    UmrahDua(
      id: 20,
      titleEnglish: 'Returning Home',
      titleArabic: 'العودة إلى الوطن',
      arabicText:
          'آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
      transliteration:
          "Āyibūna tā'ibūna 'ābidūna li rabbinā hāmidūna.",
      translationEnglish:
          '(We are those) who return, who repent, who worship our Lord, who praise.',
      translationBengali:
          '(আমরা তারা) যারা ফিরে এসেছি, যারা তওবা করছি, যারা আমাদের রবের ইবাদত করছি, যারা প্রশংসা করছি।',
      reference: 'Muslim',
      category: UmrahDuaCategory.completion,
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

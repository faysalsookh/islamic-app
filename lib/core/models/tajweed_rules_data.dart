import 'package:flutter/material.dart';
import 'tajweed.dart';

/// Represents a detailed Tajweed rule with Bengali explanations
class TajweedRuleDetail {
  final String nameArabic;
  final String nameBengali;
  final String nameEnglish;
  final Color color;
  final String descriptionBengali;
  final String descriptionEnglish;
  final List<String> arabicLetters;
  final String exampleArabic;
  final String exampleTranslation;
  final TajweedRule rule;

  const TajweedRuleDetail({
    required this.nameArabic,
    required this.nameBengali,
    required this.nameEnglish,
    required this.color,
    required this.descriptionBengali,
    required this.descriptionEnglish,
    required this.arabicLetters,
    required this.exampleArabic,
    required this.exampleTranslation,
    required this.rule,
  });
}

/// Data class containing all Tajweed rules with Bengali explanations
/// Colors match the standard Bengali Quran Tajweed color coding as shown in the guide image
class TajweedRulesData {
  static const List<TajweedRuleDetail> allRules = [
    // 1. Ghunnah (Nasalization) - RED - গুন্নাহ
    TajweedRuleDetail(
      nameArabic: 'غُنَّة',
      nameBengali: 'গুন্নাহ',
      nameEnglish: 'Ghunnah (Nasalization)',
      color: Color(0xFFE53935), // Red
      descriptionBengali: 'গুন্নাহ নাকের ভিতর হতে হালকা আওয়াজে উচ্চারণ করতে হয়। নূন ও মীম মুশাদ্দাদ (نّ  مّ) এর ক্ষেত্রে ২ মাত্রা পর্যন্ত টানতে হয়।',
      descriptionEnglish: 'Ghunnah is a nasal sound produced from the nose, typically lasting 2 counts. Applied to noon and meem mushaddad.',
      arabicLetters: ['نّ', 'مّ'],
      exampleArabic: 'إِنَّ - ثُمَّ - مِنَّا',
      exampleTranslation: 'Examples showing Ghunnah',
      rule: TajweedRule.ghunnah,
    ),

    // 2. Ikhfa (Concealment) - BLUE - ইখফা
    TajweedRuleDetail(
      nameArabic: 'إخفاء',
      nameBengali: 'ইখফা',
      nameEnglish: 'Ikhfa (Concealment)',
      color: Color(0xFF2196F3), // Blue
      descriptionBengali: 'যদি নূন সাকিন (نْ) বা তানবীন (ً ٍ ٌ) এর পর এই পনেরটি হরফ আসে তাহলে নূন সাকিন বা তানবীনকে গোপন করে (গুন্নাহ সহকারে) পড়তে হবে।',
      descriptionEnglish: 'If noon sakin or tanween is followed by one of these 15 letters, it should be concealed (with ghunnah).',
      arabicLetters: ['ص', 'ذ', 'ث', 'ك', 'ج', 'ش', 'ق', 'س', 'د', 'ط', 'ز', 'ف', 'ت', 'ض', 'ظ'],
      exampleArabic: 'مَنْ ذَا - أَنْ صَدُّوكُمْ - مِنْ قَبْلِ',
      exampleTranslation: 'Examples showing Ikhfa',
      rule: TajweedRule.ikhfa,
    ),

    // 3. Qalqalah (Echoing) - BROWN/MAROON - কলকলা
    TajweedRuleDetail(
      nameArabic: 'قلقلة',
      nameBengali: 'কলকলা',
      nameEnglish: 'Qalqalah (Echoing)',
      color: Color(0xFF8B4513), // Brown/Maroon
      descriptionBengali: 'যদি ق ط ب ج د এর যে কোন হরফের উপর সাকিন হয় বা বাক্য শেষ করার কারণে থামতে হয় তাহলে এটি প্রতিধ্বনি আকারে বা ধাক্কা দিয়ে পড়তে হয়।',
      descriptionEnglish: 'A slight echoing or bouncing sound on the letters ق ط ب ج د when they have sukoon.',
      arabicLetters: ['ق', 'ط', 'ب', 'ج', 'د'],
      exampleArabic: 'يَخْلُقْ - أَحَدْ - الْفَلَقْ',
      exampleTranslation: 'Examples showing Qalqalah',
      rule: TajweedRule.qalqalah,
    ),

    // 4. Idgham (Assimilation) - GREEN - ইদগাম
    TajweedRuleDetail(
      nameArabic: 'إدغام',
      nameBengali: 'ইদগাম',
      nameEnglish: 'Idgham (Assimilation)',
      color: Color(0xFF4CAF50), // Green
      descriptionBengali: 'যদি নূন সাকিন বা তানবীন এর পর ي ن م و ل ر হতে যে কোন একটি হরফ আসে তাহলে মিলিয়ে পড়তে হবে। ي ن م و এর সাথে গুন্নাহ সহ এবং ل ر এর সাথে গুন্নাহ ছাড়া।',
      descriptionEnglish: 'If noon sakin or tanween is followed by one of these letters, merge them. With ي ن م و (with ghunnah), with ل ر (without ghunnah).',
      arabicLetters: ['ي', 'ن', 'م', 'و', 'ل', 'ر'],
      exampleArabic: 'مَنْ يَعْمَلْ - مِنْ رَبِّهِمْ',
      exampleTranslation: 'Examples showing Idgham',
      rule: TajweedRule.idgham,
    ),

    // 5. Iqlab (Conversion) - PURPLE - ইকলাব
    TajweedRuleDetail(
      nameArabic: 'إقلاب',
      nameBengali: 'ইকলাব',
      nameEnglish: 'Iqlab (Conversion)',
      color: Color(0xFF9C27B0), // Purple
      descriptionBengali: 'যদি নূন সাকিন বা তানবীন এর পর ب হরফ আসে তাহলে নূন সাকিন বা তানবীনকে মীমে (م) বদল করে গুন্নাহ সহকারে পড়তে হবে।',
      descriptionEnglish: 'When noon sakin or tanween is followed by Ba (ب), convert it to meem (م) with ghunnah.',
      arabicLetters: ['ب'],
      exampleArabic: 'مِنْ بَعْدِ - أَنْبِئْهُمْ - سَمِيعٌۢ بَصِيرٌ',
      exampleTranslation: 'Examples showing Iqlab',
      rule: TajweedRule.iqlab,
    ),

    // 6. Izhar (Clear Pronunciation) - DARK BLUE - ইজহার
    TajweedRuleDetail(
      nameArabic: 'إظهار',
      nameBengali: 'ইজহার',
      nameEnglish: 'Izhar (Clear)',
      color: Color(0xFF1A237E), // Dark Blue
      descriptionBengali: 'যদি নূন সাকিন বা তানবীন এর পর ء ه ع ح غ خ (হলক্বী হরফ) আসে তাহলে নূন সাকিন বা তানবীনকে স্পষ্টভাবে পড়তে হবে।',
      descriptionEnglish: 'When noon sakin or tanween is followed by throat letters (ء ه ع ح غ خ), pronounce clearly without ghunnah.',
      arabicLetters: ['ء', 'ه', 'ع', 'ح', 'غ', 'خ'],
      exampleArabic: 'مَنْ آمَنَ - مِنْ عِلْمٍ - أَنْعَمْتَ',
      exampleTranslation: 'Examples showing Izhar',
      rule: TajweedRule.izhar,
    ),

    // 7. Safir (Whistling) - ORANGE - ছফিরহ
    TajweedRuleDetail(
      nameArabic: 'صفير',
      nameBengali: 'ছফিরহ',
      nameEnglish: 'Safir (Whistling)',
      color: Color(0xFFFF9800), // Orange
      descriptionBengali: 'ص ز س এই তিনটি হরফ উচ্চারণ করার সময় শিস দেওয়ার মতো আওয়াজ হয়। এদেরকে হরফে ছফির বলে।',
      descriptionEnglish: 'A whistling sound produced when pronouncing the letters ص ز س. These are called whistling letters.',
      arabicLetters: ['ص', 'ز', 'س'],
      exampleArabic: 'الصِّرَاطَ - زَكَاةَ - سَمِيعٌ',
      exampleTranslation: 'Examples showing Safir',
      rule: TajweedRule.safir,
    ),

    // 8. Madd (Elongation) - PINK - মাদ
    TajweedRuleDetail(
      nameArabic: 'مد',
      nameBengali: 'মাদ',
      nameEnglish: 'Madd (Elongation)',
      color: Color(0xFFE91E63), // Pink
      descriptionBengali: 'মাদ অর্থ টানা। মাদের হরফ তিনটি: ا و ي। এই হরফগুলো আসলে স্বরধ্বনিকে ২ থেকে ৬ মাত্রা পর্যন্ত টানতে হয়।',
      descriptionEnglish: 'Madd means elongation. The letters of Madd are ا و ي. Vowel sounds are prolonged from 2 to 6 counts.',
      arabicLetters: ['ا', 'و', 'ي'],
      exampleArabic: 'قَالَ - يَقُولُ - فِيهَا',
      exampleTranslation: 'Examples showing Madd',
      rule: TajweedRule.madd,
    ),

    // 9. Ikhfaye Meem Sakin (Concealment of Meem)
    TajweedRuleDetail(
      nameArabic: 'إخفاء ميم ساكن',
      nameBengali: 'ইখফায়ে মীম সাকিন',
      nameEnglish: 'Ikhfaye Meem Sakin',
      color: Color(0xFFE53935), // Red (same as Ghunnah)
      descriptionBengali: 'যখন মীম সাকিন (مْ) এর পরে বা (ب) আসে তখন মীম সাকিনকে গোপন করে গুন্নাহ সহকারে পড়তে হয়।',
      descriptionEnglish: 'When meem sakin is followed by the letter Ba (ب), it should be concealed with ghunnah.',
      arabicLetters: ['ب'],
      exampleArabic: 'تَرْمِيهِمْ بِحِجَارَةٍ - هُمْ بِرَبِّهِمْ',
      exampleTranslation: 'Examples showing Ikhfaye Meem Sakin',
      rule: TajweedRule.ghunnah,
    ),

    // 10. Idgham Meem Sakin (Merging of Meem)
    TajweedRuleDetail(
      nameArabic: 'إدغام ميم ساكن',
      nameBengali: 'ইদগাম মীম সাকিন',
      nameEnglish: 'Idgham Meem Sakin',
      color: Color(0xFFE53935), // Red (same as Ghunnah)
      descriptionBengali: 'মীম সাকিনের (مْ) পর আরেকটি مّ আসলে দুটি মীমকে একসাথে মিলিয়ে গুন্নাহ সহকারে পড়তে হবে।',
      descriptionEnglish: 'When meem sakin is followed by another meem, merge them with ghunnah.',
      arabicLetters: ['م'],
      exampleArabic: 'فِي قُلُوبِهِم مَّرَضٌ - لَهُم مَّا يَشَاءُونَ',
      exampleTranslation: 'Examples showing Idgham Meem Sakin',
      rule: TajweedRule.ghunnah,
    ),
  ];

  /// Get rule by TajweedRule enum
  static TajweedRuleDetail? getRuleDetail(TajweedRule rule) {
    try {
      return allRules.firstWhere((r) => r.rule == rule);
    } catch (e) {
      return null;
    }
  }

  /// Get all rules as a list
  static List<TajweedRuleDetail> getAllRules() => allRules;
}

/// Represents an Arabic letter with its pronunciation details (Makhraj)
class ArabicLetter {
  final String letter;
  final String nameBengali;
  final String makhrajBengali;
  final String pronunciationBengali;

  const ArabicLetter({
    required this.letter,
    required this.nameBengali,
    required this.makhrajBengali,
    required this.pronunciationBengali,
  });
}

/// Data class containing all Arabic letters with Makhraj (articulation points)
class ArabicAlphabetData {
  static const List<ArabicLetter> allLetters = [
    ArabicLetter(
      letter: 'ا',
      nameBengali: 'আলিফ',
      makhrajBengali: 'মুখের ভিতর খালি জায়গা হতে বাতাসের সাথে উচ্চারিত হয়',
      pronunciationBengali: 'আ',
    ),
    ArabicLetter(
      letter: 'ب',
      nameBengali: 'বা',
      makhrajBengali: 'দুই ঠোঁটের মধ্যখান হতে',
      pronunciationBengali: 'ব',
    ),
    ArabicLetter(
      letter: 'ت',
      nameBengali: 'তা',
      makhrajBengali: 'জিহ্বার আগা সামনের উপরের দুই দাঁতের গোড়ার সঙ্গে লাগে',
      pronunciationBengali: 'ত',
    ),
    ArabicLetter(
      letter: 'ث',
      nameBengali: 'ছা',
      makhrajBengali: 'জিহ্বার আগা সামনের দাঁতের ফাঁকে',
      pronunciationBengali: 'থ',
    ),
    ArabicLetter(
      letter: 'ج',
      nameBengali: 'জীম',
      makhrajBengali: 'জিহ্বার মাঝখান তালুর উপর',
      pronunciationBengali: 'জ',
    ),
    ArabicLetter(
      letter: 'ح',
      nameBengali: 'হা',
      makhrajBengali: 'কণ্ঠনালীর মাঝখান হতে',
      pronunciationBengali: 'হ',
    ),
    ArabicLetter(
      letter: 'خ',
      nameBengali: 'খা',
      makhrajBengali: 'কণ্ঠনালীর উপরাংশ হতে',
      pronunciationBengali: 'খ',
    ),
    ArabicLetter(
      letter: 'د',
      nameBengali: 'দাল',
      makhrajBengali: 'জিহ্বার আগা সামনের উপরের দাঁতের গোড়া',
      pronunciationBengali: 'দ',
    ),
    ArabicLetter(
      letter: 'ذ',
      nameBengali: 'যাল',
      makhrajBengali: 'জিহ্বার আগা সামনের দাঁতের ফাঁক',
      pronunciationBengali: 'য',
    ),
    ArabicLetter(
      letter: 'ر',
      nameBengali: 'র',
      makhrajBengali: 'জিহ্বার আগা উপরের তালুর সঙ্গে',
      pronunciationBengali: 'র',
    ),
    ArabicLetter(
      letter: 'ز',
      nameBengali: 'যা',
      makhrajBengali: 'জিহ্বার আগা সামনের নিচের দাঁতের গোড়া',
      pronunciationBengali: 'য',
    ),
    ArabicLetter(
      letter: 'س',
      nameBengali: 'সীন',
      makhrajBengali: 'জিহ্বার আগা সামনের নিচের দাঁতের গোড়া',
      pronunciationBengali: 'স',
    ),
    ArabicLetter(
      letter: 'ش',
      nameBengali: 'শীন',
      makhrajBengali: 'জিহ্বার মাঝখান তালুর উপর',
      pronunciationBengali: 'শ',
    ),
    ArabicLetter(
      letter: 'ص',
      nameBengali: 'সাদ',
      makhrajBengali: 'জিহ্বার আগা সামনের নিচের দাঁতের গোড়া',
      pronunciationBengali: 'স',
    ),
    ArabicLetter(
      letter: 'ض',
      nameBengali: 'দাদ',
      makhrajBengali: 'জিহ্বার গোড়া কিলার উপর',
      pronunciationBengali: 'দ',
    ),
    ArabicLetter(
      letter: 'ط',
      nameBengali: 'ত্ব',
      makhrajBengali: 'জিহ্বার আগা উপরের দাঁতের গোড়া',
      pronunciationBengali: 'ত্ব',
    ),
    ArabicLetter(
      letter: 'ظ',
      nameBengali: 'জ্ব',
      makhrajBengali: 'জিহ্বার আগা দাঁতের ফাঁক',
      pronunciationBengali: 'জ্ব',
    ),
    ArabicLetter(
      letter: 'ع',
      nameBengali: 'আইন',
      makhrajBengali: 'কণ্ঠনালীর মধ্যখান',
      pronunciationBengali: 'অ',
    ),
    ArabicLetter(
      letter: 'غ',
      nameBengali: 'গাইন',
      makhrajBengali: 'কণ্ঠনালীর উপরাংশ',
      pronunciationBengali: 'গ',
    ),
    ArabicLetter(
      letter: 'ف',
      nameBengali: 'ফা',
      makhrajBengali: 'নিচের ঠোঁট ও উপরের দাঁত',
      pronunciationBengali: 'ফ',
    ),
    ArabicLetter(
      letter: 'ق',
      nameBengali: 'ক্বাফ',
      makhrajBengali: 'জিহ্বার গোড়া উপরের তালু',
      pronunciationBengali: 'ক্ব',
    ),
    ArabicLetter(
      letter: 'ك',
      nameBengali: 'কাফ',
      makhrajBengali: 'জিহ্বার গোড়া সামান্য সামনে',
      pronunciationBengali: 'ক',
    ),
    ArabicLetter(
      letter: 'ل',
      nameBengali: 'লাম',
      makhrajBengali: 'জিহ্বার আগা উপরের তালু',
      pronunciationBengali: 'ল',
    ),
    ArabicLetter(
      letter: 'م',
      nameBengali: 'মীম',
      makhrajBengali: 'দুই ঠোঁট মিলিয়ে',
      pronunciationBengali: 'ম',
    ),
    ArabicLetter(
      letter: 'ن',
      nameBengali: 'নুন',
      makhrajBengali: 'জিহ্বার আগা উপরের তালু',
      pronunciationBengali: 'ন',
    ),
    ArabicLetter(
      letter: 'و',
      nameBengali: 'ওয়াও',
      makhrajBengali: 'দুই ঠোঁট গোল',
      pronunciationBengali: 'ও',
    ),
    ArabicLetter(
      letter: 'ه',
      nameBengali: 'হা',
      makhrajBengali: 'কণ্ঠনালীর নিচ',
      pronunciationBengali: 'হ',
    ),
    ArabicLetter(
      letter: 'ي',
      nameBengali: 'ইয়া',
      makhrajBengali: 'জিহ্বার মাঝখান তালু',
      pronunciationBengali: 'ই',
    ),
  ];

  /// Get all letters as a list
  static List<ArabicLetter> getAllLetters() => allLetters;
}

/// Represents a Waqf (stopping/pausing) sign used in Quran recitation
class WaqfSign {
  final String symbol;
  final String nameArabic;
  final String nameBengali;
  final String nameEnglish;
  final String descriptionBengali;
  final String descriptionEnglish;
  final bool mustStop;
  final bool mustNotStop;
  final bool preferredStop;

  const WaqfSign({
    required this.symbol,
    required this.nameArabic,
    required this.nameBengali,
    required this.nameEnglish,
    required this.descriptionBengali,
    required this.descriptionEnglish,
    this.mustStop = false,
    this.mustNotStop = false,
    this.preferredStop = false,
  });
}

/// Data class containing all Waqf (stopping) signs with Bengali explanations
/// Based on the standard Bengali Quran Waqf notation
class WaqfSignsData {
  static const List<WaqfSign> allSigns = [
    // 01. Waqf Tam (ۚ or ○)
    WaqfSign(
      symbol: '○',
      nameArabic: 'وقف تام',
      nameBengali: 'ওয়াকফি তাম',
      nameEnglish: 'Waqf Tam (Complete Stop)',
      descriptionBengali: 'গোল চিহ্ন। এখানে দম ছাড়া যাবে। অর্থ সম্পূর্ণ হয়েছে।',
      descriptionEnglish: 'Circle sign. You should stop here. The meaning is complete.',
      mustStop: true,
    ),

    // 02. Waqf Lazim (مـ)
    WaqfSign(
      symbol: 'مـ',
      nameArabic: 'وقف لازم',
      nameBengali: 'ওয়াকফি লাজিম',
      nameEnglish: 'Waqf Lazim (Compulsory Stop)',
      descriptionBengali: '"মীম" ওয়াকফি লাজিম। এখানে দম না ছেড়ে কোনক্রমেই মিলিয়ে পড়া যাবে না। মিলিয়ে পড়লে বিপরীত অর্থ হয়ে যেতে পারে। কোন কোন ক্ষেত্রে কুফরীও আশংকা আছে।',
      descriptionEnglish: 'Meem sign. Must stop here. Continuing without stopping may change or corrupt the meaning.',
      mustStop: true,
    ),

    // 03. Waqf Ruku (ع)
    WaqfSign(
      symbol: 'ع',
      nameArabic: 'وقف ركوع',
      nameBengali: 'ওয়াকফি রুকু',
      nameEnglish: 'Waqf Ruku (Ruku Stop)',
      descriptionBengali: '"আঈন" ওয়াকফি রুকু। এখানে দম ফেলাতে হবে। অক্ষরটির উপরে, মধ্যে ও নীচে যেই নম্বর দেওয়া হয়, তন্মধ্যে উপরেরটি সূরার রুকু সংখ্যা এবং নীচের নম্বরটি পারার রুকু সংখ্যা, মধ্যের নম্বরটি দু রুকুর মধ্যবর্তী আইয়্যাতের সংখ্যা নির্দেশ করে।',
      descriptionEnglish: 'Ain sign marking the end of a Ruku (section). The numbers indicate Surah ruku count (top), Para ruku count (bottom), and ayat count between rukus (middle).',
      mustStop: true,
    ),

    // 04. Waqf Mutlaq (ط)
    WaqfSign(
      symbol: 'ط',
      nameArabic: 'وقف مطلق',
      nameBengali: 'ওয়াকফি মুতলাক',
      nameEnglish: 'Waqf Mutlaq (Absolute Stop)',
      descriptionBengali: '"তু" ওয়াকফি মুতলাক। এখানে দম ফেলানোই ভাল।',
      descriptionEnglish: 'Ta sign. It is better to stop here.',
      preferredStop: true,
    ),

    // 05. Waqf Jaiz (ج)
    WaqfSign(
      symbol: 'ج',
      nameArabic: 'وقف جائز',
      nameBengali: 'ওয়াকফি জায়িজ',
      nameEnglish: 'Waqf Jaiz (Permissible Stop)',
      descriptionBengali: '"জীম" ওয়াকফি জায়িজ। এখানে ওয়াকুফ করা না করা উভয়ই জায়েয; কিন্তু ওয়াকুফ করা উত্তম।',
      descriptionEnglish: 'Jeem sign. Both stopping and continuing are permissible, but stopping is better.',
      preferredStop: true,
    ),

    // 06. Waqf Murakhkhas (ص)
    WaqfSign(
      symbol: 'ص',
      nameArabic: 'وقف مرخص',
      nameBengali: 'ওয়াকফি মুরাখখছ',
      nameEnglish: 'Waqf Murakhkhas (Licensed Stop)',
      descriptionBengali: '"ছদ" ওয়াকফি মুরাখখছ। এখানে দম না ফেলে মিলিয়ে পড়া উত্তম।',
      descriptionEnglish: 'Sad sign. It is better to continue without stopping.',
    ),

    // 07. Waqf Al-Aih (لا)
    WaqfSign(
      symbol: 'لا',
      nameArabic: 'وقف الائه',
      nameBengali: 'ওয়াকফি আলাইহ',
      nameEnglish: 'Waqf Al-Aih (No Stop)',
      descriptionBengali: '"লা" ওয়াকফি আলাইহ। এখানে দম ফেলানো যাবে না।',
      descriptionEnglish: 'La sign. Do not stop here.',
      mustNotStop: true,
    ),

    // 08. Waqf Mu\'anaqah (∴)
    WaqfSign(
      symbol: '∴',
      nameArabic: 'وقف معانقة',
      nameBengali: 'ওয়াকফি মুআনাকাহ',
      nameEnglish: 'Waqf Mu\'anaqah (Embracing Stop)',
      descriptionBengali: '"৩ ফোটা + ৩ ফোটা মোট ৬ ফোটা" ওয়াকফি মুআনাকাহ। দুই জায়গার এক জায়গায় দম ফেলানো যাবে।',
      descriptionEnglish: 'Six dots (3+3). Stop at one of the two marked places, not both.',
    ),

    // 09. Waqf Gufran (غ)
    WaqfSign(
      symbol: 'غ',
      nameArabic: 'وقف غفران',
      nameBengali: 'ওয়াকফি গুফরান',
      nameEnglish: 'Waqf Gufran (Forgiveness Stop)',
      descriptionBengali: '"গাঈন" ওয়াকফি গুফরান। দম ফেললে ছগিরাহ গুনাহ মাফ হয়।',
      descriptionEnglish: 'Ghain sign. Stopping here brings forgiveness for minor sins.',
      preferredStop: true,
    ),

    // 10. Waqf Amr (ڤ)
    WaqfSign(
      symbol: 'ڤ',
      nameArabic: 'وقف أمر',
      nameBengali: 'ওয়াকফি আমর',
      nameEnglish: 'Waqf Amr (Commanded Stop)',
      descriptionBengali: '"ক্বিফ" ওয়াকফি আমর। দম ফেলিবার হুকুম করা হয়েছে।',
      descriptionEnglish: 'Qif sign. You are commanded to stop here.',
      mustStop: true,
    ),

    // 11. Waqf Mujawwaz (ز)
    WaqfSign(
      symbol: 'ز',
      nameArabic: 'وقف مجوز',
      nameBengali: 'ওয়াকফি মুজাউয়াজ',
      nameEnglish: 'Waqf Mujawwaz (Permitted Stop)',
      descriptionBengali: '"জা" ওয়াকফি মুজাউয়াজ। এখানে ওয়াকুফ করা না করা উভয়ই জায়েয; কিন্তু ওয়াকুফ না করা উত্তম।',
      descriptionEnglish: 'Za sign. Both stopping and continuing are permissible, but continuing is better.',
    ),

    // 12. Waqf Qila Al-Aih (ق)
    WaqfSign(
      symbol: 'ق',
      nameArabic: 'وقف قيل الائه',
      nameBengali: 'ওয়াকফি কিলা আলাইহ',
      nameEnglish: 'Waqf Qila Al-Aih',
      descriptionBengali: '"ক্বাফ" ওয়াকফি কিলা আলাইহ। দম ফেলানো ভাল।',
      descriptionEnglish: 'Qaf sign. It is good to stop here.',
      preferredStop: true,
    ),

    // 13. Waqf Saktah (سـ)
    WaqfSign(
      symbol: 'سـ',
      nameArabic: 'وقف سكتة',
      nameBengali: 'ওয়াকফি সাকতাহ',
      nameEnglish: 'Waqf Saktah (Brief Pause)',
      descriptionBengali: 'ওয়াকফি সাকতাহ। দম না ফেলে আওয়াজ বন্ধ করতে হয়।',
      descriptionEnglish: 'Saktah sign. Pause briefly without taking a breath.',
    ),

    // 14. Wasl Awla (صلي)
    WaqfSign(
      symbol: 'صلي',
      nameArabic: 'وصل أولى',
      nameBengali: 'ওয়াছল আওলা',
      nameEnglish: 'Wasl Awla (Better to Continue)',
      descriptionBengali: 'ওয়াছল আওলা। পড়ে যাওয়াই উত্তম।',
      descriptionEnglish: 'It is better to continue reading without stopping.',
    ),

    // 15. Waqf Jibrail (ك)
    WaqfSign(
      symbol: 'ك',
      nameArabic: 'وقف جبرئيل',
      nameBengali: 'ওয়াকফি জিবরঈল',
      nameEnglish: 'Waqf Jibrail (Angel\'s Stop)',
      descriptionBengali: 'ওয়াকফি জিবরঈল। দম ফেলা বরকতপূর্ণ।',
      descriptionEnglish: 'Jibrail\'s stop. Stopping here is blessed.',
      preferredStop: true,
    ),

    // 16. Waqf Nabi (ں)
    WaqfSign(
      symbol: 'ں',
      nameArabic: 'وقف نبي',
      nameBengali: 'ওয়াকফি নাবী (সঃ)',
      nameEnglish: 'Waqf Nabi (Prophet\'s Stop)',
      descriptionBengali: 'ওয়াকফি নাবী (সঃ)। দম ফেলা অতি উত্তম।',
      descriptionEnglish: 'Prophet\'s stop. It is highly recommended to stop here.',
      preferredStop: true,
    ),

    // 17. Waqf Manzil (ل)
    WaqfSign(
      symbol: 'ل',
      nameArabic: 'وقف منزل',
      nameBengali: 'ওয়াকফে মানযিল',
      nameEnglish: 'Waqf Manzil (Station Stop)',
      descriptionBengali: 'এই চিহ্নকে ওয়াকুফে মানযিল বলে। এরূপ স্থানে ওয়াকুফ করতে হয়।',
      descriptionEnglish: 'Manzil stop sign. This marks a station where you should stop.',
      mustStop: true,
    ),
  ];

  /// Get all waqf signs as a list
  static List<WaqfSign> getAllSigns() => allSigns;

  /// Get signs that require stopping
  static List<WaqfSign> getMustStopSigns() =>
      allSigns.where((s) => s.mustStop).toList();

  /// Get signs where stopping is not allowed
  static List<WaqfSign> getMustNotStopSigns() =>
      allSigns.where((s) => s.mustNotStop).toList();

  /// Get signs where stopping is preferred
  static List<WaqfSign> getPreferredStopSigns() =>
      allSigns.where((s) => s.preferredStop).toList();
}

/// Translation color coding information
/// Used to indicate different types of translations in Bengali Quran
class TranslationColorInfo {
  final Color color;
  final String nameBengali;
  final String nameEnglish;
  final String descriptionBengali;
  final String descriptionEnglish;

  const TranslationColorInfo({
    required this.color,
    required this.nameBengali,
    required this.nameEnglish,
    required this.descriptionBengali,
    required this.descriptionEnglish,
  });
}

/// Data class containing translation color coding information
class TranslationColorsData {
  static const List<TranslationColorInfo> allColors = [
    TranslationColorInfo(
      color: Color(0xFF1565C0), // Blue
      nameBengali: 'নীল রং',
      nameEnglish: 'Blue Color',
      descriptionBengali: 'রাব্বানা দিয়ে শুরু আয়াতগুলো বুঝাতে বাংলা অনুবাদে নীল রং ব্যবহার করা হয়েছে।',
      descriptionEnglish: 'Blue color is used in Bengali translation for verses starting with "Rabbana" (Our Lord).',
    ),
    TranslationColorInfo(
      color: Color(0xFFE91E63), // Pink
      nameBengali: 'গোলাপী রং',
      nameEnglish: 'Pink Color',
      descriptionBengali: 'রাবি দিয়ে শুরু আয়াতগুলো বুঝাতে বাংলা অনুবাদে গোলাপী রং ব্যবহার করা হয়েছে।',
      descriptionEnglish: 'Pink color is used in Bengali translation for verses starting with "Rabbi" (My Lord).',
    ),
  ];

  /// Get all translation colors
  static List<TranslationColorInfo> getAllColors() => allColors;
}

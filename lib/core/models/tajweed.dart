import 'package:flutter/material.dart';

/// Enum representing different Tajweed rules for Quran recitation
/// Colors are based on the standard Bengali Quran Tajweed color coding
/// Includes rules from Quran.com API text_uthmani_tajweed field
enum TajweedRule {
  /// غنة - Nasalization - nasal sound (RED - গুন্নাহ)
  ghunnah,

  /// إخفاء - Hiding/Concealment - nasalization without complete assimilation (BLUE - ইখফা)
  ikhfa,

  /// إخفاء شفوي - Labial Ikhfa - hiding with meem (LIGHT BLUE - ইখফা শাফাওয়ী)
  ikhfaShafawi,

  /// قلقلة - Echoing - slight bouncing sound on certain letters (BROWN/MAROON - কলকলা)
  qalqalah,

  /// إدغام مع غنة - Assimilation with nasalization (GREEN - ইদগাম)
  idgham,

  /// إدغام بدون غنة - Assimilation without nasalization (DARK GREEN - ইদগাম বিলা গুন্নাহ)
  idghamWoGhunnah,

  /// إدغام شفوي - Labial Idgham - assimilation with meem (TEAL - ইদগাম শাফাওয়ী)
  idghamShafawi,

  /// إقلاب - Conversion - changing noon sakinah to meem (PURPLE - ইকলাব)
  iqlab,

  /// إظهار - Clear pronunciation - pronouncing noon sakinah clearly (DARK BLUE - ইজহার)
  izhar,

  /// صفير - Whistling sound - for letters ص ز س (ORANGE - ছফিরহ)
  safir,

  /// مد - Elongation - prolonging a vowel sound (PINK - মাদ)
  madd,

  /// مد لازم - Necessary Madd - 6 counts elongation (DEEP PINK - মাদ লাযিম)
  maddNecessary,

  /// مد واجب - Obligatory Madd - 4-5 counts elongation (HOT PINK - মাদ ওয়াজিব)
  maddObligatory,

  /// مد جائز - Permissible Madd - 2-4-6 counts elongation (LIGHT PINK - মাদ জায়িয)
  maddPermissible,

  /// همزة الوصل - Connecting Hamza - silent when continuing (GRAY - হামযাতুল ওয়াসল)
  hamzaWasl,

  /// لام شمسية - Sun Lam - assimilated lam (CYAN - লাম শামসিয়া)
  laamShamsiyah,

  /// Silent letters - not pronounced (LIGHT GRAY - নীরব অক্ষর)
  silent,

  /// Normal text without any special Tajweed rule
  normal,
}

/// Extension to provide additional properties for TajweedRule
extension TajweedRuleExtension on TajweedRule {
  /// Get the color associated with this Tajweed rule
  /// Colors match the standard Bengali Quran Tajweed color coding
  Color get color {
    switch (this) {
      case TajweedRule.ghunnah:
        return const Color(0xFFE53935); // Red - গুন্নাহ
      case TajweedRule.ikhfa:
        return const Color(0xFF2196F3); // Blue - ইখফা
      case TajweedRule.ikhfaShafawi:
        return const Color(0xFF03A9F4); // Light Blue - ইখফা শাফাওয়ী
      case TajweedRule.qalqalah:
        return const Color(0xFF8B4513); // Brown/Maroon - কলকলা
      case TajweedRule.idgham:
        return const Color(0xFF4CAF50); // Green - ইদগাম
      case TajweedRule.idghamWoGhunnah:
        return const Color(0xFF2E7D32); // Dark Green - ইদগাম বিলা গুন্নাহ
      case TajweedRule.idghamShafawi:
        return const Color(0xFF009688); // Teal - ইদগাম শাফাওয়ী
      case TajweedRule.iqlab:
        return const Color(0xFF9C27B0); // Purple - ইকলাব
      case TajweedRule.izhar:
        return const Color(0xFF1A237E); // Dark Blue - ইজহার
      case TajweedRule.safir:
        return const Color(0xFFFF9800); // Orange - ছফিরহ
      case TajweedRule.madd:
        return const Color(0xFFE91E63); // Pink - মাদ
      case TajweedRule.maddNecessary:
        return const Color(0xFFC2185B); // Deep Pink - মাদ লাযিম
      case TajweedRule.maddObligatory:
        return const Color(0xFFD81B60); // Hot Pink - মাদ ওয়াজিব
      case TajweedRule.maddPermissible:
        return const Color(0xFFF06292); // Light Pink - মাদ জায়িয
      case TajweedRule.hamzaWasl:
        return const Color(0xFF757575); // Gray - হামযাতুল ওয়াসল
      case TajweedRule.laamShamsiyah:
        return const Color(0xFF00BCD4); // Cyan - লাম শামসিয়া
      case TajweedRule.silent:
        return const Color(0xFFBDBDBD); // Light Gray - নীরব অক্ষর
      case TajweedRule.normal:
        return Colors.black;
    }
  }

  /// Get the Arabic name of this Tajweed rule
  String get arabicName {
    switch (this) {
      case TajweedRule.ghunnah:
        return 'غُنَّة';
      case TajweedRule.ikhfa:
        return 'إخفاء';
      case TajweedRule.ikhfaShafawi:
        return 'إخفاء شفوي';
      case TajweedRule.qalqalah:
        return 'قلقلة';
      case TajweedRule.idgham:
        return 'إدغام';
      case TajweedRule.idghamWoGhunnah:
        return 'إدغام بدون غنة';
      case TajweedRule.idghamShafawi:
        return 'إدغام شفوي';
      case TajweedRule.iqlab:
        return 'إقلاب';
      case TajweedRule.izhar:
        return 'إظهار';
      case TajweedRule.safir:
        return 'صفير';
      case TajweedRule.madd:
        return 'مد';
      case TajweedRule.maddNecessary:
        return 'مد لازم';
      case TajweedRule.maddObligatory:
        return 'مد واجب';
      case TajweedRule.maddPermissible:
        return 'مد جائز';
      case TajweedRule.hamzaWasl:
        return 'همزة الوصل';
      case TajweedRule.laamShamsiyah:
        return 'لام شمسية';
      case TajweedRule.silent:
        return 'حرف ساكن';
      case TajweedRule.normal:
        return 'عادي';
    }
  }

  /// Get the English name of this Tajweed rule
  String get englishName {
    switch (this) {
      case TajweedRule.ghunnah:
        return 'Ghunnah (Nasalization)';
      case TajweedRule.ikhfa:
        return 'Ikhfa (Concealment)';
      case TajweedRule.ikhfaShafawi:
        return 'Ikhfa Shafawi (Labial)';
      case TajweedRule.qalqalah:
        return 'Qalqalah (Echoing)';
      case TajweedRule.idgham:
        return 'Idgham (Assimilation)';
      case TajweedRule.idghamWoGhunnah:
        return 'Idgham without Ghunnah';
      case TajweedRule.idghamShafawi:
        return 'Idgham Shafawi (Labial)';
      case TajweedRule.iqlab:
        return 'Iqlab (Conversion)';
      case TajweedRule.izhar:
        return 'Izhar (Clear)';
      case TajweedRule.safir:
        return 'Safir (Whistling)';
      case TajweedRule.madd:
        return 'Madd (Elongation)';
      case TajweedRule.maddNecessary:
        return 'Madd Lazim (Necessary)';
      case TajweedRule.maddObligatory:
        return 'Madd Wajib (Obligatory)';
      case TajweedRule.maddPermissible:
        return 'Madd Jaiz (Permissible)';
      case TajweedRule.hamzaWasl:
        return 'Hamzatul Wasl';
      case TajweedRule.laamShamsiyah:
        return 'Lam Shamsiyyah';
      case TajweedRule.silent:
        return 'Silent Letter';
      case TajweedRule.normal:
        return 'Normal';
    }
  }

  /// Get the Bengali name of this Tajweed rule
  String get bengaliName {
    switch (this) {
      case TajweedRule.ghunnah:
        return 'গুন্নাহ';
      case TajweedRule.ikhfa:
        return 'ইখফা';
      case TajweedRule.ikhfaShafawi:
        return 'ইখফা শাফাওয়ী';
      case TajweedRule.qalqalah:
        return 'কলকলা';
      case TajweedRule.idgham:
        return 'ইদগাম';
      case TajweedRule.idghamWoGhunnah:
        return 'ইদগাম বিলা গুন্নাহ';
      case TajweedRule.idghamShafawi:
        return 'ইদগাম শাফাওয়ী';
      case TajweedRule.iqlab:
        return 'ইকলাব';
      case TajweedRule.izhar:
        return 'ইজহার';
      case TajweedRule.safir:
        return 'ছফিরহ';
      case TajweedRule.madd:
        return 'মাদ';
      case TajweedRule.maddNecessary:
        return 'মাদ লাযিম';
      case TajweedRule.maddObligatory:
        return 'মাদ ওয়াজিব';
      case TajweedRule.maddPermissible:
        return 'মাদ জায়িয';
      case TajweedRule.hamzaWasl:
        return 'হামযাতুল ওয়াসল';
      case TajweedRule.laamShamsiyah:
        return 'লাম শামসিয়া';
      case TajweedRule.silent:
        return 'নীরব অক্ষর';
      case TajweedRule.normal:
        return 'সাধারণ';
    }
  }

  /// Get a brief description of this Tajweed rule in English
  String get description {
    switch (this) {
      case TajweedRule.ghunnah:
        return 'A nasal sound that comes from the nose, typically lasting 2 counts. Associated with noon and meem mushaddad.';
      case TajweedRule.ikhfa:
        return 'A nasalized sound between Izhar and Idgham. The noon sakinah or tanween is hidden when followed by one of 15 letters.';
      case TajweedRule.ikhfaShafawi:
        return 'Labial Ikhfa - hiding the meem sakinah when followed by the letter Ba (ب) with a nasal sound.';
      case TajweedRule.qalqalah:
        return 'A slight echoing or bouncing sound on the letters: ق ط ب ج د when they have sukoon.';
      case TajweedRule.idgham:
        return 'Merging of noon sakinah or tanween into the following letter with nasalization. Occurs with letters: ي ن م و';
      case TajweedRule.idghamWoGhunnah:
        return 'Merging without nasalization. Occurs when noon sakinah or tanween is followed by ل or ر';
      case TajweedRule.idghamShafawi:
        return 'Labial Idgham - merging meem sakinah into another meem that follows it.';
      case TajweedRule.iqlab:
        return 'Converting noon sakinah or tanween into a meem when followed by the letter Ba (ب).';
      case TajweedRule.izhar:
        return 'Clear pronunciation of noon sakinah or tanween when followed by throat letters: ء ه ع ح غ خ';
      case TajweedRule.safir:
        return 'A whistling sound produced when pronouncing the letters: ص ز س';
      case TajweedRule.madd:
        return 'Prolonging the sound of a vowel for 2 counts (natural elongation).';
      case TajweedRule.maddNecessary:
        return 'Necessary elongation for 6 counts. Occurs when madd letter is followed by sukoon or shaddah in same word.';
      case TajweedRule.maddObligatory:
        return 'Obligatory elongation for 4-5 counts. Occurs when madd letter is followed by hamzah in same word.';
      case TajweedRule.maddPermissible:
        return 'Permissible elongation for 2, 4, or 6 counts. Occurs when madd letter is followed by hamzah in next word.';
      case TajweedRule.hamzaWasl:
        return 'Connecting Hamza - pronounced at the beginning of speech but silent when continuing from previous word.';
      case TajweedRule.laamShamsiyah:
        return 'Sun Lam - the lam of "Al" that assimilates into the following sun letter and is not pronounced.';
      case TajweedRule.silent:
        return 'Silent letter - written but not pronounced in recitation.';
      case TajweedRule.normal:
        return 'Regular pronunciation without any special Tajweed rule applied.';
    }
  }

  /// Get the Bengali description of this Tajweed rule
  String get bengaliDescription {
    switch (this) {
      case TajweedRule.ghunnah:
        return 'নাক থেকে আসা একটি নাসিক্য ধ্বনি, সাধারণত ২ মাত্রা স্থায়ী হয়। নূন ও মীম মুশাদ্দাদের সাথে সম্পর্কিত।';
      case TajweedRule.ikhfa:
        return 'ইজহার ও ইদগামের মধ্যবর্তী একটি নাসিক্য ধ্বনি। নূন সাকিন বা তানবিন ১৫টি অক্ষরের আগে গোপন করে পড়া হয়।';
      case TajweedRule.ikhfaShafawi:
        return 'মীম সাকিনের পরে বা (ب) থাকলে নাসিক্য ধ্বনি সহ গোপন করে পড়া।';
      case TajweedRule.qalqalah:
        return 'ق ط ب ج د অক্ষরগুলোতে সুকুন থাকলে সামান্য প্রতিধ্বনি বা ঝংকার দিয়ে পড়া।';
      case TajweedRule.idgham:
        return 'নূন সাকিন বা তানবিনকে গুন্নাহ সহ পরবর্তী অক্ষরে মিলিয়ে পড়া। ي ن م و অক্ষরগুলোর সাথে হয়।';
      case TajweedRule.idghamWoGhunnah:
        return 'গুন্নাহ ছাড়া মিলিয়ে পড়া। নূন সাকিন বা তানবিনের পরে ل বা ر থাকলে হয়।';
      case TajweedRule.idghamShafawi:
        return 'মীম সাকিনের পরে আরেকটি মীম থাকলে মিলিয়ে পড়া।';
      case TajweedRule.iqlab:
        return 'নূন সাকিন বা তানবিনকে মীমে পরিবর্তন করা যখন এর পরে বা (ب) থাকে।';
      case TajweedRule.izhar:
        return 'নূন সাকিন বা তানবিনকে স্পষ্টভাবে পড়া যখন এর পরে হলক্বী হরফ থাকে: ء ه ع ح غ خ';
      case TajweedRule.safir:
        return 'ص ز س অক্ষরগুলো উচ্চারণ করার সময় শিস দেওয়ার মতো আওয়াজ।';
      case TajweedRule.madd:
        return 'স্বরধ্বনিকে ২ মাত্রা দীর্ঘায়িত করা (স্বাভাবিক মাদ)।';
      case TajweedRule.maddNecessary:
        return 'মাদ লাযিম - ৬ মাত্রা টানা। মাদ অক্ষরের পরে একই শব্দে সুকুন বা শাদ্দাহ থাকলে।';
      case TajweedRule.maddObligatory:
        return 'মাদ ওয়াজিব - ৪-৫ মাত্রা টানা। মাদ অক্ষরের পরে একই শব্দে হামযাহ থাকলে।';
      case TajweedRule.maddPermissible:
        return 'মাদ জায়িয - ২, ৪, বা ৬ মাত্রা টানা। মাদ অক্ষরের পরে পরবর্তী শব্দে হামযাহ থাকলে।';
      case TajweedRule.hamzaWasl:
        return 'হামযাতুল ওয়াসল - শুরুতে উচ্চারিত হয় কিন্তু মিলিয়ে পড়লে নীরব থাকে।';
      case TajweedRule.laamShamsiyah:
        return 'লাম শামসিয়া - "আল" এর লাম যা পরবর্তী শামসী অক্ষরে মিলে যায় এবং উচ্চারিত হয় না।';
      case TajweedRule.silent:
        return 'নীরব অক্ষর - লেখা থাকে কিন্তু তিলাওয়াতে উচ্চারিত হয় না।';
      case TajweedRule.normal:
        return 'কোনো বিশেষ তাজবীদ নিয়ম ছাড়াই সাধারণ উচ্চারণ।';
    }
  }

  /// Get the XML tag name for this rule (used in markup)
  String get tagName {
    switch (this) {
      case TajweedRule.ghunnah:
        return 'ghunnah';
      case TajweedRule.ikhfa:
        return 'ikhfa';
      case TajweedRule.ikhfaShafawi:
        return 'ikhfa_shafawi';
      case TajweedRule.qalqalah:
        return 'qalqalah';
      case TajweedRule.idgham:
        return 'idgham';
      case TajweedRule.idghamWoGhunnah:
        return 'idgham_wo_ghunnah';
      case TajweedRule.idghamShafawi:
        return 'idgham_shafawi';
      case TajweedRule.iqlab:
        return 'iqlab';
      case TajweedRule.izhar:
        return 'izhar';
      case TajweedRule.safir:
        return 'safir';
      case TajweedRule.madd:
        return 'madd';
      case TajweedRule.maddNecessary:
        return 'madd_necessary';
      case TajweedRule.maddObligatory:
        return 'madd_obligatory';
      case TajweedRule.maddPermissible:
        return 'madd_permissible';
      case TajweedRule.hamzaWasl:
        return 'ham_wasl';
      case TajweedRule.laamShamsiyah:
        return 'laam_shamsiyah';
      case TajweedRule.silent:
        return 'slnt';
      case TajweedRule.normal:
        return 'normal';
    }
  }

  /// Parse a tag name to get the corresponding TajweedRule
  /// Supports both app's internal tags and Quran.com API class names
  static TajweedRule fromTagName(String tagName) {
    switch (tagName.toLowerCase()) {
      case 'ghunnah':
        return TajweedRule.ghunnah;
      case 'ikhfa':
      case 'ikhafa': // Quran.com API uses this spelling
        return TajweedRule.ikhfa;
      case 'ikhfa_shafawi':
      case 'ikhafa_shafawi': // Quran.com API
        return TajweedRule.ikhfaShafawi;
      case 'qalqalah':
      case 'qalaqah': // Quran.com API uses this spelling
        return TajweedRule.qalqalah;
      case 'idgham':
      case 'idgham_ghunnah': // Quran.com API
        return TajweedRule.idgham;
      case 'idgham_wo_ghunnah':
        return TajweedRule.idghamWoGhunnah;
      case 'idgham_shafawi':
        return TajweedRule.idghamShafawi;
      case 'iqlab':
        return TajweedRule.iqlab;
      case 'izhar':
        return TajweedRule.izhar;
      case 'safir':
        return TajweedRule.safir;
      case 'madd':
      case 'madda_normal': // Quran.com API
        return TajweedRule.madd;
      case 'madd_necessary':
      case 'madda_necessary': // Quran.com API
        return TajweedRule.maddNecessary;
      case 'madd_obligatory':
      case 'madda_obligatory': // Quran.com API
        return TajweedRule.maddObligatory;
      case 'madd_permissible':
      case 'madda_permissible': // Quran.com API
        return TajweedRule.maddPermissible;
      case 'ham_wasl':
      case 'hamza_wasl':
        return TajweedRule.hamzaWasl;
      case 'laam_shamsiyah':
        return TajweedRule.laamShamsiyah;
      case 'slnt':
      case 'silent':
        return TajweedRule.silent;
      default:
        return TajweedRule.normal;
    }
  }
}

/// Represents a segment of text with a specific Tajweed rule applied
class TajweedSegment {
  /// The text content of this segment
  final String text;

  /// The Tajweed rule applied to this segment
  final TajweedRule rule;

  const TajweedSegment({
    required this.text,
    required this.rule,
  });

  /// Create a normal text segment
  factory TajweedSegment.normal(String text) {
    return TajweedSegment(text: text, rule: TajweedRule.normal);
  }

  /// Get the color for this segment based on its rule
  Color getColor({Color? normalColor}) {
    if (rule == TajweedRule.normal) {
      return normalColor ?? Colors.black;
    }
    return rule.color;
  }

  @override
  String toString() => 'TajweedSegment(text: $text, rule: ${rule.englishName})';
}

/// Configuration for Tajweed colors (allows customization)
/// Default colors match the standard Bengali Quran Tajweed color coding
class TajweedColors {
  final Color ghunnah;
  final Color ikhfa;
  final Color ikhfaShafawi;
  final Color qalqalah;
  final Color idgham;
  final Color idghamWoGhunnah;
  final Color idghamShafawi;
  final Color iqlab;
  final Color izhar;
  final Color safir;
  final Color madd;
  final Color maddNecessary;
  final Color maddObligatory;
  final Color maddPermissible;
  final Color hamzaWasl;
  final Color laamShamsiyah;
  final Color silent;
  final Color normal;

  const TajweedColors({
    this.ghunnah = const Color(0xFFE53935), // Red - গুন্নাহ
    this.ikhfa = const Color(0xFF2196F3), // Blue - ইখফা
    this.ikhfaShafawi = const Color(0xFF03A9F4), // Light Blue - ইখফা শাফাওয়ী
    this.qalqalah = const Color(0xFF8B4513), // Brown/Maroon - কলকলা
    this.idgham = const Color(0xFF4CAF50), // Green - ইদগাম
    this.idghamWoGhunnah = const Color(0xFF2E7D32), // Dark Green - ইদগাম বিলা গুন্নাহ
    this.idghamShafawi = const Color(0xFF009688), // Teal - ইদগাম শাফাওয়ী
    this.iqlab = const Color(0xFF9C27B0), // Purple - ইকলাব
    this.izhar = const Color(0xFF1A237E), // Dark Blue - ইজহার
    this.safir = const Color(0xFFFF9800), // Orange - ছফিরহ
    this.madd = const Color(0xFFE91E63), // Pink - মাদ
    this.maddNecessary = const Color(0xFFC2185B), // Deep Pink - মাদ লাযিম
    this.maddObligatory = const Color(0xFFD81B60), // Hot Pink - মাদ ওয়াজিব
    this.maddPermissible = const Color(0xFFF06292), // Light Pink - মাদ জায়িয
    this.hamzaWasl = const Color(0xFF757575), // Gray - হামযাতুল ওয়াসল
    this.laamShamsiyah = const Color(0xFF00BCD4), // Cyan - লাম শামসিয়া
    this.silent = const Color(0xFFBDBDBD), // Light Gray - নীরব অক্ষর
    this.normal = Colors.black,
  });

  /// Default Tajweed colors matching Bengali Quran style
  static const TajweedColors bengaliQuran = TajweedColors();

  /// Get color for a specific rule
  Color colorForRule(TajweedRule rule) {
    switch (rule) {
      case TajweedRule.ghunnah:
        return ghunnah;
      case TajweedRule.ikhfa:
        return ikhfa;
      case TajweedRule.ikhfaShafawi:
        return ikhfaShafawi;
      case TajweedRule.qalqalah:
        return qalqalah;
      case TajweedRule.idgham:
        return idgham;
      case TajweedRule.idghamWoGhunnah:
        return idghamWoGhunnah;
      case TajweedRule.idghamShafawi:
        return idghamShafawi;
      case TajweedRule.iqlab:
        return iqlab;
      case TajweedRule.izhar:
        return izhar;
      case TajweedRule.safir:
        return safir;
      case TajweedRule.madd:
        return madd;
      case TajweedRule.maddNecessary:
        return maddNecessary;
      case TajweedRule.maddObligatory:
        return maddObligatory;
      case TajweedRule.maddPermissible:
        return maddPermissible;
      case TajweedRule.hamzaWasl:
        return hamzaWasl;
      case TajweedRule.laamShamsiyah:
        return laamShamsiyah;
      case TajweedRule.silent:
        return silent;
      case TajweedRule.normal:
        return normal;
    }
  }
}

import 'package:flutter/material.dart';

/// Enum representing different Tajweed rules for Quran recitation
/// Colors are based on the standard Bengali Quran Tajweed color coding
enum TajweedRule {
  /// غنة - Nasalization - nasal sound (RED - গুন্নাহ)
  ghunnah,

  /// إخفاء - Hiding/Concealment - nasalization without complete assimilation (BLUE - ইখফা)
  ikhfa,

  /// قلقلة - Echoing - slight bouncing sound on certain letters (BROWN/MAROON - কলকলা)
  qalqalah,

  /// إدغام - Assimilation - merging of two letters (GREEN - ইদগাম)
  idgham,

  /// إقلاب - Conversion - changing noon sakinah to meem (PURPLE - ইকলাব)
  iqlab,

  /// إظهار - Clear pronunciation - pronouncing noon sakinah clearly (DARK BLUE - ইজহার)
  izhar,

  /// صفير - Whistling sound - for letters ص ز س (ORANGE - ছফিরহ)
  safir,

  /// مد - Elongation - prolonging a vowel sound (PINK - মাদ)
  madd,

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
      case TajweedRule.qalqalah:
        return const Color(0xFF8B4513); // Brown/Maroon - কলকলা
      case TajweedRule.idgham:
        return const Color(0xFF4CAF50); // Green - ইদগাম
      case TajweedRule.iqlab:
        return const Color(0xFF9C27B0); // Purple - ইকলাব
      case TajweedRule.izhar:
        return const Color(0xFF1A237E); // Dark Blue - ইজহার
      case TajweedRule.safir:
        return const Color(0xFFFF9800); // Orange - ছফিরহ
      case TajweedRule.madd:
        return const Color(0xFFE91E63); // Pink - মাদ
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
      case TajweedRule.qalqalah:
        return 'قلقلة';
      case TajweedRule.idgham:
        return 'إدغام';
      case TajweedRule.iqlab:
        return 'إقلاب';
      case TajweedRule.izhar:
        return 'إظهار';
      case TajweedRule.safir:
        return 'صفير';
      case TajweedRule.madd:
        return 'مد';
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
      case TajweedRule.qalqalah:
        return 'Qalqalah (Echoing)';
      case TajweedRule.idgham:
        return 'Idgham (Assimilation)';
      case TajweedRule.iqlab:
        return 'Iqlab (Conversion)';
      case TajweedRule.izhar:
        return 'Izhar (Clear)';
      case TajweedRule.safir:
        return 'Safir (Whistling)';
      case TajweedRule.madd:
        return 'Madd (Elongation)';
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
      case TajweedRule.qalqalah:
        return 'কলকলা';
      case TajweedRule.idgham:
        return 'ইদগাম';
      case TajweedRule.iqlab:
        return 'ইকলাব';
      case TajweedRule.izhar:
        return 'ইজহার';
      case TajweedRule.safir:
        return 'ছফিরহ';
      case TajweedRule.madd:
        return 'মাদ';
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
      case TajweedRule.qalqalah:
        return 'A slight echoing or bouncing sound on the letters: ق ط ب ج د when they have sukoon.';
      case TajweedRule.idgham:
        return 'Merging of noon sakinah or tanween into the following letter. Occurs with letters: ي ن م و ل ر';
      case TajweedRule.iqlab:
        return 'Converting noon sakinah or tanween into a meem when followed by the letter Ba (ب).';
      case TajweedRule.izhar:
        return 'Clear pronunciation of noon sakinah or tanween when followed by throat letters: ء ه ع ح غ خ';
      case TajweedRule.safir:
        return 'A whistling sound produced when pronouncing the letters: ص ز س';
      case TajweedRule.madd:
        return 'Prolonging the sound of a vowel. The elongation varies from 2 to 6 counts depending on the type.';
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
      case TajweedRule.qalqalah:
        return 'ق ط ب ج د অক্ষরগুলোতে সুকুন থাকলে সামান্য প্রতিধ্বনি বা ঝংকার দিয়ে পড়া।';
      case TajweedRule.idgham:
        return 'নূন সাকিন বা তানবিনকে পরবর্তী অক্ষরে মিলিয়ে পড়া। ي ن م و ل ر অক্ষরগুলোর সাথে হয়।';
      case TajweedRule.iqlab:
        return 'নূন সাকিন বা তানবিনকে মীমে পরিবর্তন করা যখন এর পরে বা (ب) থাকে।';
      case TajweedRule.izhar:
        return 'নূন সাকিন বা তানবিনকে স্পষ্টভাবে পড়া যখন এর পরে হলক্বী হরফ থাকে: ء ه ع ح غ خ';
      case TajweedRule.safir:
        return 'ص ز س অক্ষরগুলো উচ্চারণ করার সময় শিস দেওয়ার মতো আওয়াজ।';
      case TajweedRule.madd:
        return 'স্বরধ্বনিকে দীর্ঘায়িত করা। প্রকারভেদে ২ থেকে ৬ মাত্রা পর্যন্ত টানা হয়।';
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
      case TajweedRule.qalqalah:
        return 'qalqalah';
      case TajweedRule.idgham:
        return 'idgham';
      case TajweedRule.iqlab:
        return 'iqlab';
      case TajweedRule.izhar:
        return 'izhar';
      case TajweedRule.safir:
        return 'safir';
      case TajweedRule.madd:
        return 'madd';
      case TajweedRule.normal:
        return 'normal';
    }
  }

  /// Parse a tag name to get the corresponding TajweedRule
  static TajweedRule fromTagName(String tagName) {
    switch (tagName.toLowerCase()) {
      case 'ghunnah':
        return TajweedRule.ghunnah;
      case 'ikhfa':
        return TajweedRule.ikhfa;
      case 'qalqalah':
        return TajweedRule.qalqalah;
      case 'idgham':
        return TajweedRule.idgham;
      case 'iqlab':
        return TajweedRule.iqlab;
      case 'izhar':
        return TajweedRule.izhar;
      case 'safir':
        return TajweedRule.safir;
      case 'madd':
        return TajweedRule.madd;
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
  final Color qalqalah;
  final Color idgham;
  final Color iqlab;
  final Color izhar;
  final Color safir;
  final Color madd;
  final Color normal;

  const TajweedColors({
    this.ghunnah = const Color(0xFFE53935), // Red - গুন্নাহ
    this.ikhfa = const Color(0xFF2196F3), // Blue - ইখফা
    this.qalqalah = const Color(0xFF8B4513), // Brown/Maroon - কলকলা
    this.idgham = const Color(0xFF4CAF50), // Green - ইদগাম
    this.iqlab = const Color(0xFF9C27B0), // Purple - ইকলাব
    this.izhar = const Color(0xFF1A237E), // Dark Blue - ইজহার
    this.safir = const Color(0xFFFF9800), // Orange - ছফিরহ
    this.madd = const Color(0xFFE91E63), // Pink - মাদ
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
      case TajweedRule.qalqalah:
        return qalqalah;
      case TajweedRule.idgham:
        return idgham;
      case TajweedRule.iqlab:
        return iqlab;
      case TajweedRule.izhar:
        return izhar;
      case TajweedRule.safir:
        return safir;
      case TajweedRule.madd:
        return madd;
      case TajweedRule.normal:
        return normal;
    }
  }
}

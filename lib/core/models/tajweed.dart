import 'package:flutter/material.dart';

/// Enum representing different Tajweed rules for Quran recitation
enum TajweedRule {
  /// إخفاء - Hiding/Concealment - nasalization without complete assimilation
  ikhfa,

  /// إدغام - Assimilation - merging of two letters
  idgham,

  /// إقلاب - Conversion - changing noon sakinah to meem
  iqlab,

  /// مد - Elongation - prolonging a vowel sound
  madd,

  /// قلقلة - Echoing - slight bouncing sound on certain letters
  qalqalah,

  /// غنة - Nasalization - nasal sound
  ghunnah,

  /// Normal text without any special Tajweed rule
  normal,
}

/// Extension to provide additional properties for TajweedRule
extension TajweedRuleExtension on TajweedRule {
  /// Get the color associated with this Tajweed rule
  Color get color {
    switch (this) {
      case TajweedRule.ikhfa:
        return const Color(0xFF4CAF50); // Green
      case TajweedRule.idgham:
        return const Color(0xFFE53935); // Red
      case TajweedRule.iqlab:
        return const Color(0xFF9C27B0); // Purple
      case TajweedRule.madd:
        return const Color(0xFF2196F3); // Blue
      case TajweedRule.qalqalah:
        return const Color(0xFFFF9800); // Orange
      case TajweedRule.ghunnah:
        return const Color(0xFFE91E63); // Pink
      case TajweedRule.normal:
        return Colors.black;
    }
  }

  /// Get the Arabic name of this Tajweed rule
  String get arabicName {
    switch (this) {
      case TajweedRule.ikhfa:
        return 'إخفاء';
      case TajweedRule.idgham:
        return 'إدغام';
      case TajweedRule.iqlab:
        return 'إقلاب';
      case TajweedRule.madd:
        return 'مد';
      case TajweedRule.qalqalah:
        return 'قلقلة';
      case TajweedRule.ghunnah:
        return 'غنة';
      case TajweedRule.normal:
        return 'عادي';
    }
  }

  /// Get the English name of this Tajweed rule
  String get englishName {
    switch (this) {
      case TajweedRule.ikhfa:
        return 'Ikhfa (Concealment)';
      case TajweedRule.idgham:
        return 'Idgham (Assimilation)';
      case TajweedRule.iqlab:
        return 'Iqlab (Conversion)';
      case TajweedRule.madd:
        return 'Madd (Elongation)';
      case TajweedRule.qalqalah:
        return 'Qalqalah (Echoing)';
      case TajweedRule.ghunnah:
        return 'Ghunnah (Nasalization)';
      case TajweedRule.normal:
        return 'Normal';
    }
  }

  /// Get the Bengali name of this Tajweed rule
  String get bengaliName {
    switch (this) {
      case TajweedRule.ikhfa:
        return 'ইখফা (গোপন করা)';
      case TajweedRule.idgham:
        return 'ইদগাম (মিলিয়ে পড়া)';
      case TajweedRule.iqlab:
        return 'ইকলাব (পরিবর্তন)';
      case TajweedRule.madd:
        return 'মাদ (দীর্ঘায়িত)';
      case TajweedRule.qalqalah:
        return 'কলকলা (প্রতিধ্বনি)';
      case TajweedRule.ghunnah:
        return 'গুন্নাহ (নাসিক্য ধ্বনি)';
      case TajweedRule.normal:
        return 'সাধারণ';
    }
  }

  /// Get a brief description of this Tajweed rule in English
  String get description {
    switch (this) {
      case TajweedRule.ikhfa:
        return 'A nasalized sound between Izhar and Idgham. The noon sakinah or tanween is hidden when followed by one of 15 letters.';
      case TajweedRule.idgham:
        return 'Merging of noon sakinah or tanween into the following letter. Occurs with letters: ي ن م و ل ر';
      case TajweedRule.iqlab:
        return 'Converting noon sakinah or tanween into a meem when followed by the letter Ba (ب).';
      case TajweedRule.madd:
        return 'Prolonging the sound of a vowel. The elongation varies from 2 to 6 counts depending on the type.';
      case TajweedRule.qalqalah:
        return 'A slight echoing or bouncing sound on the letters: ق ط ب ج د when they have sukoon.';
      case TajweedRule.ghunnah:
        return 'A nasal sound that comes from the nose, typically lasting 2 counts. Associated with noon and meem.';
      case TajweedRule.normal:
        return 'Regular pronunciation without any special Tajweed rule applied.';
    }
  }

  /// Get the Bengali description of this Tajweed rule
  String get bengaliDescription {
    switch (this) {
      case TajweedRule.ikhfa:
        return 'ইজহার ও ইদগামের মধ্যবর্তী একটি নাসিক্য ধ্বনি। নূন সাকিন বা তানবিন ১৫টি অক্ষরের আগে গোপন করে পড়া হয়।';
      case TajweedRule.idgham:
        return 'নূন সাকিন বা তানবিনকে পরবর্তী অক্ষরে মিলিয়ে পড়া। ي ن م و ل ر অক্ষরগুলোর সাথে হয়।';
      case TajweedRule.iqlab:
        return 'নূন সাকিন বা তানবিনকে মীমে পরিবর্তন করা যখন এর পরে বা (ب) থাকে।';
      case TajweedRule.madd:
        return 'স্বরধ্বনিকে দীর্ঘায়িত করা। প্রকারভেদে ২ থেকে ৬ মাত্রা পর্যন্ত টানা হয়।';
      case TajweedRule.qalqalah:
        return 'ق ط ب ج د অক্ষরগুলোতে সুকুন থাকলে সামান্য প্রতিধ্বনি বা ঝংকার।';
      case TajweedRule.ghunnah:
        return 'নাক থেকে আসা একটি নাসিক্য ধ্বনি, সাধারণত ২ মাত্রা স্থায়ী হয়। নূন ও মীমের সাথে সম্পর্কিত।';
      case TajweedRule.normal:
        return 'কোনো বিশেষ তাজবীদ নিয়ম ছাড়াই সাধারণ উচ্চারণ।';
    }
  }

  /// Get the XML tag name for this rule (used in markup)
  String get tagName {
    switch (this) {
      case TajweedRule.ikhfa:
        return 'ikhfa';
      case TajweedRule.idgham:
        return 'idgham';
      case TajweedRule.iqlab:
        return 'iqlab';
      case TajweedRule.madd:
        return 'madd';
      case TajweedRule.qalqalah:
        return 'qalqalah';
      case TajweedRule.ghunnah:
        return 'ghunnah';
      case TajweedRule.normal:
        return 'normal';
    }
  }

  /// Parse a tag name to get the corresponding TajweedRule
  static TajweedRule fromTagName(String tagName) {
    switch (tagName.toLowerCase()) {
      case 'ikhfa':
        return TajweedRule.ikhfa;
      case 'idgham':
        return TajweedRule.idgham;
      case 'iqlab':
        return TajweedRule.iqlab;
      case 'madd':
        return TajweedRule.madd;
      case 'qalqalah':
        return TajweedRule.qalqalah;
      case 'ghunnah':
        return TajweedRule.ghunnah;
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
class TajweedColors {
  final Color ikhfa;
  final Color idgham;
  final Color iqlab;
  final Color madd;
  final Color qalqalah;
  final Color ghunnah;
  final Color normal;

  const TajweedColors({
    this.ikhfa = const Color(0xFF4CAF50),
    this.idgham = const Color(0xFFE53935),
    this.iqlab = const Color(0xFF9C27B0),
    this.madd = const Color(0xFF2196F3),
    this.qalqalah = const Color(0xFFFF9800),
    this.ghunnah = const Color(0xFFE91E63),
    this.normal = Colors.black,
  });

  /// Default Tajweed colors matching Shohoz Quran style
  static const TajweedColors shohozQuran = TajweedColors();

  /// Get color for a specific rule
  Color colorForRule(TajweedRule rule) {
    switch (rule) {
      case TajweedRule.ikhfa:
        return ikhfa;
      case TajweedRule.idgham:
        return idgham;
      case TajweedRule.iqlab:
        return iqlab;
      case TajweedRule.madd:
        return madd;
      case TajweedRule.qalqalah:
        return qalqalah;
      case TajweedRule.ghunnah:
        return ghunnah;
      case TajweedRule.normal:
        return normal;
    }
  }
}

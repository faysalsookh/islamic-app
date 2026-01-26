import '../models/tajweed.dart';

/// Service for parsing and handling Tajweed markup in Quran text
/// Supports both internal XML-style tags and Quran.com API HTML-style format
class TajweedService {
  /// Singleton instance
  static final TajweedService _instance = TajweedService._internal();
  factory TajweedService() => _instance;
  TajweedService._internal();

  /// Regular expression to match internal Tajweed tags
  /// Matches patterns like: <ikhfa>text</ikhfa>, <madd>text</madd>, etc.
  static final RegExp _tajweedTagRegex = RegExp(
    r'<(\w+)>(.*?)</\1>',
    multiLine: true,
    dotAll: true,
  );


  /// Parse text with Tajweed markup into a list of TajweedSegments
  /// Supports both internal XML-style tags and Quran.com API HTML-style format
  ///
  /// Internal format: '<madd>بِسْمِ</madd> اللَّهِ <ghunnah>الرَّحْمَٰنِ</ghunnah>'
  /// Quran.com format: '<tajweed class=madda_normal>ـٰ</tajweed>'
  ///
  /// Returns segments with appropriate Tajweed rules applied
  List<TajweedSegment> parseMarkup(String? textWithMarkup) {
    if (textWithMarkup == null || textWithMarkup.isEmpty) {
      return [];
    }

    // Detect which format is being used
    final isQuranComFormat = textWithMarkup.contains('<tajweed');

    if (isQuranComFormat) {
      return _parseQuranComFormat(textWithMarkup);
    } else {
      return _parseInternalFormat(textWithMarkup);
    }
  }

  /// Parse Quran.com API HTML-style Tajweed format
  List<TajweedSegment> _parseQuranComFormat(String text) {
    final segments = <TajweedSegment>[];
    var lastIndex = 0;

    // Combined regex to match both tajweed and span tags
    final combinedRegex = RegExp(
      r'<(?:tajweed\s+class=|span\s+class=)([a-z_]+)>(.*?)</(?:tajweed|span)>',
      multiLine: true,
      dotAll: true,
    );

    final matches = combinedRegex.allMatches(text);

    for (final match in matches) {
      // Add any text before this tag as normal text
      if (match.start > lastIndex) {
        final normalText = text.substring(lastIndex, match.start);
        if (normalText.isNotEmpty) {
          segments.add(TajweedSegment.normal(normalText));
        }
      }

      // Add the tagged text with its Tajweed rule
      final className = match.group(1)!;
      final taggedText = match.group(2)!;

      // Skip 'end' class (verse number markers)
      if (className == 'end') {
        // Add verse number as normal text
        if (taggedText.isNotEmpty) {
          segments.add(TajweedSegment.normal(' $taggedText'));
        }
      } else {
        final rule = TajweedRuleExtension.fromTagName(className);
        if (taggedText.isNotEmpty) {
          segments.add(TajweedSegment(text: taggedText, rule: rule));
        }
      }

      lastIndex = match.end;
    }

    // Add any remaining text after the last tag
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        segments.add(TajweedSegment.normal(remainingText));
      }
    }

    // If no tags were found, return the entire text as normal
    if (segments.isEmpty && text.isNotEmpty) {
      segments.add(TajweedSegment.normal(text));
    }

    return segments;
  }

  /// Parse internal XML-style Tajweed format
  List<TajweedSegment> _parseInternalFormat(String text) {
    final segments = <TajweedSegment>[];
    var lastIndex = 0;

    // Find all Tajweed tags
    final matches = _tajweedTagRegex.allMatches(text);

    for (final match in matches) {
      // Add any text before this tag as normal text
      if (match.start > lastIndex) {
        final normalText = text.substring(lastIndex, match.start);
        if (normalText.isNotEmpty) {
          segments.add(TajweedSegment.normal(normalText));
        }
      }

      // Add the tagged text with its Tajweed rule
      final tagName = match.group(1)!;
      final taggedText = match.group(2)!;
      final rule = TajweedRuleExtension.fromTagName(tagName);

      if (taggedText.isNotEmpty) {
        segments.add(TajweedSegment(text: taggedText, rule: rule));
      }

      lastIndex = match.end;
    }

    // Add any remaining text after the last tag
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        segments.add(TajweedSegment.normal(remainingText));
      }
    }

    // If no tags were found, return the entire text as normal
    if (segments.isEmpty && text.isNotEmpty) {
      segments.add(TajweedSegment.normal(text));
    }

    return segments;
  }

  /// Convert segments back to markup string (for storage/transmission)
  String toMarkup(List<TajweedSegment> segments) {
    final buffer = StringBuffer();

    for (final segment in segments) {
      if (segment.rule == TajweedRule.normal) {
        buffer.write(segment.text);
      } else {
        buffer.write('<${segment.rule.tagName}>${segment.text}</${segment.rule.tagName}>');
      }
    }

    return buffer.toString();
  }

  /// Strip all Tajweed markup and return plain text
  String stripMarkup(String? textWithMarkup) {
    if (textWithMarkup == null || textWithMarkup.isEmpty) {
      return '';
    }

    return textWithMarkup.replaceAllMapped(
      _tajweedTagRegex,
      (match) => match.group(2) ?? '',
    );
  }

  /// Get all unique Tajweed rules present in a piece of text
  Set<TajweedRule> getRulesInText(String? textWithMarkup) {
    if (textWithMarkup == null || textWithMarkup.isEmpty) {
      return {};
    }

    final rules = <TajweedRule>{};
    final matches = _tajweedTagRegex.allMatches(textWithMarkup);

    for (final match in matches) {
      final tagName = match.group(1)!;
      rules.add(TajweedRuleExtension.fromTagName(tagName));
    }

    return rules;
  }

  /// Check if text contains any Tajweed markup
  bool hasMarkup(String? text) {
    if (text == null || text.isEmpty) return false;
    return _tajweedTagRegex.hasMatch(text);
  }

  /// Get statistics about Tajweed rules in text
  Map<TajweedRule, int> getTajweedStats(String? textWithMarkup) {
    if (textWithMarkup == null || textWithMarkup.isEmpty) {
      return {};
    }

    final stats = <TajweedRule, int>{};
    final matches = _tajweedTagRegex.allMatches(textWithMarkup);

    for (final match in matches) {
      final tagName = match.group(1)!;
      final rule = TajweedRuleExtension.fromTagName(tagName);
      stats[rule] = (stats[rule] ?? 0) + 1;
    }

    return stats;
  }

  /// Validate that all Tajweed tags in text are properly closed
  bool validateMarkup(String? textWithMarkup) {
    if (textWithMarkup == null || textWithMarkup.isEmpty) {
      return true;
    }

    // Check for unclosed tags
    final openTagRegex = RegExp(r'<(\w+)>');
    final closeTagRegex = RegExp(r'</(\w+)>');

    final openTags = openTagRegex.allMatches(textWithMarkup).map((m) => m.group(1)).toList();
    final closeTags = closeTagRegex.allMatches(textWithMarkup).map((m) => m.group(1)).toList();

    // Simple validation: same number of open and close tags
    if (openTags.length != closeTags.length) {
      return false;
    }

    return true;
  }

  /// Generate Tajweed markup for Arabic text algorithmically
  /// This is useful for text that doesn't have pre-annotated tajweed (like IndoPak script)
  /// Detects and marks common tajweed rules based on Arabic patterns
  String generateTajweedMarkup(String arabicText) {
    if (arabicText.isEmpty) return arabicText;

    // Use a segment-based approach to avoid nested tags
    // First, identify all tajweed positions, then build the result
    final List<_TajweedMatch> matches = [];

    // Helper to add matches without overlapping
    void addMatches(RegExp pattern, String tagName) {
      for (final match in pattern.allMatches(arabicText)) {
        // Check if this position is already marked
        bool overlaps = matches.any((m) =>
            (match.start >= m.start && match.start < m.end) ||
            (match.end > m.start && match.end <= m.end) ||
            (match.start <= m.start && match.end >= m.end));
        if (!overlaps) {
          matches.add(_TajweedMatch(match.start, match.end, tagName));
        }
      }
    }

    // Process rules in order of priority (most specific first)
    // Note: Many patterns include variants with/without explicit sukoon (ْ)
    // since IndoPak and some fonts don't always show sukoon explicitly

    // 1. Ghunnah - noon and meem with shaddah (نّ مّ) - very specific
    addMatches(RegExp(r'[نم]ّ'), 'ghunnah');

    // 2. Iqlab - نْب or tanween before ب (with or without explicit sukoon)
    addMatches(RegExp(r'نْ?ب'), 'iqlab');
    addMatches(RegExp(r'[ًٌٍ]\s*ب'), 'iqlab');

    // 3. Idgham - noon sakinah before ي ن م و ل ر
    addMatches(RegExp(r'نْ[ينمولر]'), 'idgham');
    addMatches(RegExp(r'ن\s+[ينمولر]'), 'idgham'); // Across word boundary
    addMatches(RegExp(r'[ًٌٍ]\s*[ينمولر]'), 'idgham');

    // 4. Izhar - noon sakinah before throat letters (ء ه ع ح غ خ أ إ)
    addMatches(RegExp(r'نْ[ءهعحغخأإ]'), 'izhar');
    addMatches(RegExp(r'ن\s+[ءهعحغخأإ]'), 'izhar');
    addMatches(RegExp(r'[ًٌٍ]\s*[ءهعحغخأإ]'), 'izhar');

    // 5. Ikhfa - noon sakinah before 15 ikhfa letters
    addMatches(RegExp(r'نْ[تثجدذزسشصضطظفقك]'), 'ikhfa');
    addMatches(RegExp(r'ن\s+[تثجدذزسشصضطظفقك]'), 'ikhfa');
    addMatches(RegExp(r'[ًٌٍ]\s*[تثجدذزسشصضطظفقك]'), 'ikhfa');

    // 6. Qalqalah - ق ط ب ج د with sukoon or at end of word
    addMatches(RegExp(r'[قطبجد]ْ'), 'qalqalah');
    // At end of word (before space, or before next word)
    addMatches(RegExp(r'[قطبجد](?=\s)'), 'qalqalah');
    // Before consonant without vowel (implied sukoon)
    addMatches(RegExp(r'[قطبجد](?=[بتثجحخدذرزسشصضطظعغفقكلمنهوي][^َُِ])'), 'qalqalah');

    // 7. Safir - ص ز س with sukoon or in sakin position
    addMatches(RegExp(r'[صزس]ْ'), 'safir');
    addMatches(RegExp(r'[صزس](?=\s)'), 'safir');

    // 8. Meem sakinah rules
    addMatches(RegExp(r'مْب'), 'ikhfa_shafawi');
    addMatches(RegExp(r'مْم'), 'idgham_shafawi');
    addMatches(RegExp(r'م\s+ب'), 'ikhfa_shafawi');
    addMatches(RegExp(r'م\s+م'), 'idgham_shafawi');

    // 9. Lam Shamsiyyah - ال before sun letters
    // Sun letters: ت ث د ذ ر ز س ش ص ض ط ظ ل ن
    addMatches(RegExp(r'ال[تثدذرزسشصضطظلن]'), 'laam_shamsiyah');

    // 10. Madd - elongation (most common, process last)
    // Fatha + alif, damma + waw, kasra + ya
    addMatches(RegExp(r'َا'), 'madd');
    addMatches(RegExp(r'ُو'), 'madd');
    addMatches(RegExp(r'ِي'), 'madd');
    addMatches(RegExp(r'ِى'), 'madd');
    // Alif maddah (آ)
    addMatches(RegExp(r'آ'), 'madd');
    // Superscript alif (ٰ) - small alif above
    addMatches(RegExp(r'ٰ'), 'madd');
    addMatches(RegExp(r'ـٰ'), 'madd');
    // Alif with madda: ءَا
    addMatches(RegExp(r'ءَا'), 'madd');
    // Long vowels at specific positions
    addMatches(RegExp(r'ا(?=[ءأإ])'), 'madd'); // Alif before hamza

    // Sort matches by position
    matches.sort((a, b) => a.start.compareTo(b.start));

    // Build result string
    if (matches.isEmpty) return arabicText;

    final buffer = StringBuffer();
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before this match
      if (match.start > lastEnd) {
        buffer.write(arabicText.substring(lastEnd, match.start));
      }
      // Add the tagged match
      buffer.write('<${match.tagName}>');
      buffer.write(arabicText.substring(match.start, match.end));
      buffer.write('</${match.tagName}>');
      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < arabicText.length) {
      buffer.write(arabicText.substring(lastEnd));
    }

    return buffer.toString();
  }
}

/// Helper class for tracking tajweed matches
class _TajweedMatch {
  final int start;
  final int end;
  final String tagName;

  _TajweedMatch(this.start, this.end, this.tagName);
}

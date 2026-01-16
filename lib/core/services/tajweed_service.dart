import '../models/tajweed.dart';

/// Service for parsing and handling Tajweed markup in Quran text
class TajweedService {
  /// Singleton instance
  static final TajweedService _instance = TajweedService._internal();
  factory TajweedService() => _instance;
  TajweedService._internal();

  /// Regular expression to match Tajweed tags
  /// Matches patterns like: <ikhfa>text</ikhfa>, <madd>text</madd>, etc.
  static final RegExp _tajweedTagRegex = RegExp(
    r'<(\w+)>(.*?)</\1>',
    multiLine: true,
    dotAll: true,
  );

  /// Parse text with Tajweed markup into a list of TajweedSegments
  ///
  /// Example input: '<madd>بِسْمِ</madd> اللَّهِ <ghunnah>الرَّحْمَٰنِ</ghunnah>'
  /// Returns segments with appropriate Tajweed rules applied
  List<TajweedSegment> parseMarkup(String? textWithMarkup) {
    if (textWithMarkup == null || textWithMarkup.isEmpty) {
      return [];
    }

    final segments = <TajweedSegment>[];
    var lastIndex = 0;

    // Find all Tajweed tags
    final matches = _tajweedTagRegex.allMatches(textWithMarkup);

    for (final match in matches) {
      // Add any text before this tag as normal text
      if (match.start > lastIndex) {
        final normalText = textWithMarkup.substring(lastIndex, match.start);
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
    if (lastIndex < textWithMarkup.length) {
      final remainingText = textWithMarkup.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        segments.add(TajweedSegment.normal(remainingText));
      }
    }

    // If no tags were found, return the entire text as normal
    if (segments.isEmpty && textWithMarkup.isNotEmpty) {
      segments.add(TajweedSegment.normal(textWithMarkup));
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
}

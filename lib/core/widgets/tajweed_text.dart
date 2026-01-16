import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/tajweed.dart';
import '../services/tajweed_service.dart';

/// A widget that renders Quran text with color-coded Tajweed rules
class TajweedText extends StatelessWidget {
  /// The text with Tajweed markup (e.g., '<madd>بِسْمِ</madd>')
  final String? textWithMarkup;

  /// Plain text to show if markup is null or Tajweed colors are disabled
  final String? plainText;

  /// Whether to show Tajweed colors
  final bool showTajweedColors;

  /// Whether learning mode is enabled (tap to see rule info)
  final bool learningModeEnabled;

  /// Callback when a Tajweed segment is tapped (for learning mode)
  final void Function(TajweedRule rule, String text)? onTajweedTap;

  /// Base text style for the Arabic text
  final TextStyle? textStyle;

  /// Color for normal (non-Tajweed) text
  final Color? normalTextColor;

  /// Text alignment
  final TextAlign textAlign;

  /// Text direction (RTL for Arabic)
  final TextDirection textDirection;

  /// Maximum lines (null for unlimited)
  final int? maxLines;

  /// Overflow behavior
  final TextOverflow overflow;

  /// Custom Tajweed colors (if not using defaults)
  final TajweedColors? customColors;

  const TajweedText({
    super.key,
    this.textWithMarkup,
    this.plainText,
    this.showTajweedColors = true,
    this.learningModeEnabled = false,
    this.onTajweedTap,
    this.textStyle,
    this.normalTextColor,
    this.textAlign = TextAlign.right,
    this.textDirection = TextDirection.rtl,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.customColors,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = textStyle ?? DefaultTextStyle.of(context).style;
    final effectiveNormalColor = normalTextColor ??
        effectiveTextStyle.color ??
        Theme.of(context).textTheme.bodyLarge?.color ??
        Colors.black;

    // If Tajweed colors are disabled or no markup, show plain text
    if (!showTajweedColors || textWithMarkup == null || textWithMarkup!.isEmpty) {
      final displayText = plainText ??
          (textWithMarkup != null ? TajweedService().stripMarkup(textWithMarkup!) : '');
      return Text(
        displayText,
        style: effectiveTextStyle.copyWith(color: effectiveNormalColor),
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // Parse the Tajweed markup
    final segments = TajweedService().parseMarkup(textWithMarkup);

    if (segments.isEmpty) {
      return Text(
        plainText ?? '',
        style: effectiveTextStyle.copyWith(color: effectiveNormalColor),
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // Build text spans for each segment
    final spans = <InlineSpan>[];
    final colors = customColors ?? TajweedColors.shohozQuran;

    for (final segment in segments) {
      final color = segment.rule == TajweedRule.normal
          ? effectiveNormalColor
          : colors.colorForRule(segment.rule);

      if (learningModeEnabled && segment.rule != TajweedRule.normal) {
        // Make Tajweed text tappable in learning mode
        spans.add(
          TextSpan(
            text: segment.text,
            style: effectiveTextStyle.copyWith(color: color),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onTajweedTap?.call(segment.rule, segment.text);
              },
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: segment.text,
            style: effectiveTextStyle.copyWith(color: color),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A widget that shows a legend of Tajweed color codes
class TajweedLegend extends StatelessWidget {
  /// Whether to show in compact mode (horizontal)
  final bool compact;

  /// Text style for legend labels
  final TextStyle? labelStyle;

  /// Which rules to show (defaults to all)
  final List<TajweedRule>? rulesToShow;

  const TajweedLegend({
    super.key,
    this.compact = false,
    this.labelStyle,
    this.rulesToShow,
  });

  @override
  Widget build(BuildContext context) {
    final rules = rulesToShow ??
        TajweedRule.values.where((r) => r != TajweedRule.normal).toList();

    if (compact) {
      return Wrap(
        spacing: 16,
        runSpacing: 8,
        children: rules.map((rule) => _buildLegendItem(context, rule)).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: rules.map((rule) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _buildLegendItem(context, rule),
      )).toList(),
    );
  }

  Widget _buildLegendItem(BuildContext context, TajweedRule rule) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: rule.color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rule.englishName,
          style: labelStyle ?? defaultStyle,
        ),
      ],
    );
  }
}

/// A widget that displays detailed info about a Tajweed rule
class TajweedRuleInfo extends StatelessWidget {
  final TajweedRule rule;
  final bool showArabicName;
  final bool showBengali;

  const TajweedRuleInfo({
    super.key,
    required this.rule,
    this.showArabicName = true,
    this.showBengali = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with color and names
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: rule.color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.englishName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showArabicName)
                    Text(
                      rule.arabicName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: 'Amiri',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // English description
        Text(
          rule.description,
          style: theme.textTheme.bodyMedium,
        ),

        // Bengali description
        if (showBengali) ...[
          const SizedBox(height: 8),
          Text(
            rule.bengaliDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'NotoSansBengali',
            ),
          ),
        ],
      ],
    );
  }
}

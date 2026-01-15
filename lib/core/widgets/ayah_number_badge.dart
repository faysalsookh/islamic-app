import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Beautiful ayah number badge widget
class AyahNumberBadge extends StatelessWidget {
  final int number;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const AyahNumberBadge({
    super.key,
    required this.number,
    this.size = 32,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ??
            (isDark
                ? AppColors.darkCard
                : AppColors.forestGreen.withValues(alpha: 0.1)),
        border: Border.all(
          color: isDark
              ? AppColors.softRose.withValues(alpha: 0.3)
              : AppColors.forestGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          _toArabicNumber(number),
          style: AppTypography.ayahNumber(
            color: textColor ??
                (isDark ? AppColors.softRose : AppColors.forestGreen),
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  /// Convert to Arabic-Indic numerals
  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicDigits[int.parse(digit)])
        .join();
  }
}

/// Decorative ayah separator
class AyahSeparator extends StatelessWidget {
  final double width;
  final Color? color;

  const AyahSeparator({
    super.key,
    this.width = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final separatorColor = color ??
        (isDark
            ? AppColors.softRose.withValues(alpha: 0.3)
            : AppColors.forestGreen.withValues(alpha: 0.3));

    return SizedBox(
      width: width,
      height: 20,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: separatorColor,
              ),
            ),
            Container(
              width: width - 20,
              height: 1,
              color: separatorColor,
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: separatorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bismillah header widget
class BismillahHeader extends StatelessWidget {
  final double fontSize;

  const BismillahHeader({
    super.key,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: AppTypography.quranText(
          fontSize: fontSize,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textArabic,
        ),
      ),
    );
  }
}

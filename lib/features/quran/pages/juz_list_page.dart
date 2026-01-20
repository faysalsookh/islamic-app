import 'package:flutter/material.dart';
import '../../../core/models/juz.dart';
import '../../../core/models/surah.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/elegant_card.dart';
import '../../../core/utils/responsive.dart';

/// Page displaying all 30 Juz of the Quran
class JuzListPage extends StatelessWidget {
  const JuzListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Browse by Juz',
          style: AppTypography.heading2(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : double.infinity,
          ),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isTablet ? 16 : 8),
            itemCount: JuzData.allJuz.length,
            itemBuilder: (context, index) {
              final juz = JuzData.allJuz[index];
              return Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                child: _JuzListTile(juz: juz, isTablet: isTablet),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _JuzListTile extends StatelessWidget {
  final Juz juz;
  final bool isTablet;

  const _JuzListTile({required this.juz, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get start and end surah names
    final startSurah = SurahData.surahs.firstWhere(
      (s) => s.number == juz.startSurah,
      orElse: () => SurahData.surahs.first,
    );
    final endSurah = SurahData.surahs.firstWhere(
      (s) => s.number == juz.endSurah,
      orElse: () => SurahData.surahs.first,
    );

    // Responsive sizes
    final badgeSize = isTablet ? 64.0 : 56.0;
    final juzLabelFontSize = isTablet ? 12.0 : 10.0;
    final juzNumberFontSize = isTablet ? 24.0 : 20.0;
    final arabicNameFontSize = isTablet ? 18.0 : 16.0;

    return ElegantCard(
      onTap: () {
        // Navigate to Quran reader at the start of this Juz
        Navigator.pushNamed(
          context,
          '/quran-reader',
          arguments: juz.startSurah,
        );
      },
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Row(
        children: [
          // Juz number badge
          Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'جزء',
                  style: TextStyle(
                    fontSize: juzLabelFontSize,
                    fontFamily: 'Amiri',
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  _toArabicNumber(juz.number),
                  style: TextStyle(
                    fontSize: juzNumberFontSize,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),

          // Juz info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Juz ${juz.number}',
                      style: AppTypography.heading3(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Text(
                      juz.nameArabic,
                      style: TextStyle(
                        fontSize: arabicNameFontSize,
                        fontFamily: 'Amiri',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  juz.nameTransliteration,
                  style: AppTypography.bodyMedium(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                // Range info
                Row(
                  children: [
                    _buildRangeChip(
                      context,
                      isDark,
                      'Start',
                      '${startSurah.nameTransliteration} ${juz.startAyah}',
                      isTablet,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: isTablet ? 16 : 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    _buildRangeChip(
                      context,
                      isDark,
                      'End',
                      '${endSurah.nameTransliteration} ${juz.endAyah}',
                      isTablet,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arrow icon
          Icon(
            Icons.chevron_right_rounded,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textTertiary,
            size: isTablet ? 28 : 24,
          ),
        ],
      ),
    );
  }

  Widget _buildRangeChip(
    BuildContext context,
    bool isDark,
    String label,
    String value,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 8,
        vertical: isTablet ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 10 : 9,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) => arabicDigits[int.parse(d)]).join();
  }
}

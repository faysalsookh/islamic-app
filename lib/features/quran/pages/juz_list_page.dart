import 'package:flutter/material.dart';
import '../../../core/models/juz.dart';
import '../../../core/models/surah.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/elegant_card.dart';

/// Page displaying all 30 Juz of the Quran
class JuzListPage extends StatelessWidget {
  const JuzListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: JuzData.allJuz.length,
        itemBuilder: (context, index) {
          final juz = JuzData.allJuz[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _JuzListTile(juz: juz),
          );
        },
      ),
    );
  }
}

class _JuzListTile extends StatelessWidget {
  final Juz juz;

  const _JuzListTile({required this.juz});

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

    return ElegantCard(
      onTap: () {
        // Navigate to Quran reader at the start of this Juz
        Navigator.pushNamed(
          context,
          '/quran-reader',
          arguments: juz.startSurah,
        );
      },
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Row(
        children: [
          // Juz number badge
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'جزء',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Amiri',
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  _toArabicNumber(juz.number),
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

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
                    const SizedBox(width: 8),
                    Text(
                      juz.nameArabic,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Amiri',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  juz.nameTransliteration,
                  style: AppTypography.bodyMedium(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Range info
                Row(
                  children: [
                    _buildRangeChip(
                      context,
                      isDark,
                      'Start',
                      '${startSurah.nameTransliteration} ${juz.startAyah}',
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    _buildRangeChip(
                      context,
                      isDark,
                      'End',
                      '${endSurah.nameTransliteration} ${juz.endAyah}',
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
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
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
              fontSize: 11,
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

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/elegant_card.dart';

/// App bar for Quran reading screen
class QuranAppBar extends StatelessWidget {
  final String surahNameEnglish;
  final String surahNameArabic;
  final int surahNumber;
  final int juzNumber;
  final VoidCallback onBackPressed;
  final VoidCallback onMenuPressed;

  const QuranAppBar({
    super.key,
    required this.surahNameEnglish,
    required this.surahNameArabic,
    required this.surahNumber,
    required this.juzNumber,
    required this.onBackPressed,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.cream,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back_rounded),
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),

          // Title
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surahNameEnglish,
                  style: AppTypography.heading3(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Juz $juzNumber • Surah $surahNumber',
                  style: AppTypography.caption(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Menu button
          IconButton(
            onPressed: onMenuPressed,
            icon: const Icon(Icons.more_vert_rounded),
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

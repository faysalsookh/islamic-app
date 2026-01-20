import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Surah list preview section on home page
class SurahListSection extends StatelessWidget {
  final double horizontalPadding;

  const SurahListSection({super.key, this.horizontalPadding = 16});

  @override
  Widget build(BuildContext context) {
    final previewSurahs = SurahData.surahs.take(5).toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final surah = previewSurahs[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
            child: SurahListTile(surah: surah),
          );
        },
        childCount: previewSurahs.length,
      ),
    );
  }
}

/// Individual surah list tile
class SurahListTile extends StatelessWidget {
  final Surah surah;

  const SurahListTile({
    super.key,
    required this.surah,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ElegantCard(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/quran-reader',
          arguments: surah.number,
        );
      },
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      child: Row(
        children: [
          // Surah number badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                surah.number.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Surah info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  surah.nameTransliteration,
                  style: AppTypography.heading3(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      surah.revelationType,
                      style: AppTypography.bodySmall(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      '${surah.ayahCount} verses',
                      style: AppTypography.bodySmall(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arabic name
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                surah.nameArabic,
                textDirection: TextDirection.rtl,
                style: AppTypography.surahNameArabic(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

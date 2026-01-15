import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/surah.dart';

/// Custom app bar for the Quran reader screen
class QuranAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Surah surah;
  final int currentJuz;
  final VoidCallback? onMorePressed;

  const QuranAppBar({
    super.key,
    required this.surah,
    required this.currentJuz,
    this.onMorePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.darkBackground : theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          // Surah name in Arabic
          Text(
            surah.nameArabic,
            textDirection: TextDirection.rtl,
            style: AppTypography.surahNameArabic(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          // Surah info
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                surah.nameTransliteration,
                style: AppTypography.bodySmall(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textTertiary,
                ),
              ),
              Text(
                'Juz $currentJuz',
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
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: onMorePressed,
        ),
      ],
    );
  }
}

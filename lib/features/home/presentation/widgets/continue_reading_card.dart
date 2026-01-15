import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Card showing the user's last reading position with progress
class ContinueReadingCard extends StatelessWidget {
  const ContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final progress = appState.readingProgress;

        return GradientCard(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkCard,
                    AppColors.darkSurface,
                  ],
                )
              : AppColors.headerGradient,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/quran-reader',
              arguments: progress.lastSurahNumber,
            );
          },
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_filled_rounded,
                        color: isDark
                            ? AppColors.softRose
                            : AppColors.textOnDark,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Continue Reading',
                        style: AppTypography.heading3(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textOnDark,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textOnDark.withValues(alpha: 0.7),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Surah name in Arabic
              Text(
                progress.lastSurahNameArabic,
                textDirection: TextDirection.rtl,
                style: AppTypography.surahNameArabic(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textOnDark,
                  fontSize: 28,
                ),
              ),

              // Surah name in English and Ayah
              Row(
                children: [
                  Text(
                    progress.lastSurahNameEnglish,
                    style: AppTypography.bodyMedium(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textOnDark.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    ' • ',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textOnDark.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'Ayah ${progress.lastAyahNumber}',
                    style: AppTypography.bodyMedium(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textOnDark.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progress.progressPercentage.toStringAsFixed(1)}% completed',
                        style: AppTypography.bodySmall(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textOnDark.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '${progress.totalAyahsRead}/6236 verses',
                        style: AppTypography.bodySmall(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textOnDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.progressPercentage / 100,
                      backgroundColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.textOnDark.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.softRose : AppColors.softRose,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

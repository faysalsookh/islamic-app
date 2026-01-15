import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/models/ayah.dart';
import '../../../../core/widgets/ayah_number_badge.dart';

/// Ayah list view - each ayah in a separate block for easier reading
class AyahListView extends StatelessWidget {
  final List<Ayah> ayahs;
  final Surah surah;
  final bool showTranslation;
  final int currentAyahIndex;
  final Function(int) onAyahTap;

  const AyahListView({
    super.key,
    required this.ayahs,
    required this.surah,
    required this.showTranslation,
    required this.currentAyahIndex,
    required this.onAyahTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: ayahs.length + 1, // +1 for Bismillah header
          itemBuilder: (context, index) {
            // Bismillah header (except for Surah At-Tawbah which is 9)
            if (index == 0) {
              if (surah.number != 9 && surah.number != 1) {
                return const BismillahHeader();
              }
              // For Al-Fatihah, show as first ayah
              if (surah.number == 1) {
                return const SizedBox.shrink();
              }
              return const SizedBox.shrink();
            }

            final ayahIndex = index - 1;
            final ayah = ayahs[ayahIndex];
            final isCurrentAyah = ayahIndex == currentAyahIndex;
            final isPlayingAyah = appState.currentPlayingAyah == ayah.number;

            return GestureDetector(
              onTap: () => onAyahTap(ayahIndex),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrentAyah
                      ? (isDark
                          ? AppColors.highlightAyahDark
                          : AppColors.highlightAyah)
                      : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: isPlayingAyah
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black12
                          : AppColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ayah number row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AyahNumberBadge(number: ayah.numberInSurah),
                        Row(
                          children: [
                            if (isPlayingAyah)
                              Icon(
                                Icons.volume_up_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.more_horiz_rounded,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textTertiary,
                              ),
                              onPressed: () {
                                // TODO: Show ayah options
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Arabic text
                    Text(
                      ayah.textArabic,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: _getArabicTextStyle(appState, isDark),
                    ),

                    // Translation
                    if (showTranslation &&
                        appState.translationLanguage !=
                            TranslationLanguage.none) ...[
                      const SizedBox(height: 16),
                      Divider(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.divider,
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      _buildTranslation(ayah, appState, isDark),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  TextStyle _getArabicTextStyle(AppStateProvider appState, bool isDark) {
    final color = isDark ? AppColors.darkTextPrimary : AppColors.textArabic;

    switch (appState.arabicFontStyle) {
      case ArabicFontStyle.amiri:
        return AppTypography.quranText(
          fontSize: appState.quranFontSize,
          height: appState.quranLineHeight,
          color: color,
        );
      case ArabicFontStyle.scheherazade:
        return AppTypography.quranTextTraditional(
          fontSize: appState.quranFontSize,
          height: appState.quranLineHeight,
          color: color,
        );
      case ArabicFontStyle.lateef:
        return AppTypography.quranTextModern(
          fontSize: appState.quranFontSize,
          height: appState.quranLineHeight,
          color: color,
        );
    }
  }

  Widget _buildTranslation(
      Ayah ayah, AppStateProvider appState, bool isDark) {
    final translations = <Widget>[];

    if (appState.translationLanguage == TranslationLanguage.english ||
        appState.translationLanguage == TranslationLanguage.both) {
      if (ayah.translationEnglish != null) {
        translations.add(
          Text(
            ayah.translationEnglish!,
            style: AppTypography.translationText(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTranslation,
            ),
          ),
        );
      }
    }

    if (appState.translationLanguage == TranslationLanguage.bengali ||
        appState.translationLanguage == TranslationLanguage.both) {
      if (ayah.translationBengali != null) {
        if (translations.isNotEmpty) {
          translations.add(const SizedBox(height: 8));
        }
        translations.add(
          Text(
            ayah.translationBengali!,
            style: AppTypography.translationText(
              color: isDark
                  ? AppColors.darkTextSecondary.withValues(alpha: 0.8)
                  : AppColors.textTranslation.withValues(alpha: 0.8),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: translations,
    );
  }
}

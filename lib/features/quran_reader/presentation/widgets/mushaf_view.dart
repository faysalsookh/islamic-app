import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/models/ayah.dart';
import '../../../../core/widgets/ayah_number_badge.dart';

/// Mushaf view - page-style like printed Quran
class MushafView extends StatelessWidget {
  final List<Ayah> ayahs;
  final bool showTranslation;
  final int currentAyahIndex;
  final Function(int) onAyahTap;

  const MushafView({
    super.key,
    required this.ayahs,
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
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.cream,
            border: Border.all(
              color: isDark
                  ? AppColors.dividerDark
                  : AppColors.warmBeigeDark,
              width: 1,
            ),
          ),
          margin: const EdgeInsets.all(8),
          child: Stack(
            children: [
              // Decorative corner elements
              Positioned(
                top: 0,
                left: 0,
                child: _buildCornerDecoration(isDark),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Transform.flip(
                  flipX: true,
                  child: _buildCornerDecoration(isDark),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Transform.flip(
                  flipY: true,
                  child: _buildCornerDecoration(isDark),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Transform.flip(
                  flipX: true,
                  flipY: true,
                  child: _buildCornerDecoration(isDark),
                ),
              ),

              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Page number indicator
                    if (ayahs.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Page ${ayahs.first.page}',
                          style: AppTypography.caption(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),

                    // Quran text in continuous flow
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 0,
                        runSpacing: appState.quranLineHeight * 8,
                        children: ayahs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final ayah = entry.value;
                          final isCurrentAyah = index == currentAyahIndex;
                          final isPlayingAyah =
                              appState.currentPlayingAyah == ayah.number;

                          return GestureDetector(
                            onTap: () => onAyahTap(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentAyah
                                    ? (isDark
                                        ? AppColors.highlightAyahDark
                                        : AppColors.highlightAyah)
                                    : (isPlayingAyah
                                        ? theme.colorScheme.primary
                                            .withValues(alpha: 0.15)
                                        : null),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: RichText(
                                textDirection: TextDirection.rtl,
                                text: TextSpan(
                                  children: [
                                    // Ayah text
                                    TextSpan(
                                      text: ayah.textArabic,
                                      style: _getArabicTextStyle(
                                        appState,
                                        isDark,
                                      ),
                                    ),
                                    // Ayah number marker (inline)
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: _AyahNumberMarker(
                                          number: ayah.numberInSurah,
                                          color: isDark
                                              ? AppColors.softRose
                                              : AppColors.forestGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Translation section (if enabled)
                    if (showTranslation &&
                        appState.translationLanguage !=
                            TranslationLanguage.none) ...[
                      const SizedBox(height: 32),
                      Divider(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.warmBeigeDark,
                      ),
                      const SizedBox(height: 16),
                      ...ayahs.map((ayah) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${ayah.numberInSurah}. ',
                                  style: AppTypography.bodyMedium(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Expanded(
                                  child: _buildTranslation(
                                      ayah, appState, isDark),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCornerDecoration(bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.softRose.withValues(alpha: 0.3)
                : AppColors.forestGreen.withValues(alpha: 0.3),
            width: 2,
          ),
          right: BorderSide(
            color: isDark
                ? AppColors.softRose.withValues(alpha: 0.3)
                : AppColors.forestGreen.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
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
          translations.add(const SizedBox(height: 4));
        }
        translations.add(
          Text(
            ayah.translationBengali!,
            style: AppTypography.translationText(
              fontSize: 14,
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

/// Inline ayah number marker for Mushaf view
class _AyahNumberMarker extends StatelessWidget {
  final int number;
  final Color color;

  const _AyahNumberMarker({
    required this.number,
    required this.color,
  });

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) => arabicDigits[int.parse(digit)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        _toArabicNumber(number),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

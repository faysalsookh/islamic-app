import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';

/// Bottom sheet for adjusting font size and reading settings
class FontSettingsSheet extends StatelessWidget {
  const FontSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.2)
                    : AppColors.textTertiary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quran Appearance',
                style: AppTypography.heading2(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Customize',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Premium Live Preview Card
          _buildLivePreview(context, theme, isDark),
          const SizedBox(height: 32),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Font Style Section
                   _buildSectionTitle('Arabic Font Style', isDark),
                   const SizedBox(height: 16),
                   _buildFontSelector(context, theme, isDark),
                   
                   const SizedBox(height: 32),

                   // Font Size Section
                   _buildSectionTitle('Font Size', isDark),
                   const SizedBox(height: 16),
                   _buildFontSizeSlider(context, theme, isDark),

                   const SizedBox(height: 32),

                   // Toggles Section
                   _buildSectionTitle('View Options', isDark),
                   const SizedBox(height: 16),
                   _buildViewOptions(context, theme, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildLivePreview(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF222B32) 
                : const Color(0xFFFFFDF5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark 
                  ? AppColors.warning.withValues(alpha: 0.2) 
                  : AppColors.warning.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: AppTypography.quranText(
                  fontSize: appState.quranFontSize,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A1A),
                  fontFamily: appState.arabicFontStyle.fontFamily,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedOpacity(
                opacity: appState.showTranslation ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'In the name of Allah, the Most Gracious, the Most Merciful',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFontSelector(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ArabicFontStyle.values.map((style) {
            final isSelected = appState.arabicFontStyle == style;
            return GestureDetector(
              onTap: () => appState.setArabicFontStyle(style),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: (MediaQuery.of(context).size.width - 60) / 2,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? AppColors.darkSurface : AppColors.cream),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: isSelected ? 0 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    // Demo Text in the Real Font
                    Text(
                      'القرآن',
                      style: AppTypography.quranText(
                        fontSize: 22,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textArabic),
                        fontFamily: style.fontFamily,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Font Name
                    Text(
                      style.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.9)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFontSizeSlider(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.cream,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    thumbColor: theme.colorScheme.primary,
                    trackHeight: 4,
                 ),
                 child: Slider(
                   value: appState.quranFontSize,
                   min: QuranFontSizes.extraSmall,
                   max: QuranFontSizes.jumbo,
                   divisions: 11,
                   label: appState.quranFontSize.toInt().toString(),
                   onChanged: (value) => appState.setQuranFontSize(value),
                 ),
               ),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewOptions(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Column(
          children: [
            _buildSwitchTile(
              title: 'Show Translation',
              value: appState.showTranslation,
              onChanged: (val) => appState.toggleShowTranslation(),
              isDark: isDark,
              activeColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            _buildSwitchTile(
              title: 'Show Transliteration',
              value: appState.showTransliteration,
              onChanged: (val) => appState.toggleShowTransliteration(),
              isDark: isDark,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
    required Color activeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
      ),
      child: SwitchListTile.adaptive(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

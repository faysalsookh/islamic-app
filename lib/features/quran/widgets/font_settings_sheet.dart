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
    final screenWidth = MediaQuery.of(context).size.width;

    // Use a constrained width on tablets for a cleaner, dialog-like look
    final bool isTablet = screenWidth > 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 600 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(32),
              bottom: isTablet ? const Radius.circular(32) : Radius.zero,
            ),
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
              // Handle (only show on mobile or if draggable)
              if (!isTablet) ...[
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
              ] else
                const SizedBox(height: 32), // More spacing on tablet top

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
      ),
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
              // Dynamic Text based on chosen style
              Text(
                (appState.arabicFontStyle == ArabicFontStyle.indopak || 
                 appState.arabicFontStyle.fontFamily == 'Lateef') 
                    ? 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ' // IndoPak Script Bismillah (Note: Allah written with dagger alif, etc)
                    : 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', // Uthmani Script
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
        return LayoutBuilder(
          builder: (context, constraints) {
            // Determine column count based on available width
            final double width = constraints.maxWidth;
            int crossAxisCount = 2;
            if (width > 600) crossAxisCount = 4;
            else if (width > 400) crossAxisCount = 3;

            final double spacing = 12;
            final double itemWidth = (width - (spacing * (crossAxisCount - 1))) / crossAxisCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: ArabicFontStyle.values.map((style) {
                final isSelected = appState.arabicFontStyle == style;
                return GestureDetector(
                  onTap: () => appState.setArabicFontStyle(style),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: itemWidth,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                          textAlign: TextAlign.center,
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
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
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
            const SizedBox(height: 8),
            _buildFeatureTile(
              title: 'Word-by-Word Translation',
              subtitle: 'Tap any Arabic word for meaning & grammar',
              value: appState.wordByWordEnabled,
              onChanged: (val) => appState.toggleWordByWord(),
              isDark: isDark,
              theme: theme,
              icon: Icons.touch_app_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
    required ThemeData theme,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : (isDark ? AppColors.dividerDark : AppColors.divider),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : (isDark ? AppColors.darkCard : AppColors.cream),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: value
                ? theme.colorScheme.primary
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => onChanged(!value),
      ),
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

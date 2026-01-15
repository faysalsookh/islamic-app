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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                    : AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Appearance Settings',
            style: AppTypography.heading3(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  // Arabic Font Size
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         'Arabic Font Size',
                         style: AppTypography.bodyMedium(
                           color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                         ),
                       ),
                       Text(
                         appState.quranFontSize.toInt().toString(),
                         style: AppTypography.label(
                           color: theme.colorScheme.primary,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 8),
                   SliderTheme(
                     data: SliderTheme.of(context).copyWith(
                       trackHeight: 4,
                     ),
                     child: Slider(
                       value: appState.quranFontSize,
                       min: QuranFontSizes.extraSmall,
                       max: QuranFontSizes.jumbo,
                       divisions: 11, // Granular control
                       onChanged: (value) {
                         appState.setQuranFontSize(value);
                       },
                     ),
                   ),

                   const SizedBox(height: 24),

                   // Toggle Translation
                   SwitchListTile.adaptive(
                     title: Text(
                       'Show Translation',
                       style: AppTypography.bodyLarge(
                         color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                       ),
                     ),
                     value: appState.showTranslation,
                     onChanged: (value) {
                       appState.toggleShowTranslation();
                     },
                     activeColor: theme.colorScheme.primary,
                     contentPadding: EdgeInsets.zero,
                   ),
                 ],
              );
            },
          ),
        ],
      ),
    );
  }
}

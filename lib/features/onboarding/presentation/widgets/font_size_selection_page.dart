import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Font size selection page during onboarding
class FontSizeSelectionPage extends StatelessWidget {
  const FontSizeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Icon
              Icon(
                Icons.format_size_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Choose Font Size',
                textAlign: TextAlign.center,
                style: AppTypography.heading1(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Select a comfortable size for reading the Quran',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Preview card
              ElegantCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Preview',
                      style: AppTypography.label(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: AppTypography.quranText(
                        fontSize: appState.quranFontSize,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textArabic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Font size slider
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Small',
                        style: AppTypography.bodySmall(),
                      ),
                      Text(
                        'Large',
                        style: AppTypography.bodySmall(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 14,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24,
                      ),
                    ),
                    child: Slider(
                      value: appState.quranFontSize,
                      min: QuranFontSizes.extraSmall,
                      max: QuranFontSizes.jumbo,
                      divisions: 5,
                      onChanged: (value) {
                        appState.setQuranFontSize(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick select buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FontSizeButton(
                    label: 'S',
                    size: QuranFontSizes.small,
                    isSelected:
                        appState.quranFontSize == QuranFontSizes.small,
                    onTap: () =>
                        appState.setQuranFontSize(QuranFontSizes.small),
                  ),
                  _FontSizeButton(
                    label: 'M',
                    size: QuranFontSizes.medium,
                    isSelected:
                        appState.quranFontSize == QuranFontSizes.medium,
                    onTap: () =>
                        appState.setQuranFontSize(QuranFontSizes.medium),
                  ),
                  _FontSizeButton(
                    label: 'L',
                    size: QuranFontSizes.large,
                    isSelected:
                        appState.quranFontSize == QuranFontSizes.large,
                    onTap: () =>
                        appState.setQuranFontSize(QuranFontSizes.large),
                  ),
                  _FontSizeButton(
                    label: 'XL',
                    size: QuranFontSizes.extraLarge,
                    isSelected:
                        appState.quranFontSize == QuranFontSizes.extraLarge,
                    onTap: () =>
                        appState.setQuranFontSize(QuranFontSizes.extraLarge),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  final String label;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontSizeButton({
    required this.label,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

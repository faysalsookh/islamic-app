import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/providers/app_state_provider.dart';

/// Bottom sheet for font and reading settings
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
      child: SafeArea(
        child: Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Reading Settings',
                    style: AppTypography.heading2(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Font size section
                  _SectionTitle(
                    title: 'Font Size',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _FontSizeSlider(
                    value: appState.quranFontSize,
                    onChanged: appState.setQuranFontSize,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // Line spacing section
                  _SectionTitle(
                    title: 'Line Spacing',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _LineSpacingOptions(
                    currentValue: appState.quranLineHeight,
                    onChanged: appState.setQuranLineHeight,
                    isDark: isDark,
                    accentColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // Font style section
                  _SectionTitle(
                    title: 'Arabic Font Style',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _FontStyleOptions(
                    currentStyle: appState.arabicFontStyle,
                    onChanged: appState.setArabicFontStyle,
                    isDark: isDark,
                    accentColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // View mode toggle
                  _SectionTitle(
                    title: 'View Mode',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _ViewModeToggle(
                    isMushafView: appState.isMushafView,
                    onChanged: appState.setMushafView,
                    isDark: isDark,
                    accentColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // Translation toggle
                  _ToggleRow(
                    title: 'Show Translation',
                    value: appState.showTranslation,
                    onChanged: (_) => appState.toggleShowTranslation(),
                    isDark: isDark,
                    accentColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),

                  // Left-handed mode toggle
                  _ToggleRow(
                    title: 'Left-handed Mode',
                    subtitle: 'Swap control positions',
                    value: appState.isLeftHanded,
                    onChanged: appState.setLeftHanded,
                    isDark: isDark,
                    accentColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // Preview
                  _PreviewSection(
                    appState: appState,
                    isDark: isDark,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.label(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final bool isDark;

  const _FontSizeSlider({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aa',
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            Text(
              'Aa',
              style: TextStyle(
                fontSize: 24,
                color:
                    isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: QuranFontSizes.extraSmall,
          max: QuranFontSizes.jumbo,
          divisions: 5,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LineSpacingOptions extends StatelessWidget {
  final double currentValue;
  final Function(double) onChanged;
  final bool isDark;
  final Color accentColor;

  const _LineSpacingOptions({
    required this.currentValue,
    required this.onChanged,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SpacingOption(
          label: 'Compact',
          value: QuranLineHeights.compact,
          isSelected: currentValue == QuranLineHeights.compact,
          onTap: () => onChanged(QuranLineHeights.compact),
          isDark: isDark,
          accentColor: accentColor,
        ),
        const SizedBox(width: 8),
        _SpacingOption(
          label: 'Normal',
          value: QuranLineHeights.normal,
          isSelected: currentValue == QuranLineHeights.normal,
          onTap: () => onChanged(QuranLineHeights.normal),
          isDark: isDark,
          accentColor: accentColor,
        ),
        const SizedBox(width: 8),
        _SpacingOption(
          label: 'Comfortable',
          value: QuranLineHeights.comfortable,
          isSelected: currentValue == QuranLineHeights.comfortable,
          onTap: () => onChanged(QuranLineHeights.comfortable),
          isDark: isDark,
          accentColor: accentColor,
        ),
      ],
    );
  }
}

class _SpacingOption extends StatelessWidget {
  final String label;
  final double value;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color accentColor;

  const _SpacingOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.15)
                : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? accentColor
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FontStyleOptions extends StatelessWidget {
  final ArabicFontStyle currentStyle;
  final Function(ArabicFontStyle) onChanged;
  final bool isDark;
  final Color accentColor;

  const _FontStyleOptions({
    required this.currentStyle,
    required this.onChanged,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FontStyleOption(
          name: 'Amiri',
          sample: 'بِسْمِ اللَّهِ',
          style: ArabicFontStyle.amiri,
          isSelected: currentStyle == ArabicFontStyle.amiri,
          onTap: () => onChanged(ArabicFontStyle.amiri),
          isDark: isDark,
          accentColor: accentColor,
        ),
        const SizedBox(height: 8),
        _FontStyleOption(
          name: 'Scheherazade',
          sample: 'بِسْمِ اللَّهِ',
          style: ArabicFontStyle.scheherazade,
          isSelected: currentStyle == ArabicFontStyle.scheherazade,
          onTap: () => onChanged(ArabicFontStyle.scheherazade),
          isDark: isDark,
          accentColor: accentColor,
        ),
        const SizedBox(height: 8),
        _FontStyleOption(
          name: 'Lateef',
          sample: 'بِسْمِ اللَّهِ',
          style: ArabicFontStyle.lateef,
          isSelected: currentStyle == ArabicFontStyle.lateef,
          onTap: () => onChanged(ArabicFontStyle.lateef),
          isDark: isDark,
          accentColor: accentColor,
        ),
      ],
    );
  }
}

class _FontStyleOption extends StatelessWidget {
  final String name;
  final String sample;
  final ArabicFontStyle style;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color accentColor;

  const _FontStyleOption({
    required this.name,
    required this.sample,
    required this.style,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle sampleStyle;
    switch (style) {
      case ArabicFontStyle.amiri:
      case ArabicFontStyle.uthmani:
        sampleStyle = AppTypography.quranText(fontSize: 20);
        break;
      case ArabicFontStyle.scheherazade:
      case ArabicFontStyle.indopak:
        sampleStyle = AppTypography.quranTextTraditional(fontSize: 20);
        break;
      case ArabicFontStyle.lateef:
        sampleStyle = AppTypography.quranTextModern(fontSize: 20);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              sample,
              textDirection: TextDirection.rtl,
              style: sampleStyle.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textArabic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  final bool isMushafView;
  final Function(bool) onChanged;
  final bool isDark;
  final Color accentColor;

  const _ViewModeToggle({
    required this.isMushafView,
    required this.onChanged,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: !isMushafView
                    ? accentColor
                    : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.view_list_rounded,
                    size: 20,
                    color: !isMushafView
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ayah List',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: !isMushafView
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isMushafView
                    ? accentColor
                    : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 20,
                    color: isMushafView
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mushaf',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isMushafView
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final Function(bool) onChanged;
  final bool isDark;
  final Color accentColor;

  const _ToggleRow({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.bodyLarge(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: AppTypography.bodySmall(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
          ],
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: accentColor,
        ),
      ],
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final AppStateProvider appState;
  final bool isDark;

  const _PreviewSection({
    required this.appState,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle;
    switch (appState.arabicFontStyle) {
      case ArabicFontStyle.amiri:
      case ArabicFontStyle.uthmani:
        textStyle = AppTypography.quranText(
          fontSize: appState.quranFontSize,
          height: appState.quranLineHeight,
        );
        break;
      case ArabicFontStyle.scheherazade:
      case ArabicFontStyle.indopak:
        textStyle = AppTypography.quranTextTraditional(
          fontSize: appState.quranFontSize,
          height: appState.quranLineHeight,
        );
        break;
      case ArabicFontStyle.lateef:
        textStyle = AppTypography.quranTextModern(
          fontSize: appState.quranFontSize,
          height: appState.quranLineHeight,
        );
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.warmBeige,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Preview',
            style: AppTypography.label(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: textStyle.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textArabic,
            ),
          ),
        ],
      ),
    );
  }
}

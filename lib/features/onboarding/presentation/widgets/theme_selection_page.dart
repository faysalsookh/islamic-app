import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Theme selection page during onboarding
class ThemeSelectionPage extends StatelessWidget {
  const ThemeSelectionPage({super.key});

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
                Icons.palette_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Choose Your Theme',
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
                'Select a theme that feels comfortable for your eyes',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Theme options
              _ThemeOption(
                title: 'Light',
                subtitle: 'Clean and bright',
                isSelected: appState.themeMode == AppThemeMode.light,
                colors: [AppColors.cream, AppColors.forestGreen],
                onTap: () => appState.setThemeMode(AppThemeMode.light),
              ),
              const SizedBox(height: 12),
              _ThemeOption(
                title: 'Dark',
                subtitle: 'Easy on the eyes at night',
                isSelected: appState.themeMode == AppThemeMode.dark,
                colors: [AppColors.darkBackground, AppColors.softRose],
                onTap: () => appState.setThemeMode(AppThemeMode.dark),
              ),
              const SizedBox(height: 12),
              _ThemeOption(
                title: 'Rose Gold',
                subtitle: 'Elegant and warm',
                isSelected: appState.themeMode == AppThemeMode.roseGold,
                colors: [AppColors.roseGoldBackground, AppColors.roseGoldPrimary],
                onTap: () => appState.setThemeMode(AppThemeMode.roseGold),
              ),
              const SizedBox(height: 12),
              _ThemeOption(
                title: 'Olive & Cream',
                subtitle: 'Natural and calming',
                isSelected: appState.themeMode == AppThemeMode.oliveCream,
                colors: [AppColors.oliveCream, AppColors.oliveGreen],
                onTap: () => appState.setThemeMode(AppThemeMode.oliveCream),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElegantCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      border: isSelected
          ? Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            )
          : null,
      child: Row(
        children: [
          // Color preview
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.heading3(),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(),
                ),
              ],
            ),
          ),

          // Selection indicator
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
        ],
      ),
    );
  }
}

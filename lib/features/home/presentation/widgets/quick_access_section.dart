import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Horizontal scrolling section with quick access tiles
class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _QuickAccessCard(
        icon: Icons.list_alt_rounded,
        label: 'By Surah',
        subtitle: '114 Surahs',
        color: AppColors.forestGreen,
        onTap: () {
          Navigator.pushNamed(context, '/surah-list');
        },
      ),
      _QuickAccessCard(
        icon: Icons.layers_rounded,
        label: 'By Juz',
        subtitle: '30 Juz',
        color: AppColors.mutedTeal,
        onTap: () {
          Navigator.pushNamed(context, '/juz-list');
        },
      ),
      _QuickAccessCard(
        icon: Icons.school_rounded,
        label: 'তাজবীদ শিক্ষা',
        subtitle: 'Tajweed Rules',
        color: AppColors.softRose,
        onTap: () {
          Navigator.pushNamed(context, '/tajweed-rules');
        },
      ),
      _QuickAccessCard(
        icon: Icons.bookmark_rounded,
        label: 'Bookmarks',
        subtitle: 'Saved',
        color: AppColors.softRoseDark,
        onTap: () {
          Navigator.pushNamed(context, '/bookmarks');
        },
      ),
      _QuickAccessCard(
        icon: Icons.palette_rounded,
        label: 'Themes',
        subtitle: 'Customize',
        color: AppColors.oliveGreen,
        onTap: () {
          Navigator.pushNamed(context, '/settings');
        },
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: cards,
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 200,
        child: ElegantCard(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/elegant_card.dart';

/// Horizontal scrolling section with quick access tiles
class QuickAccessSection extends StatelessWidget {
  final bool isTablet;

  const QuickAccessSection({super.key, this.isTablet = false});

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
        icon: Icons.nightlight_round,
        label: 'Ramadan',
        subtitle: 'Calendar',
        color: AppColors.softRoseDark,
        onTap: () {
          Navigator.pushNamed(context, '/ramadan-calendar');
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
        icon: Icons.explore_rounded,
        label: 'Qibla',
        subtitle: 'Direction',
        color: AppColors.mutedTealDark,
        onTap: () {
          Navigator.pushNamed(context, '/qibla');
        },
      ),
      _QuickAccessCard(
        icon: Icons.radio_button_on_rounded,
        label: 'Tasbih',
        subtitle: 'Counter',
        color: AppColors.roseGoldPrimary,
        onTap: () {
          Navigator.pushNamed(context, '/tasbih');
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

    final cardWidth = isTablet ? 240.0 : 200.0;
    final sectionHeight = isTablet ? 120.0 : 100.0;
    final horizontalPadding = isTablet ? 28.0 : 12.0;

    return SizedBox(
      height: sectionHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return _QuickAccessCardWidget(
            card: card,
            cardWidth: cardWidth,
            isTablet: isTablet,
          );
        },
      ),
    );
  }
}

class _QuickAccessCard {
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
}

class _QuickAccessCardWidget extends StatelessWidget {
  final _QuickAccessCard card;
  final double cardWidth;
  final bool isTablet;

  const _QuickAccessCardWidget({
    required this.card,
    required this.cardWidth,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconSize = isTablet ? 56.0 : 48.0;
    final iconFontSize = isTablet ? 28.0 : 24.0;
    final labelFontSize = isTablet ? 18.0 : 16.0;
    final subtitleFontSize = isTablet ? 14.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
      child: SizedBox(
        width: cardWidth,
        child: ElegantCard(
          onTap: card.onTap,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 16 : 12,
          ),
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          child: Row(
            children: [
              // Icon container
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                ),
                child: Icon(
                  card.icon,
                  color: card.color,
                  size: iconFontSize,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              // Text - wrapped in Expanded to prevent overflow
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.label,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      card.subtitle,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

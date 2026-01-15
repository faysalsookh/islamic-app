import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom navigation bar for the Quran reader with audio controls
class ReadingBottomBar extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onBookmark;
  final VoidCallback onSettings;
  final bool isLeftHanded;

  const ReadingBottomBar({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onBookmark,
    required this.onSettings,
    this.isLeftHanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final leftActions = [
      _BottomBarButton(
        icon: Icons.bookmark_border_rounded,
        activeIcon: Icons.bookmark_rounded,
        label: 'Bookmark',
        onTap: onBookmark,
        isDark: isDark,
        accentColor: theme.colorScheme.primary,
      ),
      _BottomBarButton(
        icon: Icons.text_fields_rounded,
        label: 'Font',
        onTap: onSettings,
        isDark: isDark,
        accentColor: theme.colorScheme.primary,
      ),
    ];

    final rightActions = [
      _BottomBarButton(
        icon: Icons.skip_previous_rounded,
        label: 'Previous',
        onTap: onPrevious,
        isDark: isDark,
        accentColor: theme.colorScheme.primary,
      ),
      _BottomBarButton(
        icon: Icons.skip_next_rounded,
        label: 'Next',
        onTap: onNext,
        isDark: isDark,
        accentColor: theme.colorScheme.primary,
      ),
    ];

    // Swap sides for left-handed users
    final firstGroup = isLeftHanded ? rightActions : leftActions;
    final secondGroup = isLeftHanded ? leftActions : rightActions;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left/Right action group
              Row(children: firstGroup),

              // Center play/pause button
              _PlayPauseButton(
                isPlaying: isPlaying,
                onTap: onPlayPause,
                isDark: isDark,
                accentColor: theme.colorScheme.primary,
              ),

              // Right/Left action group
              Row(children: secondGroup),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Color accentColor;
  final bool isActive;

  const _BottomBarButton({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.accentColor,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? (activeIcon ?? icon) : icon,
              color: isActive
                  ? accentColor
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? accentColor
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final bool isDark;
  final Color accentColor;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.onTap,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accentColor,
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

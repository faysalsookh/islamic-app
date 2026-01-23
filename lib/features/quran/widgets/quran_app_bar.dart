import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Premium app bar for Quran reading screen with progress indicator
class QuranAppBar extends StatelessWidget {
  final String surahNameEnglish;
  final String surahNameArabic;
  final int surahNumber;
  final int juzNumber;
  final int currentAyah;
  final int totalAyahs;
  final VoidCallback onBackPressed;
  final VoidCallback onMenuPressed;
  final VoidCallback? onProgressTap;

  const QuranAppBar({
    super.key,
    required this.surahNameEnglish,
    required this.surahNameArabic,
    required this.surahNumber,
    required this.juzNumber,
    this.currentAyah = 1,
    this.totalAyahs = 1,
    required this.onBackPressed,
    required this.onMenuPressed,
    this.onProgressTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = totalAyahs > 0 ? currentAyah / totalAyahs : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.cardShadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main app bar content
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Row(
              children: [
                // Back button
                _buildIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: onBackPressed,
                  isDark: isDark,
                ),

                // Title section
                Expanded(
                  child: GestureDetector(
                    onTap: onProgressTap,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Arabic name
                        Text(
                          surahNameArabic,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // English name with info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              surahNameEnglish,
                              style: AppTypography.bodyMedium(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Metadata row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMetaChip(
                              'Surah $surahNumber',
                              Icons.menu_book_rounded,
                              isDark,
                              theme,
                            ),
                            const SizedBox(width: 8),
                            _buildMetaChip(
                              'Juz $juzNumber',
                              Icons.layers_rounded,
                              isDark,
                              theme,
                            ),
                            const SizedBox(width: 8),
                            _buildMetaChip(
                              '$currentAyah/$totalAyahs',
                              Icons.format_list_numbered_rounded,
                              isDark,
                              theme,
                              isHighlighted: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Menu button
                _buildIconButton(
                  icon: Icons.more_vert_rounded,
                  onTap: onMenuPressed,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Progress bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.cream,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard.withValues(alpha: 0.5)
                : AppColors.cream.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip(
    String text,
    IconData icon,
    bool isDark,
    ThemeData theme, {
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.darkCard : AppColors.cream),
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isHighlighted
                ? theme.colorScheme.primary
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
              color: isHighlighted
                  ? theme.colorScheme.primary
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated fractionally sized box for smooth progress bar
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    required this.widthFactor,
    required this.child,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}

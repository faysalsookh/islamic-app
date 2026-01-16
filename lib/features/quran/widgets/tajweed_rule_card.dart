import 'package:flutter/material.dart';
import '../../../core/models/tajweed_rules_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// A card widget displaying a single Tajweed rule with expandable details
class TajweedRuleCard extends StatefulWidget {
  final TajweedRuleDetail rule;
  final bool initiallyExpanded;

  const TajweedRuleCard({
    super.key,
    required this.rule,
    this.initiallyExpanded = false,
  });

  @override
  State<TajweedRuleCard> createState() => _TajweedRuleCardState();
}

class _TajweedRuleCardState extends State<TajweedRuleCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isDark ? 2 : 1,
      color: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.rule.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: _toggleExpanded,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Color indicator
                  Container(
                    width: 6,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.rule.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Rule names
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bengali name
                        Text(
                          widget.rule.nameBengali,
                          style: AppTypography.heading3(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Arabic name
                        Text(
                          widget.rule.nameArabic,
                          textDirection: TextDirection.rtl,
                          style: AppTypography.bodyLarge(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // English name
                        Text(
                          widget.rule.nameEnglish,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary.withOpacity(0.7)
                                : AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expand/collapse icon
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.rule.color,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Expandable content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(isDark),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Divider(
            color: widget.rule.color.withOpacity(0.3),
            thickness: 1,
          ),
          const SizedBox(height: 12),

          // Bengali description
          _buildSectionTitle('বিবরণ:', isDark),
          const SizedBox(height: 8),
          Text(
            widget.rule.descriptionBengali,
            style: AppTypography.bodyMedium(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // English description
          _buildSectionTitle('Description:', isDark),
          const SizedBox(height: 8),
          Text(
            widget.rule.descriptionEnglish,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary.withOpacity(0.8)
                  : AppColors.textSecondary.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          // Arabic letters
          if (widget.rule.arabicLetters.isNotEmpty) ...[
            _buildSectionTitle('হরফসমূহ (Letters):', isDark),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.rule.arabicLetters.map((letter) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.rule.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.rule.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    letter,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.rule.color,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Example
          if (widget.rule.exampleArabic.isNotEmpty) ...[
            _buildSectionTitle('উদাহরণ (Example):', isDark),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.rule.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                widget.rule.exampleArabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: AppTypography.quranText(
                  fontSize: 22,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textArabic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
    );
  }
}

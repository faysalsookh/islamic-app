import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/models/ayah.dart';
import '../../../../core/widgets/ayah_number_badge.dart';
import '../../../../core/widgets/elegant_card.dart';

/// List view of ayahs (verses)
class AyahListView extends StatefulWidget {
  final Surah surah;
  final List<Ayah> ayahs;
  final int currentAyahIndex;
  final bool showTranslation;
  final double quranFontSize;
  final ValueChanged<int> onAyahSelected;

  const AyahListView({
    super.key,
    required this.surah,
    required this.ayahs,
    required this.currentAyahIndex,
    required this.showTranslation,
    required this.quranFontSize,
    required this.onAyahSelected,
  });

  @override
  State<AyahListView> createState() => _AyahListViewState();
}

class _AyahListViewState extends State<AyahListView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void didUpdateWidget(AyahListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAyahIndex != oldWidget.currentAyahIndex) {
      _scrollToIndex(widget.currentAyahIndex);
    }
  }

  void _scrollToIndex(int index) {
    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.1, // Scroll to top-ish
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScrollablePositionedList.builder(
      itemCount: widget.ayahs.length + 1, // +1 for Bismillah/Header
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (context, index) {
        if (index == 0) {
          return BismillahHeader(fontSize: widget.quranFontSize);
        }

        final ayahIndex = index - 1;
        final ayah = widget.ayahs[ayahIndex];
        final isSelected = ayahIndex == widget.currentAyahIndex;

        return _AyahItem(
          ayah: ayah,
          isSelected: isSelected,
          showTranslation: widget.showTranslation,
          fontSize: widget.quranFontSize,
          onTap: () => widget.onAyahSelected(ayahIndex),
        );
      },
    );
  }
}

class _AyahItem extends StatelessWidget {
  final Ayah ayah;
  final bool isSelected;
  final bool showTranslation;
  final double fontSize;
  final VoidCallback onTap;

  const _AyahItem({
    required this.ayah,
    required this.isSelected,
    required this.showTranslation,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isSelected
        ? (isDark
            ? AppColors.softRose.withValues(alpha: 0.1)
            : AppColors.highlightAyah)
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Top row with number and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AyahNumberBadge(
                  number: ayah.numberInSurah,
                  size: 28,
                  backgroundColor: isSelected
                      ? (isDark ? AppColors.softRose : AppColors.forestGreen)
                      : null,
                  textColor: isSelected
                      ? (isDark ? AppColors.darkBackground : Colors.white)
                      : null,
                ),
                if (isSelected)
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Arabic Text
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                ayah.textArabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: AppTypography.quranText(
                  fontSize: fontSize,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textArabic,
                ),
              ),
            ),

            if (showTranslation) ...[
              const SizedBox(height: 16),
              // Translation Text
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ayah.translationEnglish ?? '',
                  style: AppTypography.translationText(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTranslation,
                    fontSize: fontSize * 0.55, // Responsive translation size
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 8),
            Divider(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
              thickness: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}

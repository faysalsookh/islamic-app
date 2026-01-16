import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/models/surah.dart';
import '../../../core/models/ayah.dart';
import '../../../core/models/tajweed.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/widgets/ayah_number_badge.dart';
import '../../../core/widgets/tajweed_text.dart';
import '../../../core/widgets/tajweed_tooltip.dart';
import '../../../core/services/audio_service.dart';
import 'tafsir_bottom_sheet.dart';

/// List view of ayahs (verses) with Tajweed support
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
  final AudioService _audioService = AudioService();

  @override
  void didUpdateWidget(AyahListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAyahIndex != oldWidget.currentAyahIndex) {
      _scrollToIndex(widget.currentAyahIndex);
    }
  }

  void _scrollToIndex(int index) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return ListenableBuilder(
          listenable: _audioService,
          builder: (context, child) {
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
                final isPlaying = _audioService.isAyahPlaying(
                  widget.surah.number,
                  ayah.numberInSurah,
                );

                return _AyahItem(
                  ayah: ayah,
                  surah: widget.surah,
                  isSelected: isSelected,
                  isPlaying: isPlaying,
                  showTranslation: appState.showTranslation,
                  showTransliteration: appState.showTransliteration,
                  showTajweedColors: appState.showTajweedColors,
                  tajweedLearningMode: appState.tajweedLearningMode,
                  translationLanguage: appState.translationLanguage,
                  transliterationLanguage: appState.transliterationLanguage,
                  fontSize: widget.quranFontSize,
                  isBookmarked: appState.isAyahBookmarked(
                    widget.surah.number,
                    ayah.numberInSurah,
                  ),
                  onTap: () => widget.onAyahSelected(ayahIndex),
                  onPlayTap: () => _handlePlayTap(ayah),
                  onBookmarkTap: () => _handleBookmarkTap(context, ayah),
                  onTafsirTap: () => _handleTafsirTap(context, ayah),
                  onTajweedTap: (rule, text) =>
                      _handleTajweedTap(context, rule, text),
                );
              },
            );
          },
        );
      },
    );
  }

  void _handlePlayTap(Ayah ayah) {
    if (_audioService.isAyahPlaying(widget.surah.number, ayah.numberInSurah)) {
      _audioService.pause();
    } else {
      _audioService.playAyah(widget.surah.number, ayah.numberInSurah);
    }
  }

  void _handleBookmarkTap(BuildContext context, Ayah ayah) {
    final appState = context.read<AppStateProvider>();
    // Toggle bookmark logic would go here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appState.isAyahBookmarked(widget.surah.number, ayah.numberInSurah)
              ? 'Bookmark removed'
              : 'Bookmark added',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleTafsirTap(BuildContext context, Ayah ayah) {
    TafsirBottomSheet.show(
      context,
      ayah: ayah,
      surah: widget.surah,
    );
  }

  void _handleTajweedTap(BuildContext context, TajweedRule rule, String text) {
    TajweedTooltip.show(
      context,
      rule: rule,
      tappedText: text,
    );
  }
}

class _AyahItem extends StatelessWidget {
  final Ayah ayah;
  final Surah surah;
  final bool isSelected;
  final bool isPlaying;
  final bool showTranslation;
  final bool showTransliteration;
  final bool showTajweedColors;
  final bool tajweedLearningMode;
  final TranslationLanguage translationLanguage;
  final TransliterationLanguage transliterationLanguage;
  final double fontSize;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTafsirTap;
  final void Function(TajweedRule rule, String text) onTajweedTap;

  const _AyahItem({
    required this.ayah,
    required this.surah,
    required this.isSelected,
    required this.isPlaying,
    required this.showTranslation,
    required this.showTransliteration,
    required this.showTajweedColors,
    required this.tajweedLearningMode,
    required this.translationLanguage,
    required this.transliterationLanguage,
    required this.fontSize,
    required this.isBookmarked,
    required this.onTap,
    required this.onPlayTap,
    required this.onBookmarkTap,
    required this.onTafsirTap,
    required this.onTajweedTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isPlaying
        ? (isDark
            ? AppColors.mutedTeal.withValues(alpha: 0.15)
            : AppColors.mutedTeal.withValues(alpha: 0.1))
        : isSelected
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top row with number and actions
            _buildTopRow(context, isDark, theme),
            const SizedBox(height: 16),

            // Arabic Text with Tajweed
            _buildArabicText(isDark),

            // Transliteration (if enabled)
            if (showTransliteration) ...[
              const SizedBox(height: 12),
              _buildTransliteration(isDark),
            ],

            // Translation (if enabled)
            if (showTranslation) ...[
              const SizedBox(height: 12),
              _buildTranslation(isDark),
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

  Widget _buildTopRow(BuildContext context, bool isDark, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AyahNumberBadge(
          number: ayah.numberInSurah,
          size: 28,
          backgroundColor: isPlaying
              ? AppColors.mutedTeal
              : isSelected
                  ? (isDark ? AppColors.softRose : AppColors.forestGreen)
                  : null,
          textColor: (isSelected || isPlaying)
              ? (isDark ? AppColors.darkBackground : Colors.white)
              : null,
        ),
        Row(
          children: [
            // Play button
            IconButton(
              onPressed: onPlayTap,
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_outline_rounded,
                size: 24,
                color: isPlaying
                    ? AppColors.mutedTeal
                    : (isSelected
                        ? theme.colorScheme.primary
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary)),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),

            // Bookmark button
            IconButton(
              onPressed: onBookmarkTap,
              icon: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                size: 22,
                color: isBookmarked
                    ? AppColors.softRoseDark
                    : (isSelected
                        ? theme.colorScheme.primary
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary)),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),

            // Tafsir button
            IconButton(
              onPressed: onTafsirTap,
              icon: Icon(
                Icons.menu_book_rounded,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArabicText(bool isDark) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textArabic;

    return Align(
      alignment: Alignment.centerRight,
      child: TajweedText(
        textWithMarkup: ayah.textWithTajweed,
        plainText: ayah.textArabic,
        showTajweedColors: showTajweedColors,
        learningModeEnabled: tajweedLearningMode,
        onTajweedTap: onTajweedTap,
        textStyle: AppTypography.quranText(
          fontSize: fontSize,
          color: textColor,
        ),
        normalTextColor: textColor,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildTransliteration(bool isDark) {
    String? transliteration;

    switch (transliterationLanguage) {
      case TransliterationLanguage.english:
        transliteration = ayah.transliterationEnglish;
        break;
      case TransliterationLanguage.bengali:
        transliteration = ayah.transliterationBengali;
        break;
      case TransliterationLanguage.both:
        final parts = <String>[];
        if (ayah.transliterationEnglish != null) {
          parts.add(ayah.transliterationEnglish!);
        }
        if (ayah.transliterationBengali != null) {
          parts.add(ayah.transliterationBengali!);
        }
        transliteration = parts.isNotEmpty ? parts.join('\n') : null;
        break;
      case TransliterationLanguage.none:
        return const SizedBox.shrink();
    }

    if (transliteration == null || transliteration.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        transliteration,
        style: TextStyle(
          fontSize: fontSize * 0.5,
          fontStyle: FontStyle.italic,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTranslation(bool isDark) {
    String? translation;

    switch (translationLanguage) {
      case TranslationLanguage.english:
        translation = ayah.translationEnglish;
        break;
      case TranslationLanguage.bengali:
        translation = ayah.translationBengali;
        break;
      case TranslationLanguage.both:
        final parts = <String>[];
        if (ayah.translationEnglish != null) {
          parts.add(ayah.translationEnglish!);
        }
        if (ayah.translationBengali != null) {
          parts.add(ayah.translationBengali!);
        }
        translation = parts.isNotEmpty ? parts.join('\n\n') : null;
        break;
      case TranslationLanguage.none:
        return const SizedBox.shrink();
    }

    if (translation == null || translation.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        translation,
        style: AppTypography.translationText(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textTranslation,
          fontSize: fontSize * 0.55,
        ),
      ),
    );
  }
}

/// Bismillah header shown at the top of each surah
class BismillahHeader extends StatelessWidget {
  final double fontSize;

  const BismillahHeader({
    super.key,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          // Decorative line
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bismillah text
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textDirection: TextDirection.rtl,
            style: AppTypography.quranText(
              fontSize: fontSize * 0.9,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textArabic,
            ),
          ),

          const SizedBox(height: 8),

          // Translation
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Decorative line
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

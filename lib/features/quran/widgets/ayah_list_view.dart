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

/// Compact Tajweed color legend that shows at bottom of screen
/// Matches the Bengali Quran color coding style shown in the image
class TajweedColorLegend extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const TajweedColorLegend({
    super.key,
    this.isExpanded = false,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tajweed rules with their colors and Bengali names (matching the image)
    final tajweedRules = [
      (TajweedRule.ghunnah, 'গুন্নাহ'),
      (TajweedRule.ikhfa, 'ইখফা'),
      (TajweedRule.qalqalah, 'কলকলা'),
      (TajweedRule.idgham, 'ইদগাম'),
      (TajweedRule.iqlab, 'ইকলাব'),
      (TajweedRule.izhar, 'ইজহার'),
      (TajweedRule.safir, 'ছফিরহ'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
              : AppColors.divider,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with toggle
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.palette_rounded,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'তাজবীদ রং / Tajweed Colors',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Color legend - always visible in compact form
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: tajweedRules.map((rule) {
                return _ColorChip(
                  color: rule.$1.color,
                  label: rule.$2,
                  isDark: isDark,
                  isExpanded: isExpanded,
                  onTap: isExpanded
                      ? () => _showRuleDetail(context, rule.$1)
                      : null,
                );
              }).toList(),
            ),
          ),

          // Expanded details
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'রং এর অর্থ বুঝতে ট্যাপ করুন',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap any color to learn more about that Tajweed rule',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRuleDetail(BuildContext context, TajweedRule rule) {
    TajweedTooltip.show(context, rule: rule, tappedText: '');
  }
}

/// Individual color chip in the legend
class _ColorChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;
  final bool isExpanded;
  final VoidCallback? onTap;

  const _ColorChip({
    required this.color,
    required this.label,
    required this.isDark,
    required this.isExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 10 : 8,
          vertical: isExpanded ? 6 : 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.2 : 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isExpanded ? 14 : 10,
              height: isExpanded ? 14 : 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 3,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isExpanded ? 12 : 10,
                fontWeight: FontWeight.w500,
                fontFamily: 'NotoSansBengali',
                color: isDark ? Colors.white : color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List view of ayahs (verses) with Tajweed support
class AyahListView extends StatefulWidget {
  final Surah surah;
  final List<Ayah> ayahs;
  final int currentAyahIndex;
  final bool showTranslation;
  final double quranFontSize;
  final ValueChanged<int> onAyahSelected;
  final int? initialScrollIndex;

  const AyahListView({
    super.key,
    required this.surah,
    required this.ayahs,
    required this.currentAyahIndex,
    required this.showTranslation,
    required this.quranFontSize,
    required this.onAyahSelected,
    this.initialScrollIndex,
  });

  @override
  State<AyahListView> createState() => _AyahListViewState();
}

class _AyahListViewState extends State<AyahListView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final AudioService _audioService = AudioService();
  bool _hasScrolledToInitial = false;

  @override
  void initState() {
    super.initState();
    // Schedule initial scroll animation after first frame
    if (widget.initialScrollIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToInitialWithAnimation();
      });
    }
  }

  void _scrollToInitialWithAnimation() {
    if (_hasScrolledToInitial) return;
    _hasScrolledToInitial = true;

    if (_itemScrollController.isAttached && widget.initialScrollIndex != null) {
      // Small delay for smoother UX - let the page settle first
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_itemScrollController.isAttached) {
          _itemScrollController.scrollTo(
            index: widget.initialScrollIndex! + 1, // +1 for Bismillah header
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart, // Smooth, elegant deceleration
            alignment: 0.0, // Position at top of screen
          );
        }
      });
    }
  }

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
        index: index + 1, // +1 for Bismillah header
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic, // Smooth deceleration animation
        alignment: 0.0, // Position at top of screen
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
              // Start at beginning, then animate to target for smooth effect
              initialScrollIndex: 0,
              padding: const EdgeInsets.only(bottom: 100),
              itemBuilder: (context, index) {
                if (index == 0) {
                   if (widget.surah.number == 9) {
                     return const SizedBox.shrink();
                   }
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
            // Ayah number badge with actions row
            _buildTopRow(context, isDark, theme),
            const SizedBox(height: 12),

            // Arabic Text with Tajweed (Right-aligned)
            _buildArabicText(isDark),

            // Bengali transliteration (Arabic pronunciation in Bengali script)
            if (showTransliteration &&
                transliterationLanguage != TransliterationLanguage.none) ...[
              const SizedBox(height: 8),
              _buildBengaliTransliteration(isDark),
            ],

            // Bengali/English Translation (meaning)
            if (showTranslation &&
                translationLanguage != TranslationLanguage.none) ...[
              const SizedBox(height: 8),
              _buildTranslation(isDark),
            ],

            const SizedBox(height: 12),
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

  /// Builds Bengali transliteration display (Arabic pronunciation in Bengali/English script)
  /// Format matches Bengali Quran style - shows how to pronounce the Arabic
  Widget _buildBengaliTransliteration(bool isDark) {
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
        if (ayah.transliterationBengali != null) {
          parts.add(ayah.transliterationBengali!);
        }
        if (ayah.transliterationEnglish != null) {
          parts.add(ayah.transliterationEnglish!);
        }
        transliteration = parts.isNotEmpty ? parts.join('\n') : null;
        break;
      case TransliterationLanguage.none:
        return const SizedBox.shrink();
    }

    if (transliteration == null || transliteration.isEmpty) {
      return const SizedBox.shrink();
    }

    // Check if it contains Bengali text
    final hasBengali = transliteration.contains(RegExp(r'[\u0980-\u09FF]'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A237E).withValues(alpha: 0.15)
            : const Color(0xFF1565C0).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1565C0).withValues(alpha: 0.3)
              : const Color(0xFF1565C0).withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        transliteration,
        textAlign: TextAlign.right,
        textDirection: hasBengali ? TextDirection.ltr : TextDirection.ltr,
        style: TextStyle(
          fontSize: fontSize * 0.52,
          fontFamily: hasBengali ? 'NotoSansBengali' : null,
          color: isDark
              ? const Color(0xFF90CAF9)
              : const Color(0xFF1565C0),
          height: 1.6,
          letterSpacing: hasBengali ? 0.3 : 0.5,
        ),
      ),
    );
  }

  Widget _buildTranslation(bool isDark) {
    String? translation;
    bool hasBengali = false;

    switch (translationLanguage) {
      case TranslationLanguage.english:
        translation = ayah.translationEnglish;
        break;
      case TranslationLanguage.bengali:
        translation = ayah.translationBengali;
        hasBengali = true;
        break;
      case TranslationLanguage.both:
        final parts = <String>[];
        if (ayah.translationBengali != null) {
          parts.add(ayah.translationBengali!);
          hasBengali = true;
        }
        if (ayah.translationEnglish != null) {
          parts.add(ayah.translationEnglish!);
        }
        translation = parts.isNotEmpty ? parts.join('\n\n') : null;
        break;
      case TranslationLanguage.none:
        return const SizedBox.shrink();
    }

    if (translation == null || translation.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.green.withValues(alpha: 0.08)
            : const Color(0xFF2E7D32).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ayah number indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                  : const Color(0xFF2E7D32).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${ayah.numberInSurah}',
              style: TextStyle(
                fontSize: fontSize * 0.4,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFF81C784)
                    : const Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Translation text
          Expanded(
            child: Text(
              translation,
              style: TextStyle(
                fontSize: fontSize * 0.5,
                fontFamily: hasBengali ? 'NotoSansBengali' : null,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textTranslation,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bismillah header shown at the top of each surah
/// Matches Bengali Quran style with Arabic, transliteration, and translation
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

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF1A237E).withValues(alpha: 0.3),
                      const Color(0xFF0D47A1).withValues(alpha: 0.2),
                    ]
                  : [
                      const Color(0xFF1565C0).withValues(alpha: 0.1),
                      const Color(0xFF42A5F5).withValues(alpha: 0.05),
                    ],

            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1565C0).withValues(alpha: 0.3)
                  : const Color(0xFF1565C0).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Arabic Bismillah text
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: AppTypography.quranText(
                  fontSize: fontSize * 0.85,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textArabic,
                ),
              ),

              // Bengali transliteration (if enabled)
              if (appState.showTransliteration &&
                  appState.transliterationLanguage != TransliterationLanguage.none) ...[
                const SizedBox(height: 10),
                Text(
                  'বিসমিল্লাহির রাহমানির রাহীম',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize * 0.45,
                    fontFamily: 'NotoSansBengali',
                    color: isDark
                        ? const Color(0xFF90CAF9)
                        : const Color(0xFF1565C0),
                    height: 1.5,
                  ),
                ),
              ],

              // Translation (if enabled)
              if (appState.showTranslation &&
                  appState.translationLanguage != TranslationLanguage.none) ...[
                const SizedBox(height: 10),
                Text(
                  appState.translationLanguage == TranslationLanguage.bengali ||
                          appState.translationLanguage == TranslationLanguage.both
                      ? 'পরম করুণাময় অতি দয়ালু আল্লাহর নামে'
                      : 'In the name of Allah, the Most Gracious, the Most Merciful',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize * 0.42,
                    fontFamily: appState.translationLanguage == TranslationLanguage.bengali ||
                            appState.translationLanguage == TranslationLanguage.both
                        ? 'NotoSansBengali'
                        : null,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTranslation,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

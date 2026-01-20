import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/models/surah.dart';
import '../../../core/models/ayah.dart';
import '../../../core/widgets/ayah_number_badge.dart' hide BismillahHeader;
import '../../../core/services/audio_service.dart';
import '../../../core/services/word_timing_service.dart';
import 'ayah_list_view.dart' show BismillahHeader;

/// Mushaf (page style) view of the Quran with word-by-word highlighting
class MushafView extends StatefulWidget {
  final Surah surah;
  final List<Ayah> ayahs;
  final double quranFontSize;

  const MushafView({
    super.key,
    required this.surah,
    required this.ayahs,
    required this.quranFontSize,
  });

  @override
  State<MushafView> createState() => _MushafViewState();
}

class _MushafViewState extends State<MushafView> {
  final AudioService _audioService = AudioService();
  final WordTimingService _wordTimingService = WordTimingService();

  @override
  void initState() {
    super.initState();
    _audioService.addListener(_onAudioStateChanged);
    _wordTimingService.addListener(_onTimingChanged);
    _loadTimingData();
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioStateChanged);
    _wordTimingService.removeListener(_onTimingChanged);
    super.dispose();
  }

  Future<void> _loadTimingData() async {
    if (_wordTimingService.hasTimingData(_audioService.currentReciter)) {
      await _wordTimingService.loadTimingData(
        _audioService.currentReciter,
        widget.surah.number,
      );
    }
  }

  void _onAudioStateChanged() {
    if (!mounted) return;

    // Update highlighting based on audio position
    if (_audioService.isPlaying &&
        _audioService.currentSurah == widget.surah.number &&
        _audioService.currentAyah != null) {
      final positionMsec = _audioService.position.inMilliseconds;
      _wordTimingService.updateHighlightedWords(
        _audioService.currentReciter,
        widget.surah.number,
        _audioService.currentAyah!,
        positionMsec,
      );
    } else {
      _wordTimingService.clearHighlight();
    }
    setState(() {});
  }

  void _onTimingChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          if (widget.surah.number != 9) BismillahHeader(fontSize: widget.quranFontSize),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.ivory,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.softRose.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : AppColors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: RichText(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              text: TextSpan(
                children: widget.ayahs.map((ayah) {
                  return _buildAyahSpan(ayah, isDark);
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  TextSpan _buildAyahSpan(Ayah ayah, bool isDark) {
    final isCurrentAyah = _audioService.isPlaying &&
        _audioService.currentSurah == widget.surah.number &&
        _audioService.currentAyah == ayah.numberInSurah;

    final highlightedIndex = isCurrentAyah ? _wordTimingService.highlightedWordIndex : -1;
    final words = ayah.arabicWords;

    final baseTextColor = isDark ? AppColors.darkTextPrimary : AppColors.textArabic;
    final highlightColor = AppColors.mutedTeal;

    // Build word spans with highlighting
    // In RTL: words flow right-to-left, ayah number appears at the END (left side)
    final wordSpans = <InlineSpan>[];

    // Add words first (they appear on the right in RTL)
    for (int i = 0; i < words.length; i++) {
      final isHighlighted = (highlightedIndex == i);

      final baseStyle = AppTypography.quranText(
        fontSize: widget.quranFontSize,
        color: isHighlighted ? highlightColor : baseTextColor,
        height: 2.2,
      );
      wordSpans.add(
        TextSpan(
          text: words[i],
          style: isHighlighted
              ? baseStyle.copyWith(fontWeight: FontWeight.bold)
              : baseStyle,
        ),
      );

      // Add space between words
      if (i < words.length - 1) {
        wordSpans.add(const TextSpan(text: ' '));
      }
    }

    // Add space before badge
    wordSpans.add(const TextSpan(text: ' '));

    // Add ayah number badge at the end (appears on the left in RTL)
    // Use Arabic-Indic numerals for proper RTL display
    final arabicNumber = _toArabicNumeral(ayah.numberInSurah);
    wordSpans.add(
      TextSpan(
        text: '\u06DD$arabicNumber', // ۝ (end of ayah mark) + Arabic numeral
        style: AppTypography.quranText(
          fontSize: widget.quranFontSize * 0.9,
          color: isCurrentAyah ? highlightColor : (isDark ? AppColors.softRose : AppColors.forestGreen),
          height: 2.2,
        ),
      ),
    );

    // Add spacing after ayah
    wordSpans.add(const TextSpan(text: ' '));

    return TextSpan(children: wordSpans);
  }

  /// Convert Western numerals to Arabic-Indic numerals (٠١٢٣٤٥٦٧٨٩)
  String _toArabicNumeral(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      final d = int.tryParse(digit);
      return d != null ? arabicNumerals[d] : digit;
    }).join();
  }
}

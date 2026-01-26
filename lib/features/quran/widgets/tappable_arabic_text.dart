import 'package:flutter/material.dart';
import '../../../core/models/quran_word.dart';
import '../../../core/services/word_by_word_service.dart';
import '../../../core/theme/app_colors.dart';
import 'word_details_sheet.dart';

/// Widget that displays Arabic text with tappable words for word-by-word translation
class TappableArabicText extends StatefulWidget {
  final String arabicText;
  final int surahNumber;
  final int ayahNumber;
  final double fontSize;
  final bool showTajweedColors;
  final Color? textColor;
  final TextAlign textAlign;

  const TappableArabicText({
    super.key,
    required this.arabicText,
    required this.surahNumber,
    required this.ayahNumber,
    this.fontSize = 28,
    this.showTajweedColors = false,
    this.textColor,
    this.textAlign = TextAlign.right,
  });

  @override
  State<TappableArabicText> createState() => _TappableArabicTextState();
}

class _TappableArabicTextState extends State<TappableArabicText> {
  final WordByWordService _wordService = WordByWordService();
  VerseWordsResponse? _wordsData;
  bool _isLoading = false;
  int? _selectedWordIndex;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void didUpdateWidget(TappableArabicText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surahNumber != widget.surahNumber ||
        oldWidget.ayahNumber != widget.ayahNumber) {
      _loadWords();
    }
  }

  Future<void> _loadWords() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _selectedWordIndex = null;
    });

    final words = await _wordService.getWordsForVerse(
      widget.surahNumber,
      widget.ayahNumber,
    );

    if (mounted) {
      setState(() {
        _wordsData = words;
        _isLoading = false;
      });
    }
  }

  void _onWordTap(QuranWord word, int index) {
    setState(() {
      _selectedWordIndex = index;
    });

    showWordDetailsSheet(
      context: context,
      word: word,
      verseKey: '${widget.surahNumber}:${widget.ayahNumber}',
    );

    // Reset selection after sheet closes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _selectedWordIndex = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultColor = widget.textColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);

    // If words data is not available, show regular text
    if (_wordsData == null || _wordsData!.words.isEmpty) {
      return Text(
        widget.arabicText,
        textDirection: TextDirection.rtl,
        textAlign: widget.textAlign,
        style: TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: widget.fontSize,
          height: 2.0,
          color: defaultColor,
        ),
      );
    }

    // Build tappable words
    final words = _wordsData!.words;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        alignment: widget.textAlign == TextAlign.center
            ? WrapAlignment.center
            : widget.textAlign == TextAlign.right
                ? WrapAlignment.start
                : WrapAlignment.end,
        spacing: 4,
        runSpacing: 8,
        children: words.asMap().entries.map((entry) {
          final index = entry.key;
          final word = entry.value;
          final isSelected = _selectedWordIndex == index;

          // Skip non-word characters like end markers
          if (!word.isWord) {
            return Text(
              word.textUthmani,
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: widget.fontSize,
                height: 2.0,
                color: defaultColor.withValues(alpha: 0.6),
              ),
            );
          }

          return GestureDetector(
            onTap: () => _onWordTap(word, index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Text(
                word.textUthmani,
                style: TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: widget.fontSize,
                  height: 1.8,
                  color: isSelected ? theme.colorScheme.primary : defaultColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Simplified version for use in list items (loads words on tap only)
class TappableArabicTextLazy extends StatefulWidget {
  final String arabicText;
  final int surahNumber;
  final int ayahNumber;
  final double fontSize;
  final Color? textColor;
  final TextAlign textAlign;

  const TappableArabicTextLazy({
    super.key,
    required this.arabicText,
    required this.surahNumber,
    required this.ayahNumber,
    this.fontSize = 28,
    this.textColor,
    this.textAlign = TextAlign.right,
  });

  @override
  State<TappableArabicTextLazy> createState() => _TappableArabicTextLazyState();
}

class _TappableArabicTextLazyState extends State<TappableArabicTextLazy> {
  final WordByWordService _wordService = WordByWordService();
  bool _wordModeEnabled = false;
  VerseWordsResponse? _wordsData;
  bool _isLoading = false;
  int? _selectedWordIndex;

  Future<void> _enableWordMode() async {
    if (_wordModeEnabled || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final words = await _wordService.getWordsForVerse(
      widget.surahNumber,
      widget.ayahNumber,
    );

    if (mounted) {
      setState(() {
        _wordsData = words;
        _wordModeEnabled = true;
        _isLoading = false;
      });
    }
  }

  void _onWordTap(QuranWord word, int index) {
    setState(() {
      _selectedWordIndex = index;
    });

    showWordDetailsSheet(
      context: context,
      word: word,
      verseKey: '${widget.surahNumber}:${widget.ayahNumber}',
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _selectedWordIndex = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultColor = widget.textColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);

    // Show loading indicator while fetching
    if (_isLoading) {
      return Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: Text(
              widget.arabicText,
              textDirection: TextDirection.rtl,
              textAlign: widget.textAlign,
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: widget.fontSize,
                height: 2.0,
                color: defaultColor,
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // If word mode is not enabled, show regular text with double-tap hint
    if (!_wordModeEnabled || _wordsData == null) {
      return GestureDetector(
        onDoubleTap: _enableWordMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.arabicText,
              textDirection: TextDirection.rtl,
              textAlign: widget.textAlign,
              style: TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: widget.fontSize,
                height: 2.0,
                color: defaultColor,
              ),
            ),
            // Hint for word-by-word mode
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 12,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Double-tap for word-by-word',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Build tappable words
    final words = _wordsData!.words;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 4,
            runSpacing: 8,
            children: words.asMap().entries.map((entry) {
              final index = entry.key;
              final word = entry.value;
              final isSelected = _selectedWordIndex == index;

              if (!word.isWord) {
                return Text(
                  word.textUthmani,
                  style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: widget.fontSize,
                    height: 2.0,
                    color: defaultColor.withValues(alpha: 0.6),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => _onWordTap(word, index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    word.textUthmani,
                    style: TextStyle(
                      fontFamily: 'Scheherazade',
                      fontSize: widget.fontSize,
                      height: 1.8,
                      color: isSelected ? theme.colorScheme.primary : defaultColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Mode indicator
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Word-by-word mode',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _wordModeEnabled = false;
                        });
                      },
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/models/ayah.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/word_timing_service.dart';

/// A widget that displays Arabic text with word-by-word highlighting during audio playback
class HighlightedArabicText extends StatefulWidget {
  final Ayah ayah;
  final double fontSize;
  final Color textColor;
  final Color highlightColor;
  final Color highlightTextColor;
  final String fontFamily;
  final TextAlign textAlign;
  final double lineHeight;

  const HighlightedArabicText({
    super.key,
    required this.ayah,
    this.fontSize = 28,
    this.textColor = Colors.black,
    this.highlightColor = const Color(0xFF4CAF50),
    this.highlightTextColor = Colors.white,
    this.fontFamily = 'Amiri',
    this.textAlign = TextAlign.center,
    this.lineHeight = 2.0,
  });

  @override
  State<HighlightedArabicText> createState() => _HighlightedArabicTextState();
}

class _HighlightedArabicTextState extends State<HighlightedArabicText> {
  final AudioService _audioService = AudioService();
  final WordTimingService _wordTimingService = WordTimingService();

  Set<int> _highlightedIndices = {};
  bool _timingLoaded = false;

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

  @override
  void didUpdateWidget(HighlightedArabicText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ayah.numberInSurah != widget.ayah.numberInSurah ||
        oldWidget.ayah.surahNumber != widget.ayah.surahNumber) {
      _loadTimingData();
    }
  }

  Future<void> _loadTimingData() async {
    final reciter = _audioService.currentReciter;
    if (_wordTimingService.hasTimingData(reciter)) {
      final timings = await _wordTimingService.loadTimingData(
        reciter,
        widget.ayah.surahNumber,
      );
      if (mounted) {
        setState(() {
          _timingLoaded = timings != null;
        });
      }
    }
  }

  void _onAudioStateChanged() {
    if (!mounted) return;

    // Check if this ayah is currently playing
    if (_audioService.currentSurah == widget.ayah.surahNumber &&
        _audioService.currentAyah == widget.ayah.numberInSurah &&
        _audioService.isPlaying) {
      // Update word highlighting based on audio position
      final positionMsec = _audioService.position.inMilliseconds;
      _wordTimingService.updateHighlightedWords(
        _audioService.currentReciter,
        widget.ayah.surahNumber,
        widget.ayah.numberInSurah,
        positionMsec,
      );
    } else {
      // Clear highlighting if not playing this ayah
      if (_highlightedIndices.isNotEmpty) {
        setState(() {
          _highlightedIndices = {};
        });
      }
    }
  }

  void _onTimingChanged() {
    if (!mounted) return;

    // Check if this ayah is currently playing
    if (_audioService.currentSurah == widget.ayah.surahNumber &&
        _audioService.currentAyah == widget.ayah.numberInSurah) {
      final newHighlighted = _wordTimingService.highlightedWords;
      if (_highlightedIndices != newHighlighted) {
        setState(() {
          _highlightedIndices = Set.from(newHighlighted);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.ayah.arabicWords;

    // Check if this ayah is currently playing
    final isCurrentlyPlaying =
        _audioService.currentSurah == widget.ayah.surahNumber &&
        _audioService.currentAyah == widget.ayah.numberInSurah &&
        _audioService.isPlaying;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        alignment: _getWrapAlignment(),
        spacing: 8,
        runSpacing: 4,
        children: List.generate(words.length, (index) {
          final isHighlighted = isCurrentlyPlaying &&
              _timingLoaded &&
              _highlightedIndices.contains(index);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: isHighlighted ? 6 : 2,
              vertical: isHighlighted ? 4 : 2,
            ),
            decoration: BoxDecoration(
              color: isHighlighted ? widget.highlightColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: widget.highlightColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              words[index],
              style: TextStyle(
                fontFamily: widget.fontFamily,
                fontSize: widget.fontSize,
                color: isHighlighted ? widget.highlightTextColor : widget.textColor,
                height: widget.lineHeight,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }),
      ),
    );
  }

  WrapAlignment _getWrapAlignment() {
    switch (widget.textAlign) {
      case TextAlign.left:
      case TextAlign.start:
        return WrapAlignment.start;
      case TextAlign.right:
      case TextAlign.end:
        return WrapAlignment.end;
      case TextAlign.center:
        return WrapAlignment.center;
      case TextAlign.justify:
        return WrapAlignment.spaceBetween;
    }
  }
}

/// A simpler version that just displays highlighted text based on external state
class SimpleHighlightedArabicText extends StatelessWidget {
  final String text;
  final Set<int> highlightedWordIndices;
  final double fontSize;
  final Color textColor;
  final Color highlightColor;
  final Color highlightTextColor;
  final String fontFamily;
  final TextAlign textAlign;
  final double lineHeight;

  const SimpleHighlightedArabicText({
    super.key,
    required this.text,
    this.highlightedWordIndices = const {},
    this.fontSize = 28,
    this.textColor = Colors.black,
    this.highlightColor = const Color(0xFF4CAF50),
    this.highlightTextColor = Colors.white,
    this.fontFamily = 'Amiri',
    this.textAlign = TextAlign.center,
    this.lineHeight = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final words = text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        alignment: _getWrapAlignment(),
        spacing: 8,
        runSpacing: 4,
        children: List.generate(words.length, (index) {
          final isHighlighted = highlightedWordIndices.contains(index);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: isHighlighted ? 6 : 2,
              vertical: isHighlighted ? 4 : 2,
            ),
            decoration: BoxDecoration(
              color: isHighlighted ? highlightColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: highlightColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              words[index],
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: fontSize,
                color: isHighlighted ? highlightTextColor : textColor,
                height: lineHeight,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }),
      ),
    );
  }

  WrapAlignment _getWrapAlignment() {
    switch (textAlign) {
      case TextAlign.left:
      case TextAlign.start:
        return WrapAlignment.start;
      case TextAlign.right:
      case TextAlign.end:
        return WrapAlignment.end;
      case TextAlign.center:
        return WrapAlignment.center;
      case TextAlign.justify:
        return WrapAlignment.spaceBetween;
    }
  }
}

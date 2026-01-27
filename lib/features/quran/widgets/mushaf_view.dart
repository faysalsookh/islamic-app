import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/surah.dart';
import '../../../../core/models/ayah.dart';
import '../../../../core/models/tajweed.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/tajweed_service.dart';

/// Premium Mushaf (page style) view of the Quran
/// Designed to look like a real physical Quran with ornamental borders
class MushafView extends StatefulWidget {
  final Surah surah;
  final List<Ayah> ayahs;
  final double quranFontSize;
  final int currentAyahIndex;
  final int? initialScrollIndex;
  final ValueChanged<int>? onAyahSelected;

  const MushafView({
    super.key,
    required this.surah,
    required this.ayahs,
    required this.quranFontSize,
    this.currentAyahIndex = 0,
    this.initialScrollIndex,
    this.onAyahSelected,
  });

  @override
  State<MushafView> createState() => _MushafViewState();
}

class _MushafViewState extends State<MushafView> {
  final ScrollController _scrollController = ScrollController();
  final AudioService _audioService = AudioService();
  int? _lastScrolledAyah;

  /// Map of ayah number -> GlobalKey for scroll targeting
  final Map<int, GlobalKey> _ayahKeys = {};

  @override
  void initState() {
    super.initState();
    _audioService.addListener(_onAudioStateChanged);
    _initAyahKeys();

    if (widget.initialScrollIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyahIndex(widget.initialScrollIndex!);
      });
    }
  }

  @override
  void didUpdateWidget(covariant MushafView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ayahs.length != widget.ayahs.length) {
      _initAyahKeys();
    }
    // Scroll when currentAyahIndex changes from parent (e.g. navigation)
    if (oldWidget.currentAyahIndex != widget.currentAyahIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyahIndex(widget.currentAyahIndex);
      });
    }
  }

  void _initAyahKeys() {
    _ayahKeys.clear();
    for (int i = 0; i < widget.ayahs.length; i++) {
      _ayahKeys[widget.ayahs[i].numberInSurah] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioStateChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onAudioStateChanged() {
    if (_audioService.currentSurah == widget.surah.number &&
        _audioService.currentAyah != null &&
        _audioService.isPlaying) {
      final playingAyahNumber = _audioService.currentAyah!;

      if (_lastScrolledAyah != playingAyahNumber) {
        _lastScrolledAyah = playingAyahNumber;
        final index = widget.ayahs
            .indexWhere((a) => a.numberInSurah == playingAyahNumber);
        if (index != -1) {
          _scrollToAyahNumber(playingAyahNumber);
        }
      }
    }
  }

  void _scrollToAyahIndex(int index) {
    if (index < 0 || index >= widget.ayahs.length) return;
    final ayahNumber = widget.ayahs[index].numberInSurah;
    _scrollToAyahNumber(ayahNumber);
  }

  void _scrollToAyahNumber(int ayahNumber) {
    final key = _ayahKeys[ayahNumber];
    if (key == null || key.currentContext == null) return;

    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.3,
    );
  }

  void _onAyahTap(Ayah ayah) {
    HapticService().selectionClick();

    // Notify parent of selection
    final index =
        widget.ayahs.indexWhere((a) => a.numberInSurah == ayah.numberInSurah);
    if (index != -1) {
      widget.onAyahSelected?.call(index);
    }

    if (_audioService.isAyahPlaying(
        widget.surah.number, ayah.numberInSurah)) {
      _audioService.pause();
    } else {
      _audioService.playAyah(widget.surah.number, ayah.numberInSurah);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          color: isDark ? AppColors.darkBackground : const Color(0xFFF5F0E8),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              children: [
                // Mushaf Page
                _MushafPage(
                  surah: widget.surah,
                  ayahs: widget.ayahs,
                  fontSize: widget.quranFontSize,
                  isDark: isDark,
                  theme: theme,
                  onAyahTap: _onAyahTap,
                  fontFamily: appState.arabicFontStyle.fontFamily,
                  ayahKeys: _ayahKeys,
                  currentAyahNumber: widget.ayahs.isNotEmpty &&
                          widget.currentAyahIndex < widget.ayahs.length
                      ? widget.ayahs[widget.currentAyahIndex].numberInSurah
                      : null,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A single Mushaf page with ornamental frame
class _MushafPage extends StatelessWidget {
  final Surah surah;
  final List<Ayah> ayahs;
  final double fontSize;
  final bool isDark;
  final ThemeData theme;
  final Function(Ayah) onAyahTap;
  final String? fontFamily;
  final Map<int, GlobalKey> ayahKeys;
  final int? currentAyahNumber;

  const _MushafPage({
    required this.surah,
    required this.ayahs,
    required this.fontSize,
    required this.isDark,
    required this.theme,
    required this.onAyahTap,
    required this.fontFamily,
    required this.ayahKeys,
    this.currentAyahNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Page colors
    final pageColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFDF5);
    final borderColor = isDark
        ? const Color(0xFF8B7355)
        : const Color(0xFFB8860B);
    final ornamentColor = isDark
        ? const Color(0xFFD4AF37).withValues(alpha: 0.6)
        : const Color(0xFFB8860B).withValues(alpha: 0.8);

    return Container(
      decoration: BoxDecoration(
        color: pageColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          children: [
            // Background pattern (subtle)
            if (!isDark)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset(
                    'assets/images/pattern.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),

            // Main content with padding
            Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ornamentColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ornamentColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Column(
                      children: [
                        // Surah Header
                        _SurahHeader(
                          surah: surah,
                          isDark: isDark,
                          ornamentColor: ornamentColor,
                        ),

                        // Bismillah (except for Surah At-Tawbah)
                        if (surah.number != 9)
                          _BismillahSection(
                            fontSize: fontSize,
                            isDark: isDark,
                            ornamentColor: ornamentColor,
                          ),

                        // Ayahs content
                        Consumer<AppStateProvider>(
                          builder: (context, appState, child) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: _AyahsContent(
                                ayahs: ayahs,
                                surahNumber: surah.number,
                                fontSize: fontSize,
                                isDark: isDark,
                                showTajweedColors: appState.showTajweedColors,
                                onAyahTap: onAyahTap,
                                fontFamily: fontFamily,
                                ayahKeys: ayahKeys,
                                currentAyahNumber: currentAyahNumber,
                              ),
                            );
                          },
                        ),

                        // Page footer
                        _PageFooter(
                          surah: surah,
                          isDark: isDark,
                          ornamentColor: ornamentColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Corner ornaments
            ..._buildCornerOrnaments(ornamentColor),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerOrnaments(Color color) {
    return [
      // Top left
      Positioned(
        top: 8,
        left: 8,
        child: _CornerOrnament(color: color, rotation: 0),
      ),
      // Top right
      Positioned(
        top: 8,
        right: 8,
        child: _CornerOrnament(color: color, rotation: 1),
      ),
      // Bottom left
      Positioned(
        bottom: 8,
        left: 8,
        child: _CornerOrnament(color: color, rotation: 3),
      ),
      // Bottom right
      Positioned(
        bottom: 8,
        right: 8,
        child: _CornerOrnament(color: color, rotation: 2),
      ),
    ];
  }
}

/// Corner ornament decoration
class _CornerOrnament extends StatelessWidget {
  final Color color;
  final int rotation; // 0-3 for 90-degree rotations

  const _CornerOrnament({
    required this.color,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: rotation,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CustomPaint(
          painter: _CornerOrnamentPainter(color: color),
        ),
      ),
    );
  }
}

class _CornerOrnamentPainter extends CustomPainter {
  final Color color;

  _CornerOrnamentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();

    // L-shaped corner with decorative curves
    path.moveTo(0, size.height * 0.7);
    path.lineTo(0, size.height * 0.15);
    path.quadraticBezierTo(0, 0, size.width * 0.15, 0);
    path.lineTo(size.width * 0.7, 0);

    canvas.drawPath(path, paint);

    // Small decorative dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.15),
      2,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Surah header with ornamental design
class _SurahHeader extends StatelessWidget {
  final Surah surah;
  final bool isDark;
  final Color ornamentColor;

  const _SurahHeader({
    required this.surah,
    required this.isDark,
    required this.ornamentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ornamental background
          Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF2C2416),
                        const Color(0xFF3D3221),
                        const Color(0xFF2C2416),
                      ]
                    : [
                        const Color(0xFFF5E6C8),
                        const Color(0xFFEED9A4),
                        const Color(0xFFF5E6C8),
                      ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: ornamentColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ornamentColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),

          // Decorative elements on sides
          Positioned(
            left: 0,
            child: _SideOrnament(color: ornamentColor, isLeft: true),
          ),
          Positioned(
            right: 0,
            child: _SideOrnament(color: ornamentColor, isLeft: false),
          ),

          // Surah name
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سُورَةُ ${surah.nameArabic}',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFF5D4E37),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${surah.ayahCount} آيات',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFFD4AF37).withValues(alpha: 0.7)
                      : const Color(0xFF5D4E37).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Side ornament for surah header
class _SideOrnament extends StatelessWidget {
  final Color color;
  final bool isLeft;

  const _SideOrnament({
    required this.color,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: isLeft ? 1 : -1,
      child: Container(
        width: 40,
        height: 56,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: color, width: 1.5),
          ),
        ),
        child: CustomPaint(
          painter: _SideOrnamentPainter(color: color),
        ),
      ),
    );
  }
}

class _SideOrnamentPainter extends CustomPainter {
  final Color color;

  _SideOrnamentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Decorative curve
    final path = Path();
    path.moveTo(size.width, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.35,
      size.width * 0.3,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.65,
      size.width,
      size.height * 0.8,
    );

    canvas.drawPath(path, paint);

    // Small decorative elements
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      3,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bismillah section with ornamental frame
class _BismillahSection extends StatelessWidget {
  final double fontSize;
  final bool isDark;
  final Color ornamentColor;

  const _BismillahSection({
    required this.fontSize,
    required this.isDark,
    required this.ornamentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ornamentColor.withValues(alpha: 0.5),
            width: 1,
          ),
          bottom: BorderSide(
            color: ornamentColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Decorative line above
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        ornamentColor.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '۞',
                  style: TextStyle(
                    fontSize: 16,
                    color: ornamentColor,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ornamentColor.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bismillah text
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: AppTypography.quranText(
              fontSize: fontSize * 0.85,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : const Color(0xFF2C1810),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          // Decorative line below
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        ornamentColor.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '۞',
                  style: TextStyle(
                    fontSize: 16,
                    color: ornamentColor,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ornamentColor.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ayahs content with proper Arabic text layout and Tajweed colors
class _AyahsContent extends StatelessWidget {
  final List<Ayah> ayahs;
  final int surahNumber;
  final double fontSize;
  final bool isDark;
  final bool showTajweedColors;
  final Function(Ayah) onAyahTap;
  final String? fontFamily;
  final Map<int, GlobalKey> ayahKeys;
  final int? currentAyahNumber;

  const _AyahsContent({
    required this.ayahs,
    required this.surahNumber,
    required this.fontSize,
    required this.isDark,
    required this.showTajweedColors,
    required this.onAyahTap,
    required this.fontFamily,
    required this.ayahKeys,
    this.currentAyahNumber,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : const Color(0xFF1A1A1A);
    final ayahMarkerColor = isDark
        ? const Color(0xFFD4AF37)
        : const Color(0xFF8B6914);

    final tajweedService = TajweedService();
    final tajweedColors = TajweedColors.bengaliQuran;

    // Check if using IndoPak font
    final isIndoPak = fontFamily == 'Scheherazade New' ||
                      fontFamily == 'Noorehuda' ||
                      fontFamily == 'Lateef';

    // Highlight color for the currently active ayah
    final highlightBg = isDark
        ? const Color(0xFF2E7D32).withValues(alpha: 0.18)
        : const Color(0xFF2E7D32).withValues(alpha: 0.10);
    final highlightTextColor = isDark
        ? const Color(0xFF81C784)
        : const Color(0xFF1B5E20);

    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
      text: TextSpan(
        children: ayahs.expand((ayah) {
          final List<InlineSpan> spans = [];
          final isCurrentAyah = ayah.numberInSurah == currentAyahNumber;

          // Determine which text to display based on font
          final displayText = (isIndoPak && ayah.textIndopak != null)
              ? ayah.textIndopak!
              : ayah.textArabic;

          // For IndoPak text, generate tajweed markup algorithmically
          // For Uthmani text, use the pre-annotated tajweed from API
          String? displayMarkup;
          if (isIndoPak && ayah.textIndopak != null) {
            displayMarkup = tajweedService.generateTajweedMarkup(ayah.textIndopak!);
          } else {
            displayMarkup = ayah.textWithTajweed;
          }

          // Add Tajweed colored text or plain text
          if (showTajweedColors && displayMarkup != null && displayMarkup.isNotEmpty) {
            final segments = tajweedService.parseMarkup(displayMarkup);
            for (final segment in segments) {
              final color = isCurrentAyah
                  ? highlightTextColor
                  : (segment.rule == TajweedRule.normal
                      ? textColor
                      : tajweedColors.colorForRule(segment.rule));
              spans.add(
                TextSpan(
                  text: segment.text,
                  style: AppTypography.quranText(
                    fontSize: fontSize,
                    color: color,
                    height: 2.4,
                    fontFamily: fontFamily,
                  ).copyWith(
                    backgroundColor: isCurrentAyah ? highlightBg : null,
                  ),
                ),
              );
            }
          } else {
            spans.add(
              TextSpan(
                text: displayText,
                style: AppTypography.quranText(
                  fontSize: fontSize,
                  color: isCurrentAyah ? highlightTextColor : textColor,
                  height: 2.4,
                  fontFamily: fontFamily,
                ).copyWith(
                  backgroundColor: isCurrentAyah ? highlightBg : null,
                ),
              ),
            );
          }

          // Add ayah end marker with GlobalKey for scroll targeting
          final key = ayahKeys[ayah.numberInSurah];

          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                key: key,
                onTap: () => onAyahTap(ayah),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _AyahEndMarker(
                    number: ayah.numberInSurah,
                    fontSize: fontSize,
                    color: isCurrentAyah
                        ? (isDark
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF2E7D32))
                        : ayahMarkerColor,
                    isHighlighted: isCurrentAyah,
                  ),
                ),
              ),
            ),
          );

          // Add spacing after ayah
          spans.add(const TextSpan(text: ' '));

          return spans;
        }).toList(),
      ),
    );
  }
}

/// Traditional Quran ayah end marker (۝) with number
class _AyahEndMarker extends StatelessWidget {
  final int number;
  final double fontSize;
  final Color color;
  final bool isHighlighted;

  const _AyahEndMarker({
    required this.number,
    required this.fontSize,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = fontSize * 0.9;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: isHighlighted ? 2.5 : 1.5,
        ),
        color: isHighlighted ? color.withValues(alpha: 0.15) : null,
      ),
      child: Center(
        child: Text(
          _toArabicNumerals(number),
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: size * 0.45,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1,
          ),
        ),
      ),
    );
  }

  String _toArabicNumerals(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      final index = int.tryParse(digit);
      return index != null ? arabicNumerals[index] : digit;
    }).join();
  }
}

/// Page footer with surah info
class _PageFooter extends StatelessWidget {
  final Surah surah;
  final bool isDark;
  final Color ornamentColor;

  const _PageFooter({
    required this.surah,
    required this.isDark,
    required this.ornamentColor,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? const Color(0xFFD4AF37).withValues(alpha: 0.7)
        : const Color(0xFF5D4E37).withValues(alpha: 0.7);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ornamentColor.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Juz info
          Row(
            children: [
              Text(
                'جزء',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _toArabicNumerals(surah.juzStart),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),

          // Decorative center element
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 1,
                color: ornamentColor.withValues(alpha: 0.3),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '۝',
                  style: TextStyle(
                    fontSize: 14,
                    color: ornamentColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 1,
                color: ornamentColor.withValues(alpha: 0.3),
              ),
            ],
          ),

          // Surah number
          Row(
            children: [
              Text(
                'سورة',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _toArabicNumerals(surah.number),
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _toArabicNumerals(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      final index = int.tryParse(digit);
      return index != null ? arabicNumerals[index] : digit;
    }).join();
  }
}

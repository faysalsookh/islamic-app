import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../data/umrah_dua_model.dart';
import 'floral_decoration.dart';

/// Premium Umrah Dua Card with elegant design
class UmrahDuaCard extends StatelessWidget {
  final UmrahDua dua;
  final int totalCards;
  final bool showBengali;

  const UmrahDuaCard({
    super.key,
    required this.dua,
    required this.totalCards,
    this.showBengali = true,
  });

  // Card color scheme matching the reference images
  static const Color _cardBackground = Color(0xFFFAF6F1);
  static const Color _primaryBrown = Color(0xFF6D4C3D);
  static const Color _secondaryBrown = Color(0xFF8B6914);
  static const Color _accentBrown = Color(0xFFA67C52);
  static const Color _textBrown = Color(0xFF5D4037);
  static const Color _lightBrown = Color(0xFFBE9B7B);
  static const Color _badgeColor = Color(0xFF5D4037);

  @override
  Widget build(BuildContext context) {
    final fontFamily = context.select<AppStateProvider, String>(
      (s) => s.arabicFontStyle.fontFamily,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _primaryBrown.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _CardBackgroundPainter(),
              ),
            ),

            // Floral decoration at top
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FloralDecoration(
                height: 100,
                primaryColor: Color(0xFF8B5A3C),
                secondaryColor: Color(0xFFBE9B7B),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card number badge
                  Center(child: _buildCardNumberBadge()),

                  const SizedBox(height: 16),

                  // Title
                  _buildTitle(),

                  const SizedBox(height: 28),

                  // Arabic text
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildArabicText(fontFamily),
                          const SizedBox(height: 24),

                          // Transliteration
                          _buildTransliteration(),

                          const SizedBox(height: 20),

                          // English translation
                          _buildEnglishTranslation(),

                          // Bengali translation (if enabled)
                          if (showBengali && dua.translationBengali != null) ...[
                            const SizedBox(height: 16),
                            _buildBengaliTranslation(),
                          ],

                          // Reference
                          if (dua.reference != null) ...[
                            const SizedBox(height: 24),
                            Center(child: _buildReference()),
                          ],

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardNumberBadge() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _badgeColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          dua.id.toString().padLeft(2, '0'),
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          dua.titleEnglish,
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: _primaryBrown,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (dua.titleArabic.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            dua.titleArabic,
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: _accentBrown.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildArabicText(String? fontFamily) {
    TextStyle arabicStyle;

    if (fontFamily != null) {
      if (fontFamily == 'Scheherazade New') {
        arabicStyle = GoogleFonts.scheherazadeNew(
          fontSize: 26,
          height: 2.0,
          color: _textBrown,
        );
      } else if (fontFamily == 'Lateef') {
        arabicStyle = GoogleFonts.lateef(
          fontSize: 26,
          height: 2.0,
          color: _textBrown,
        );
      } else if (fontFamily == 'Noto Sans Arabic') {
        arabicStyle = GoogleFonts.notoSansArabic(
          fontSize: 24,
          height: 2.0,
          color: _textBrown,
        );
      } else {
        arabicStyle = GoogleFonts.amiri(
          fontSize: 26,
          height: 2.0,
          color: _textBrown,
        );
      }
    } else {
      arabicStyle = GoogleFonts.amiri(
        fontSize: 26,
        height: 2.0,
        color: _textBrown,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Text(
        dua.arabicText,
        style: arabicStyle,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildTransliteration() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        dua.transliteration,
        style: GoogleFonts.crimsonText(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: _secondaryBrown,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEnglishTranslation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        dua.translationEnglish,
        style: GoogleFonts.crimsonText(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: _textBrown,
          height: 1.7,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBengaliTranslation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _lightBrown.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          dua.translationBengali!,
          style: TextStyle(
            fontFamily: 'NotoSansBengali',
            fontSize: 15,
            color: _textBrown.withValues(alpha: 0.85),
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildReference() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _lightBrown.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        dua.reference!,
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _accentBrown,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Background pattern painter for subtle texture
class _CardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B5A3C).withValues(alpha: 0.02)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Subtle geometric pattern
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw small decorative dots
        canvas.drawCircle(
          Offset(x + spacing / 2, y + spacing / 2),
          1,
          paint..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

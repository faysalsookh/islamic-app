import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for the Islamic app
/// Handles both Arabic (Quran text) and Latin (UI) fonts
class AppTypography {
  AppTypography._();

  // ============== ARABIC QURAN FONTS ==============

  /// Main Quran text style - uses Amiri for beautiful Arabic rendering
  /// Amiri is designed for classical Arabic texts with proper diacritics
  static TextStyle quranText({
    double fontSize = 28,
    Color color = AppColors.textArabic,
    double height = 2.0,
    double letterSpacing = 0,
    double wordSpacing = 3,
    String? fontFamily,
  }) {
    if (fontFamily != null) {
      if (fontFamily == 'Scheherazade New') {
         return GoogleFonts.scheherazadeNew(
            fontSize: fontSize,
            color: color,
            height: height,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: FontWeight.w400,
         );
      } else if (fontFamily == 'Lateef') {
         return GoogleFonts.lateef(
            fontSize: fontSize,
            color: color,
            height: height,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: FontWeight.w400,
         );
      } else if (fontFamily == 'Reem Kufi') {
         return GoogleFonts.reemKufi(
            fontSize: fontSize,
            color: color,
            height: height,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: FontWeight.w400,
         );
      } else if (fontFamily == 'Noto Sans Arabic') {
         return GoogleFonts.notoSansArabic(
            fontSize: fontSize,
            color: color,
            height: height,
            letterSpacing: letterSpacing,
            wordSpacing: wordSpacing,
            fontWeight: FontWeight.w400,
         );
      }

      try {
        return GoogleFonts.getFont(
          fontFamily,
          fontSize: fontSize,
          color: color,
          height: height,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          fontWeight: FontWeight.w400,
        );
      } catch (e) {
        debugPrint('Error loading font $fontFamily: $e');
      }
    }
    
    return GoogleFonts.amiri(
      fontSize: fontSize,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      fontWeight: FontWeight.w400,
    );
  }

  /// Alternative Quran font - Scheherazade for a more traditional look
  static TextStyle quranTextTraditional({
    double fontSize = 28,
    Color color = AppColors.textArabic,
    double height = 2.0,
  }) {
    return GoogleFonts.scheherazadeNew(
      fontSize: fontSize,
      color: color,
      height: height,
      fontWeight: FontWeight.w400,
    );
  }

  /// Lateef font - clean and modern Arabic
  static TextStyle quranTextModern({
    double fontSize = 28,
    Color color = AppColors.textArabic,
    double height = 2.0,
  }) {
    return GoogleFonts.lateef(
      fontSize: fontSize,
      color: color,
      height: height,
      fontWeight: FontWeight.w400,
    );
  }

  // ============== TRANSLATION TEXT ==============

  /// Translation text style - softer color to not distract from Arabic
  static TextStyle translationText({
    double fontSize = 16,
    Color color = AppColors.textTranslation,
    double height = 1.6,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      color: color,
      height: height,
      fontWeight: FontWeight.w400,
    );
  }

  // ============== UI FONTS (LATIN) ==============

  /// App title - large and prominent
  static TextStyle appTitle({Color color = AppColors.textPrimary}) {
    return GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.5,
    );
  }

  /// Screen/Section titles
  static TextStyle heading1({Color color = AppColors.textPrimary}) {
    return GoogleFonts.outfit(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.3,
    );
  }

  /// Subsection titles
  static TextStyle heading2({Color color = AppColors.textPrimary}) {
    return GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Card titles
  static TextStyle heading3({Color color = AppColors.textPrimary}) {
    return GoogleFonts.outfit(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Small headings
  static TextStyle heading4({Color color = AppColors.textPrimary}) {
    return GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Body text - primary
  static TextStyle bodyLarge({Color color = AppColors.textPrimary}) {
    return GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  /// Body text - secondary
  static TextStyle bodyMedium({Color color = AppColors.textSecondary}) {
    return GoogleFonts.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  /// Body text - small
  static TextStyle bodySmall({Color color = AppColors.textTertiary}) {
    return GoogleFonts.outfit(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  /// Button text
  static TextStyle button({Color color = AppColors.textOnDark}) {
    return GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.5,
    );
  }

  /// Label text
  static TextStyle label({Color color = AppColors.textSecondary}) {
    return GoogleFonts.outfit(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: 0.3,
    );
  }

  /// Caption text
  static TextStyle caption({Color color = AppColors.textTertiary}) {
    return GoogleFonts.outfit(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // ============== ARABIC UI TEXT ==============

  /// Arabic greeting text
  static TextStyle arabicGreeting({
    Color color = AppColors.textPrimary,
    double fontSize = 20,
    String? fontFamily,
  }) {
    if (fontFamily != null) {
      if (fontFamily == 'Scheherazade New') {
        return GoogleFonts.scheherazadeNew(fontSize: fontSize, fontWeight: FontWeight.w400, color: color);
      } else if (fontFamily == 'Lateef') {
        return GoogleFonts.lateef(fontSize: fontSize, fontWeight: FontWeight.w400, color: color);
      } else if (fontFamily == 'Reem Kufi') {
        return GoogleFonts.reemKufi(fontSize: fontSize, fontWeight: FontWeight.w400, color: color);
      } else if (fontFamily == 'Noto Sans Arabic') {
        return GoogleFonts.notoSansArabic(fontSize: fontSize, fontWeight: FontWeight.w400, color: color);
      }
      try {
        return GoogleFonts.getFont(
          fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: color,
        );
      } catch (e) {
        debugPrint('Error loading font $fontFamily: $e');
      }
    }
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  /// Surah name in Arabic
  static TextStyle surahNameArabic({
    Color color = AppColors.textPrimary,
    double fontSize = 24,
    String? fontFamily,
  }) {
    if (fontFamily != null) {
      if (fontFamily == 'Scheherazade New') {
        return GoogleFonts.scheherazadeNew(fontSize: fontSize, fontWeight: FontWeight.w700, color: color);
      } else if (fontFamily == 'Lateef') {
        return GoogleFonts.lateef(fontSize: fontSize, fontWeight: FontWeight.w700, color: color);
      } else if (fontFamily == 'Reem Kufi') {
        return GoogleFonts.reemKufi(fontSize: fontSize, fontWeight: FontWeight.w700, color: color);
      } else if (fontFamily == 'Noto Sans Arabic') {
        return GoogleFonts.notoSansArabic(fontSize: fontSize, fontWeight: FontWeight.w700, color: color);
      }
      try {
        return GoogleFonts.getFont(
          fontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
        );
      } catch (e) {
        debugPrint('Error loading font $fontFamily: $e');
      }
    }
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  /// Ayah number badge
  static TextStyle ayahNumber({
    Color color = AppColors.forestGreen,
    double fontSize = 14,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }
}

/// Font size presets for Quran reading
class QuranFontSizes {
  static const double extraSmall = 20;
  static const double small = 24;
  static const double medium = 28;
  static const double large = 32;
  static const double extraLarge = 36;
  static const double jumbo = 42;
}

/// Line height presets for Quran reading
class QuranLineHeights {
  static const double compact = 1.6;
  static const double normal = 2.0;
  static const double comfortable = 2.4;
  static const double spacious = 2.8;
}

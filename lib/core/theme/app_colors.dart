import 'package:flutter/material.dart';

/// App color palette designed for a feminine, elegant Islamic app
/// Soft, calming tones with professional feel
class AppColors {
  AppColors._();

  // ============== PRIMARY COLORS ==============

  // Soft Rose - Primary accent for feminine touch
  static const Color softRose = Color(0xFFE8B4B8);
  static const Color softRoseLight = Color(0xFFF5D6D9);
  static const Color softRoseDark = Color(0xFFD4959A);

  // Muted Teal - Secondary accent for balance
  static const Color mutedTeal = Color(0xFF7BA3A8);
  static const Color mutedTealLight = Color(0xFFA8C9CD);
  static const Color mutedTealDark = Color(0xFF5B8489);

  // Deep Forest Green - For emphasis and contrast
  static const Color forestGreen = Color(0xFF2D4739);
  static const Color forestGreenLight = Color(0xFF4A6B5A);
  static const Color forestGreenDark = Color(0xFF1E3026);

  // ============== NEUTRAL COLORS ==============

  // Warm Beige tones
  static const Color warmBeige = Color(0xFFF5EDE4);
  static const Color warmBeigeDark = Color(0xFFE8DDD0);
  static const Color cream = Color(0xFFFAF8F5);

  // Ivory for backgrounds
  static const Color ivory = Color(0xFFFFFFF5);
  static const Color ivoryDark = Color(0xFFF0EDE5);

  // ============== TEXT COLORS ==============

  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF6B7C8A);
  static const Color textTertiary = Color(0xFF9BA8B4);
  static const Color textOnDark = Color(0xFFFAFAFA);
  static const Color textArabic = Color(0xFF1A2530);
  static const Color textTranslation = Color(0xFF6B7C8A);

  // ============== DARK MODE COLORS ==============

  static const Color darkBackground = Color(0xFF1A1F24);
  static const Color darkSurface = Color(0xFF242B32);
  static const Color darkCard = Color(0xFF2E363E);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B8C1);

  // ============== SPECIAL THEME COLORS ==============

  // Rose Gold Theme
  static const Color roseGoldPrimary = Color(0xFFB76E79);
  static const Color roseGoldSecondary = Color(0xFFF8E8E9);
  static const Color roseGoldAccent = Color(0xFFD4A5A5);
  static const Color roseGoldBackground = Color(0xFFFDF6F6);

  // Olive & Cream Theme
  static const Color oliveGreen = Color(0xFF6B7F5E);
  static const Color oliveLight = Color(0xFF8FA580);
  static const Color oliveCream = Color(0xFFF9F6F0);
  static const Color oliveAccent = Color(0xFFC9D4BE);

  // ============== SEMANTIC COLORS ==============

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);

  // ============== UI ELEMENT COLORS ==============

  static const Color cardShadow = Color(0x1A000000);
  static const Color divider = Color(0xFFE8E8E8);
  static const Color dividerDark = Color(0xFF3A4249);
  static const Color highlight = Color(0xFFFFF9C4);
  static const Color highlightAyah = Color(0xFFF5EDE4);
  static const Color highlightAyahDark = Color(0xFF3A4249);

  // ============== GRADIENT DEFINITIONS ==============

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softRose, mutedTeal],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [forestGreen, forestGreenLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cream, warmBeige],
  );

  static const LinearGradient roseGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [roseGoldSecondary, roseGoldAccent],
  );
}

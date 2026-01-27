import 'package:flutter/material.dart';

/// Premium Islamic App Color Palette
/// Sophisticated muted teal with deep emerald accents
/// Designed for elegance, readability, and spiritual calm
class AppColors {
  AppColors._();

  // ============== PRIMARY COLORS ==============

  // Premium Muted Teal - Primary brand color
  static const Color mutedTeal = Color(0xFF2D7A7A);
  static const Color mutedTealLight = Color(0xFF4A9D9D);
  static const Color mutedTealDark = Color(0xFF1A5C5C);
  static const Color mutedTealSoft = Color(0xFFE8F4F4);

  // Deep Emerald Green - Islamic heritage accent
  static const Color emeraldGreen = Color(0xFF0D6B4F);
  static const Color emeraldGreenLight = Color(0xFF1A8A6A);
  static const Color emeraldGreenDark = Color(0xFF054D38);
  static const Color emeraldGreenSoft = Color(0xFFE6F5F0);

  // Soft Rose - Subtle feminine accent (kept for balance)
  static const Color softRose = Color(0xFFD4A5A8);
  static const Color softRoseLight = Color(0xFFF2E8E9);
  static const Color softRoseDark = Color(0xFFB8868A);

  // Legacy aliases for compatibility
  static const Color forestGreen = emeraldGreen;
  static const Color forestGreenLight = emeraldGreenLight;
  static const Color forestGreenDark = emeraldGreenDark;

  // ============== PREMIUM ACCENT COLORS ==============

  // Gold - For premium highlights and special elements
  static const Color premiumGold = Color(0xFFC9A962);
  static const Color premiumGoldLight = Color(0xFFE8D9A8);
  static const Color premiumGoldDark = Color(0xFFA68B3D);

  // ============== NEUTRAL COLORS ==============

  // Premium Warm Neutrals
  static const Color warmBeige = Color(0xFFF7F4F0);
  static const Color warmBeigeDark = Color(0xFFEDE8E2);
  static const Color cream = Color(0xFFFAFAF8);

  // Pearl & Ivory - Premium backgrounds
  static const Color pearl = Color(0xFFF8F9FA);
  static const Color ivory = Color(0xFFFCFCFB);
  static const Color ivoryDark = Color(0xFFF0F1EF);

  // ============== TEXT COLORS ==============

  static const Color textPrimary = Color(0xFF1A2E35);
  static const Color textSecondary = Color(0xFF4A6572);
  static const Color textTertiary = Color(0xFF8A9BA5);
  static const Color textOnDark = Color(0xFFF5F7F8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textArabic = Color(0xFF0F1F24);
  static const Color textTranslation = Color(0xFF4A6572);

  // ============== DARK MODE COLORS ==============

  // Premium Dark - Deep charcoal with subtle warmth
  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A2027);
  static const Color darkCard = Color(0xFF232B35);
  static const Color darkCardElevated = Color(0xFF2C3640);
  static const Color darkTextPrimary = Color(0xFFF0F3F5);
  static const Color darkTextSecondary = Color(0xFFA8B5C0);
  static const Color darkTextTertiary = Color(0xFF6B7A85);

  // Dark mode accents
  static const Color darkTealAccent = Color(0xFF3D9E9E);
  static const Color darkEmeraldAccent = Color(0xFF2AAF85);
  static const Color darkGoldAccent = Color(0xFFDBC07A);

  // ============== SPECIAL THEME COLORS ==============

  // Rose Gold Theme - Premium feminine option
  static const Color roseGoldPrimary = Color(0xFFB76E79);
  static const Color roseGoldSecondary = Color(0xFFF8ECEE);
  static const Color roseGoldAccent = Color(0xFFD4A5A5);
  static const Color roseGoldBackground = Color(0xFFFDF8F8);
  static const Color roseGoldSurface = Color(0xFFFFFFFF);

  // Olive & Cream Theme - Natural elegance
  static const Color oliveGreen = Color(0xFF5A7352);
  static const Color oliveLight = Color(0xFF7A9470);
  static const Color oliveDark = Color(0xFF3D5236);
  static const Color oliveCream = Color(0xFFFAF8F4);
  static const Color oliveAccent = Color(0xFFD4DFD0);

  // Premium Teal Theme - Primary theme colors
  static const Color tealThemePrimary = mutedTeal;
  static const Color tealThemeSecondary = emeraldGreen;
  static const Color tealThemeBackground = Color(0xFFF8FAFA);
  static const Color tealThemeSurface = Color(0xFFFFFFFF);
  static const Color tealThemeAccent = premiumGold;

  // ============== SEMANTIC COLORS ==============

  static const Color success = Color(0xFF2E9E6E);
  static const Color successLight = Color(0xFFE8F5EE);
  static const Color warning = Color(0xFFE8A838);
  static const Color warningLight = Color(0xFFFFF8E8);
  static const Color error = Color(0xFFD85858);
  static const Color errorLight = Color(0xFFFDEEEE);
  static const Color info = Color(0xFF4A90C8);
  static const Color infoLight = Color(0xFFE8F2FA);

  // ============== UI ELEMENT COLORS ==============

  static const Color cardShadow = Color(0x12000000);
  static const Color cardShadowDark = Color(0x40000000);
  static const Color divider = Color(0xFFE5E8EB);
  static const Color dividerDark = Color(0xFF2E363F);
  static const Color highlight = Color(0xFFFFFBE6);
  static const Color highlightAyah = Color(0xFFE8F4F4);
  static const Color highlightAyahDark = Color(0xFF1A3535);

  // Premium UI accents
  static const Color shimmer = Color(0xFFF5F7F9);
  static const Color shimmerHighlight = Color(0xFFFFFFFF);
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // ============== GRADIENT DEFINITIONS ==============

  // Premium Teal Gradient - Main brand gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mutedTeal, emeraldGreen],
  );

  // Premium Header Gradient
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mutedTealDark, emeraldGreenDark],
  );

  // Subtle Surface Gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pearl, warmBeige],
  );

  // Premium Gold Accent Gradient
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [premiumGoldLight, premiumGold],
  );

  // Rose Gold Gradient
  static const LinearGradient roseGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [roseGoldSecondary, roseGoldAccent],
  );

  // Dark Mode Gradient
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkSurface, darkBackground],
  );

  // Emerald Accent Gradient
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [emeraldGreen, emeraldGreenDark],
  );
}

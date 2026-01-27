import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Available theme modes in the app
enum AppThemeMode {
  light,
  dark,
  roseGold,
  oliveCream,
}

/// Theme data builder for the Islamic app
class AppTheme {
  AppTheme._();

  /// Light theme - Premium Teal & Emerald theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.mutedTeal,
      scaffoldBackgroundColor: AppColors.tealThemeBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.mutedTeal,
        primaryContainer: AppColors.mutedTealSoft,
        secondary: AppColors.emeraldGreen,
        secondaryContainer: AppColors.emeraldGreenSoft,
        tertiary: AppColors.premiumGold,
        tertiaryContainer: AppColors.premiumGoldLight,
        surface: AppColors.tealThemeSurface,
        surfaceContainerHighest: AppColors.pearl,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onTertiary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        outline: AppColors.divider,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.tealThemeBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.heading2(),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.tealThemeSurface,
        elevation: 0,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mutedTeal,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.button(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mutedTeal,
          side: const BorderSide(color: AppColors.mutedTeal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.button(color: AppColors.mutedTeal),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mutedTeal,
          textStyle: AppTypography.button(color: AppColors.mutedTeal),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.emeraldGreen,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.tealThemeSurface,
        selectedItemColor: AppColors.mutedTeal,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption(color: AppColors.mutedTeal),
        unselectedLabelStyle: AppTypography.caption(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.tealThemeSurface,
        indicatorColor: AppColors.mutedTealSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption(color: AppColors.mutedTeal);
          }
          return AppTypography.caption(color: AppColors.textTertiary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.mutedTeal);
          }
          return const IconThemeData(color: AppColors.textTertiary);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.mutedTeal,
        inactiveTrackColor: AppColors.mutedTeal.withValues(alpha: 0.2),
        thumbColor: AppColors.mutedTeal,
        overlayColor: AppColors.mutedTeal.withValues(alpha: 0.15),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mutedTeal;
          }
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mutedTeal.withValues(alpha: 0.4);
          }
          return AppColors.textTertiary.withValues(alpha: 0.25);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mutedTeal;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mutedTeal;
          }
          return AppColors.textTertiary;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.mutedTealSoft,
        labelStyle: AppTypography.caption(color: AppColors.mutedTeal),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pearl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.mutedTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: AppTypography.bodyMedium(color: AppColors.textTertiary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mutedTeal,
        linearTrackColor: AppColors.mutedTealSoft,
        circularTrackColor: AppColors.mutedTealSoft,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: AppTypography.bodyMedium(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.tealThemeSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.tealThemeSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  /// Dark theme - Premium night reading experience
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkTealAccent,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkTealAccent,
        primaryContainer: AppColors.mutedTealDark,
        secondary: AppColors.darkEmeraldAccent,
        secondaryContainer: AppColors.emeraldGreenDark,
        tertiary: AppColors.darkGoldAccent,
        tertiaryContainer: AppColors.premiumGoldDark,
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkCard,
        onPrimary: AppColors.darkBackground,
        onSecondary: AppColors.darkBackground,
        onTertiary: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.dividerDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.heading2(color: AppColors.darkTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shadowColor: AppColors.cardShadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.dividerDark.withValues(alpha: 0.5)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTealAccent,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.button(color: AppColors.darkBackground),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTealAccent,
          side: const BorderSide(color: AppColors.darkTealAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkTealAccent,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkEmeraldAccent,
        foregroundColor: AppColors.darkBackground,
        elevation: 4,
        shape: CircleBorder(),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkTealAccent,
        unselectedItemColor: AppColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption(color: AppColors.darkTealAccent),
        unselectedLabelStyle:
            AppTypography.caption(color: AppColors.darkTextTertiary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.mutedTealDark.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption(color: AppColors.darkTealAccent);
          }
          return AppTypography.caption(color: AppColors.darkTextTertiary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.darkTealAccent);
          }
          return const IconThemeData(color: AppColors.darkTextTertiary);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.darkTealAccent,
        inactiveTrackColor: AppColors.darkTealAccent.withValues(alpha: 0.2),
        thumbColor: AppColors.darkTealAccent,
        overlayColor: AppColors.darkTealAccent.withValues(alpha: 0.15),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkTealAccent;
          }
          return AppColors.darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkTealAccent.withValues(alpha: 0.4);
          }
          return AppColors.darkTextTertiary.withValues(alpha: 0.25);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkTealAccent;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.darkBackground),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: AppColors.darkTextTertiary),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkTealAccent;
          }
          return AppColors.darkTextTertiary;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.mutedTealDark.withValues(alpha: 0.3),
        labelStyle: AppTypography.caption(color: AppColors.darkTealAccent),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.dividerDark.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkTealAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: AppTypography.bodyMedium(color: AppColors.darkTextTertiary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.darkTealAccent,
        linearTrackColor: AppColors.darkTealAccent.withValues(alpha: 0.2),
        circularTrackColor: AppColors.darkTealAccent.withValues(alpha: 0.2),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCardElevated,
        contentTextStyle: AppTypography.bodyMedium(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  /// Rose Gold theme - Premium elegant feminine option
  static ThemeData roseGoldTheme() {
    return lightTheme().copyWith(
      primaryColor: AppColors.roseGoldPrimary,
      scaffoldBackgroundColor: AppColors.roseGoldBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.roseGoldPrimary,
        primaryContainer: AppColors.softRoseLight,
        secondary: AppColors.roseGoldAccent,
        secondaryContainer: AppColors.roseGoldSecondary,
        tertiary: AppColors.premiumGold,
        surface: AppColors.roseGoldSurface,
        surfaceContainerHighest: AppColors.roseGoldSecondary,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        outline: AppColors.divider,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.roseGoldBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.heading2(),
      ),
      cardTheme: CardThemeData(
        color: AppColors.roseGoldSurface,
        elevation: 0,
        shadowColor: AppColors.roseGoldPrimary.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.roseGoldAccent.withValues(alpha: 0.3)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.roseGoldPrimary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.roseGoldPrimary,
          side: const BorderSide(color: AppColors.roseGoldPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.roseGoldPrimary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.roseGoldSurface,
        selectedItemColor: AppColors.roseGoldPrimary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption(color: AppColors.roseGoldPrimary),
        unselectedLabelStyle: AppTypography.caption(),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.roseGoldPrimary,
        inactiveTrackColor: AppColors.roseGoldPrimary.withValues(alpha: 0.2),
        thumbColor: AppColors.roseGoldPrimary,
        overlayColor: AppColors.roseGoldPrimary.withValues(alpha: 0.15),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.roseGoldPrimary;
          }
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.roseGoldPrimary.withValues(alpha: 0.4);
          }
          return AppColors.textTertiary.withValues(alpha: 0.25);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.roseGoldPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.softRoseLight,
        labelStyle: AppTypography.caption(color: AppColors.roseGoldPrimary),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.roseGoldSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.roseGoldAccent.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.roseGoldPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: AppTypography.bodyMedium(color: AppColors.textTertiary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.roseGoldPrimary,
        linearTrackColor: AppColors.roseGoldPrimary.withValues(alpha: 0.2),
        circularTrackColor: AppColors.roseGoldPrimary.withValues(alpha: 0.2),
      ),
    );
  }

  /// Olive & Cream theme - Premium natural elegance
  static ThemeData oliveCreamTheme() {
    return lightTheme().copyWith(
      primaryColor: AppColors.oliveGreen,
      scaffoldBackgroundColor: AppColors.oliveCream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.oliveGreen,
        primaryContainer: AppColors.oliveAccent,
        secondary: AppColors.oliveLight,
        secondaryContainer: AppColors.oliveAccent,
        tertiary: AppColors.premiumGold,
        surface: Colors.white,
        surfaceContainerHighest: AppColors.oliveCream,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        outline: AppColors.divider,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.oliveCream,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.heading2(),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: AppColors.oliveGreen.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.oliveAccent.withValues(alpha: 0.5)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.oliveGreen,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.oliveGreen,
          side: const BorderSide(color: AppColors.oliveGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.oliveGreen,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.oliveGreen,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption(color: AppColors.oliveGreen),
        unselectedLabelStyle: AppTypography.caption(),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.oliveGreen,
        inactiveTrackColor: AppColors.oliveGreen.withValues(alpha: 0.2),
        thumbColor: AppColors.oliveGreen,
        overlayColor: AppColors.oliveGreen.withValues(alpha: 0.15),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.oliveGreen;
          }
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.oliveGreen.withValues(alpha: 0.4);
          }
          return AppColors.textTertiary.withValues(alpha: 0.25);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.oliveGreen;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.oliveAccent,
        labelStyle: AppTypography.caption(color: AppColors.oliveGreen),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.oliveCream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.oliveAccent.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.oliveGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: AppTypography.bodyMedium(color: AppColors.textTertiary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.oliveGreen,
        linearTrackColor: AppColors.oliveGreen.withValues(alpha: 0.2),
        circularTrackColor: AppColors.oliveGreen.withValues(alpha: 0.2),
      ),
    );
  }

  /// Get theme by mode
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return lightTheme();
      case AppThemeMode.dark:
        return darkTheme();
      case AppThemeMode.roseGold:
        return roseGoldTheme();
      case AppThemeMode.oliveCream:
        return oliveCreamTheme();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light mode
  static const bgLight = Color(0xFFFAF8F4);
  static const bgCardLight = Color(0xFFFFFFFF);
  static const bgSubtleLight = Color(0xFFF2EFE9);
  static const textPrimaryLight = Color(0xFF1C1917);
  static const textSecondaryLight = Color(0xFF78716C);
  static const textTertiaryLight = Color(0xFFA8A29E);
  static const borderLight = Color(0xFFE7E2DA);
  static const borderSubtleLight = Color(0xFFF0EDE7);

  // Dark mode
  static const bgDark = Color(0xFF100F0D);
  static const bgCardDark = Color(0xFF1A1916);
  static const bgSubtleDark = Color(0xFF242220);
  static const textPrimaryDark = Color(0xFFF5F0E8);
  static const textSecondaryDark = Color(0xFF9C9590);
  static const textTertiaryDark = Color(0xFF6B6560);
  static const borderDark = Color(0xFF2E2B27);
  static const borderSubtleDark = Color(0xFF252220);

  // Shared
  static const gold = Color(0xFFB8860B);
  static const goldLight = Color(0xFFC9A84C);
  static const goldSubtle = Color(0xFFFEF3C7);
  static const goldDark = Color(0xFF92701A);

  static const success = Color(0xFF4A7C59);
  static const successBg = Color(0xFFECF4EF);
  static const warning = Color(0xFFB8860B);
  static const warningBg = Color(0xFFFEF3C7);
  static const danger = Color(0xFF9B3A3A);
  static const dangerBg = Color(0xFFFDECEC);

  static const successDark = Color(0xFF6AAF82);
  static const successBgDark = Color(0xFF0F2A18);
  static const warningDark = Color(0xFFC9A84C);
  static const warningBgDark = Color(0xFF2A1E00);
  static const dangerDark = Color(0xFFD07070);
  static const dangerBgDark = Color(0xFF2A0F0F);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      // Cormorant Garamond for display/headings
      displayLarge: GoogleFonts.cormorantGaramond(
        fontSize: 48, fontWeight: FontWeight.w300,
        color: primary, letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        fontSize: 36, fontWeight: FontWeight.w300,
        color: primary, letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.cormorantGaramond(
        fontSize: 28, fontWeight: FontWeight.w400,
        color: primary,
      ),
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 24, fontWeight: FontWeight.w500,
        color: primary,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 20, fontWeight: FontWeight.w500,
        color: primary,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 18, fontWeight: FontWeight.w500,
        color: primary,
      ),
      // DM Sans for body
      titleLarge: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 13, fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: primary, height: 1.6,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: primary, height: 1.5,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 11, fontWeight: FontWeight.w400,
        color: secondary, height: 1.4,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: primary, letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 10, fontWeight: FontWeight.w400,
        color: secondary, letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData light() {
    const bg = AppColors.bgLight;
    const card = AppColors.bgCardLight;
    const primary = AppColors.textPrimaryLight;
    const secondary = AppColors.textSecondaryLight;
    const border = AppColors.borderLight;
    const gold = AppColors.gold;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.light(
        primary: gold,
        secondary: gold,
        surface: card,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: primary,
        outline: border,
      ),
      textTheme: _buildTextTheme(primary, secondary),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 18, fontWeight: FontWeight.w500,
          color: primary, letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: primary, size: 20),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: gold,
        unselectedItemColor: secondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 10),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: border, thickness: 0.5, space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSubtleLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: gold, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: secondary),
        hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiaryLight),
      ),
    );
  }

  static ThemeData dark() {
    const bg = AppColors.bgDark;
    const card = AppColors.bgCardDark;
    const primary = AppColors.textPrimaryDark;
    const secondary = AppColors.textSecondaryDark;
    const border = AppColors.borderDark;
    const gold = AppColors.goldLight;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.dark(
        primary: gold,
        secondary: gold,
        surface: card,
        onPrimary: AppColors.bgDark,
        onSecondary: AppColors.bgDark,
        onSurface: primary,
        outline: border,
      ),
      textTheme: _buildTextTheme(primary, secondary),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 18, fontWeight: FontWeight.w500,
          color: primary, letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: primary, size: 20),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: gold,
        unselectedItemColor: secondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 10),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: border, thickness: 0.5, space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSubtleDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: gold, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: secondary),
        hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textTertiaryDark),
      ),
    );
  }
}

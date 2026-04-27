import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color gold = Color(0xFFBFA060);
  static const Color goldLight = Color(0xFFD4B87A);
  static const Color goldDark = Color(0xFF8C7040);
  static const Color cream = Color(0xFFFFF8EC);
  static const Color creamDark = Color(0xFFF5ECD7);
  static const Color darkBrown = Color(0xFF2C1A0E);
  static const Color brown = Color(0xFF5C3D1E);
  static const Color rosePink = Color(0xFFE8B4B8);
  static const Color roseLight = Color(0xFFFDE8EA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A0F00);
  static const Color textMedium = Color(0xFF6B4C2A);
  static const Color textLight = Color(0xFF9E7A54);
  static const Color success = Color(0xFF4CAF50);
  static const Color divider = Color(0xFFE8D5B7);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        primary: gold,
        secondary: rosePink,
        surface: cream,
        onPrimary: white,
      ),
      scaffoldBackgroundColor: cream,
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32, fontWeight: FontWeight.w700, color: darkBrown,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 26, fontWeight: FontWeight.w700, color: darkBrown,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20, fontWeight: FontWeight.w700, color: darkBrown,
        ),
        headlineSmall: GoogleFonts.cairo(
          fontSize: 18, fontWeight: FontWeight.w600, color: darkBrown,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16, fontWeight: FontWeight.w400, color: textDark,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14, fontWeight: FontWeight.w400, color: textMedium,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 16, fontWeight: FontWeight.w600, color: white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20, fontWeight: FontWeight.w700, color: darkBrown,
        ),
        iconTheme: const IconThemeData(color: darkBrown),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.cairo(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        labelStyle: GoogleFonts.cairo(color: textMedium),
        hintStyle: GoogleFonts.cairo(color: textLight),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class SirajTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SirajColors.sirajBrown700,
        primary: SirajColors.sirajBrown700,
        secondary: SirajColors.nude300,
        surface: SirajColors.beige100,
        background: SirajColors.beige50,
        error: SirajColors.errorRed,
      ),
      fontFamily: GoogleFonts.cairo().fontFamily,
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: SirajColors.beige100,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
        backgroundColor: SirajColors.accentGold,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: SirajColors.beige50,
        foregroundColor: SirajColors.sirajBrown900,
        elevation: 0,
        titleTextStyle: GoogleFonts.cairo(
          color: SirajColors.sirajBrown900,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

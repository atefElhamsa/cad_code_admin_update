import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Light Theme Colors
  static const Color primaryAccent = Color(0xFF4F46E5); // Modern Indigo
  static const Color primaryAccentLight = Color(0xFFE0E7FF);

  static const Color backgroundLight = Color(0xFFF3F4F6); // Very light grey
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);

  static const Color borderLight = Color(0xFFE5E7EB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        brightness: Brightness.light,
        surface: surfaceWhite,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: borderLight, thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: textGray,
        textColor: textGray,
        selectedColor: primaryAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

import 'package:moean/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemesManager {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorsManager.background,
    cardColor: Colors.white,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: ColorsManager.themeActiveAccent,
      unselectedItemColor: ColorsManager.textBody,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: GoogleFonts.tajawalTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorsManager.primaryColor,
      surface: ColorsManager.surfacePrimary,
      primary: ColorsManager.primaryAction,
      onPrimary: Colors.white,
      outline: ColorsManager.borderColor,
      onSurface: ColorsManager.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorsManager.backgroundColorLight,
      foregroundColor: ColorsManager.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: ColorsManager.borderColor,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorsManager.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ColorsManager.textBody,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: ColorsManager.themeDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: ColorsManager.themeDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: ColorsManager.themeActiveAccent),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsManager.primaryAction,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorsManager.backgroundDark,
    cardColor: ColorsManager.surfaceDark,
    cardTheme: CardThemeData(
      color: ColorsManager.surfaceDark,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ColorsManager.surfaceDark,
      selectedItemColor: ColorsManager.themeActiveAccent,
      unselectedItemColor: ColorsManager.textBody,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: GoogleFonts.tajawalTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorsManager.primaryColor,
      brightness: Brightness.dark,
      surface: ColorsManager.surfaceDark,
      primary: ColorsManager.primaryAction,
      onPrimary: Colors.white,
      outline: Colors.white24,
      onSurface: ColorsManager.textPrimaryDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorsManager.backgroundDark,
      foregroundColor: ColorsManager.textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: Colors.white24,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorsManager.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ColorsManager.textBody,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: ColorsManager.themeActiveAccent),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsManager.primaryAction,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
  );
}

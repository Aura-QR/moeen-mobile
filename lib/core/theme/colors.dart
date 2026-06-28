import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:flutter/material.dart';

class ColorsManager {
  static bool get isDark => themeCubit.isDarkMode;

  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color themeDarkPrimary = Color(0xFF1E293B);
  static const Color themeActiveAccent = Color(0xFF0E7A5E);
  static const Color themeBackground = Color(0xFFF8FFFC);
  static const Color themeDivider = Color(0xFFE2E8F0);
  static const Color textBody = Color(0xFF64748B);
  static const Color themePink = Color(0xFFD61F69);
  static const Color textPrimaryLight = themeDarkPrimary;
  static const Color backgroundColorLight = Color(0xFFF8FFFC);
  static const Color precpictationcardColor = Color(0xFFDB805B);
  static const Color textPrimaryDark = Color(0xFFF4FFFC);
  static const Color backgroundDark = Color(0xFF071C18);
  static const Color surfaceDark = Color(0xFF0D2A24);
  static const Color primaryDark = Color(0xFF24B998);
  static const Color goldDark = Color(0xFFE2AD3B);
  static const Color mutedDark = Color(0xFF9CB8B0);
 static const Color textSecondaryDark = Color(0xFF075244);
  static Color get primaryColor => isDark ? primaryDark : themeActiveAccent;
  static Color get secondaryColor => isDark ? goldDark : const Color(0xFFE2AD3B);
  static Color get placeholder => isDark ? mutedDark : textBody;
  static const Color yellowBackground = Color(0xFFF4F424);
  static const Color buttomBackground = Color(0xFFB8BEA6);
  static const Color errorColor = Color(0xffBA1A1A);
  static const Color successColor = Color(0xFF16A34A);
  
  // UI Kit Colors for Schedule Screen
  static const Color statusSuccess = Color(0xFF22C55E);
  static const Color statusWarning = Color(0xFFF97316);
  static const Color statusWaiting = Color(0xFF3B82F6);
  static const Color statusActivity = Color(0xFF8B5CF6);
  static const Color brandMint = Color(0xFFCFF3EE);
  static const Color brandGold = Color(0xFFF5B25A);
  static Color get scheduleBackground => isDark ? backgroundDark : const Color(0xFFF6FAF9);
  static Color get mainText => isDark ? textPrimaryDark : const Color(0xFF111827);
  static Color get secondaryText => isDark ? mutedDark : const Color(0xFF6B7280);
  static Color get borderLightGray => isDark ? white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB);
 
  static Color get background => isDark ? backgroundDark : backgroundColorLight;
  static Color get textPrimary => isDark ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary => textPrimary;
  static Color get surfacePrimary => isDark ? surfaceDark : white;
  static Color get primaryAction => primaryColor;

  static const Color borderLight = themeDivider;
  static Color get borderColor => isDark ? white.withValues(alpha: 0.24) : borderLight;

  // 135deg Gold Gradient Colors
  static const Color goldLight = Color(0xFFF5D76E);

  static const Color goldMedium = Color(0xFFC9A227);


  // Prescriptions Feature Colors
  static Color get prescriptionSearchBackground =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  static Color get prescriptionCardGreen => primaryColor;
  static Color get prescriptionCardOrange => const Color(0xFFEA580C);
  static Color get prescriptionCardOrangeBg =>
      isDark ? const Color(0xFF431407) : const Color(0xFFFFF7ED);
  static Color get prescriptionCardBlue => const Color(0xFF0EA5E9);
  static Color get prescriptionCardBlueBg =>
      isDark ? const Color(0xFF0C4A6E) : const Color(0xFFF0F9FF);
  static Color get prescriptionListGrey =>
      isDark ? surfaceDark : const Color(0xFFF8FAFC);
}

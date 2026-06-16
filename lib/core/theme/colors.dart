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
  static const Color primaryColor = themeActiveAccent;
  static const Color secondaryColor = Color(0xFFE2AD3B);
  static const Color placeholder = textBody;
  static const Color textPrimaryLight = themeDarkPrimary;
  static const Color backgroundColorLight = Color(0xFFF8FFFC);
  static const Color precpictationcardColor = Color(0xFFDB805B);
  static const Color textPrimaryDark = Color(0xFFE6E9EF);
  static const Color backgroundDark = Color(0xFF0B1215);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color yellowBackground = Color(0xFFF4F424);
  static const Color buttomBackground = Color(0xFFB8BEA6);
  static const Color errorColor = Color(0xffBA1A1A);
  static const Color successColor = Color(0xFF16A34A);
 
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
import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ChoseAppHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const ChoseAppHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Top decorative pill
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        verticalSpace28,
        // Icon badge
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorsManager.primaryColor,
                ColorsManager.primaryColor.withValues(alpha: 0.70),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primaryColor.withValues(alpha: 0.30),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        verticalSpace20,
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStylesManager.bold22.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        verticalSpace8,
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.secondaryText,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class NoDataWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const NoDataWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.search_off_rounded,
              size: 64,
              color: ColorsManager.primaryColor.withValues(alpha: 0.5),
            ),
          ),
          verticalSpace24,
          Text(
            title,
            style: TextStylesManager.bold18,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            verticalSpace8,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                subtitle!,
                style: TextStylesManager.regular14.copyWith(
                  color: ColorsManager.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

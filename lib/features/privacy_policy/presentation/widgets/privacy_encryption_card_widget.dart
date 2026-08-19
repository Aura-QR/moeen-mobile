import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PrivacyEncryptionCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PrivacyEncryptionCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: ColorsManager.primaryColor,
              size: 24,
            ),
          ),
          verticalSpace12,
          Text(
            title,
            style: TextStylesManager.bold14.copyWith(
              color: ColorsManager.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace6,
          Text(
            description,
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.placeholder,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

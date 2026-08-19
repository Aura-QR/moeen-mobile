import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

class PrivacyTagBadgeWidget extends StatelessWidget {
  final String label;

  const PrivacyTagBadgeWidget({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStylesManager.bold12.copyWith(
          color: ColorsManager.primaryColor,
        ),
      ),
    );
  }
}

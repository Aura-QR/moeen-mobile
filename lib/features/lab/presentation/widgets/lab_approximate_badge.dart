import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

class LabApproximateBadge extends StatelessWidget {
  const LabApproximateBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsManager.placeholder.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        appTranslation().get('lab_approximate_tag'),
        style: TextStylesManager.medium10.copyWith(
          color: ColorsManager.secondaryText,
        ),
      ),
    );
  }
}

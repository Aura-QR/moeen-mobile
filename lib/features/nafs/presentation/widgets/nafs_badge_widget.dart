import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

class NafsBadgeWidget extends StatelessWidget {
  const NafsBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        appTranslation().get('nafs_badge'),
        style: TextStylesManager.bold12.copyWith(
          color: ColorsManager.primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

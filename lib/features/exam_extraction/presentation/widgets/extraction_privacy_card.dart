import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ExtractionPrivacyCard extends StatelessWidget {
  const ExtractionPrivacyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.statusWarning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsManager.statusWarning.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: ColorsManager.statusWarning,
            size: 22,
          ),
          horizontalSpace10,
          Expanded(
            child: Text(
              appTranslation().get('exam_extract_privacy_note'),
              style: TextStylesManager.medium13.copyWith(
                color: ColorsManager.mainText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

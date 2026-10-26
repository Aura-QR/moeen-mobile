import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ExtractionSourceContentBanner extends StatelessWidget {
  const ExtractionSourceContentBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: ColorsManager.primaryColor,
            size: 20,
          ),
          horizontalSpace10,
          Expanded(
            child: Text(
              appTranslation().get('exam_extract_source_content'),
              style: TextStylesManager.medium12.copyWith(
                color: ColorsManager.mainText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

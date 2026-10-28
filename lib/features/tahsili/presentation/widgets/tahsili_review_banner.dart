import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class TahsiliReviewBanner extends StatelessWidget {
  const TahsiliReviewBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColorsManager.statusWarning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsManager.statusWarning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.announcement_outlined,
            size: 20,
            color: ColorsManager.statusWarning,
          ),
          horizontalSpace8,
          Expanded(
            child: Text(
              appTranslation().get('tahsili_review_hint'),
              style: TextStylesManager.bold13.copyWith(
                color: ColorsManager.statusWarning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

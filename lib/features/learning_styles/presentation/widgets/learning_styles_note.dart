import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// The standing reminder that results are preferences, not fixed labels.
class LearningStylesNote extends StatelessWidget {
  const LearningStylesNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.statusActivity.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsManager.statusActivity.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: ColorsManager.statusActivity),
          horizontalSpace8,
          Expanded(
            child: Text(
              appTranslation().get('learning_styles_preferences_note'),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.mainText),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ExtractionMissingAnswersBanner extends StatelessWidget {
  final int count;

  const ExtractionMissingAnswersBanner({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColorsManager.statusWarning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsManager.statusWarning.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: ColorsManager.statusWarning,
            size: 20,
          ),
          horizontalSpace10,
          Expanded(
            child: Text(
              appTranslation()
                  .get('exam_extract_missing_answers')
                  .replaceAll('{n}', '$count'),
              style: TextStylesManager.bold13.copyWith(
                color: ColorsManager.mainText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

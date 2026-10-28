import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// «الوحدة 2 من 5» progress while «✨ اقترح النواتج» runs over the units.
class OutcomesMapAiProgress extends StatelessWidget {
  final int current;
  final int total;

  const OutcomesMapAiProgress({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? null : (current / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            horizontalSpace10,
            Expanded(
              child: Text(
                appTranslation()
                    .get('outcomes_map_ai_progress')
                    .replaceFirst('{current}', '$current')
                    .replaceFirst('{total}', '$total'),
                style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
              ),
            ),
          ],
        ),
        verticalSpace8,
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: ColorsManager.borderLightGray,
            valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primaryColor),
          ),
        ),
      ],
    );
  }
}

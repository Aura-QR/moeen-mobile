import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// One domain of the summary: its periods, and a soft warning when it has none.
class ActivitiesSummaryRow extends StatelessWidget {
  final String label;
  final int periods;
  final bool isWarning;

  const ActivitiesSummaryRow({super.key, required this.label, required this.periods, required this.isWarning});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText)),
              ),
              Text(
                '$periods',
                style: TextStylesManager.bold13.copyWith(
                  color: isWarning ? ColorsManager.secondaryColor : ColorsManager.mainText,
                ),
              ),
            ],
          ),
          if (isWarning) ...[
            verticalSpace2,
            Text(
              appTranslation().get('activities_plan_summary_empty_domain'),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryColor),
            ),
          ],
        ],
      ),
    );
  }
}

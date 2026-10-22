import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_result.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';

/// How the grades spread over the levels, one bar each.
class GradeBandBars extends StatelessWidget {
  final List<GradeBandCount> bands;

  const GradeBandBars({super.key, required this.bands});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final band in bands)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 86,
                  child: Text(
                    band.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStylesManager.medium12.copyWith(color: ColorsManager.mainText),
                  ),
                ),
                horizontalSpace8,
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (band.percent / 100).clamp(0, 1),
                      minHeight: 14,
                      color: ColorsManager.primaryColor,
                      backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                horizontalSpace8,
                SizedBox(
                  width: 64,
                  child: Text(
                    '${band.count} · ${formatGrade(band.percent)}%',
                    textAlign: TextAlign.end,
                    style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

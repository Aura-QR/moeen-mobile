import 'dart:math';

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/data/models/achievement_report_model.dart';

/// Lessons prepared per day, as plain bars.
class AchievementDayChartWidget extends StatelessWidget {
  final List<AchievementDayModel> days;

  const AchievementDayChartWidget({super.key, required this.days});

  static const double _chartHeight = 120;

  @override
  Widget build(BuildContext context) {
    final maxValue = days.fold<int>(0, (current, day) => max(current, day.lessonsPrepared));
    // A month has ~30 bars; label every 5th day so the numbers don't collide.
    final labelEvery = days.length > 10 ? 5 : 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appTranslation().get('achievement_chart_title'),
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
          ),
          verticalSpace16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < days.length; i++)
                Expanded(
                  child: Tooltip(
                    message: '${days[i].lessonsPrepared}',
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          margin: EdgeInsets.symmetric(horizontal: days.length > 10 ? 1 : 6),
                          height: maxValue == 0 ? 3 : max(3, _chartHeight * days[i].lessonsPrepared / maxValue),
                          decoration: BoxDecoration(
                            color: days[i].lessonsPrepared == 0
                                ? ColorsManager.primaryColor.withValues(alpha: 0.15)
                                : ColorsManager.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        verticalSpace6,
                        Text(
                          (i % labelEvery == 0) ? '${days[i].date.day}' : '',
                          style: TextStylesManager.regular10.copyWith(color: ColorsManager.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/data/models/achievement_report_model.dart';
import 'package:moean/features/reports/presentation/widgets/achievement_day_chart_widget.dart';
import 'package:moean/features/reports/presentation/widgets/achievement_lesson_tile_widget.dart';
import 'package:moean/features/reports/presentation/widgets/achievement_totals_grid_widget.dart';

/// Totals, the per-day chart and the lessons list for one period.
class AchievementReportContentWidget extends StatelessWidget {
  final AchievementReportModel report;

  const AchievementReportContentWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AchievementTotalsGridWidget(totals: report.totals),
        verticalSpace16,
        if (report.byDay.isNotEmpty) ...[
          AchievementDayChartWidget(days: report.byDay),
          verticalSpace20,
        ],
        Text(
          appTranslation().get('achievement_lessons'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
        verticalSpace10,
        if (report.lessons.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              appTranslation().get('achievement_no_lessons'),
              textAlign: TextAlign.center,
              style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
            ),
          ),
        for (final lesson in report.lessons)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AchievementLessonTileWidget(lesson: lesson),
          ),
      ],
    );
  }
}

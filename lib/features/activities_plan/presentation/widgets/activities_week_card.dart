import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';

/// A teaching or exam week: its number and dates, then its cells.
/// Exam weeks are shaded and show their title, with only «المناسبات».
class ActivitiesWeekCard extends StatelessWidget {
  final ActivitiesWeekModel week;
  final List<Widget> cells;

  const ActivitiesWeekCard({super.key, required this.week, required this.cells});

  @override
  Widget build(BuildContext context) {
    final isExam = week.type == ActivitiesWeekType.exam;
    final hijri = week.hijriRange;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExam ? ColorsManager.secondaryColor.withValues(alpha: 0.06) : ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appTranslation().get('activities_plan_week_n').replaceAll('{week}', '${week.week}'),
                  style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hijri != null)
                      Text(hijri, style: TextStylesManager.medium12.copyWith(color: ColorsManager.mainText)),
                    Text(
                      week.gregorianRange,
                      style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isExam) ...[
            verticalSpace8,
            Text(
              week.title.isEmpty ? appTranslation().get('activities_plan_exams') : week.title,
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
            ),
          ],
          ...cells,
        ],
      ),
    );
  }
}

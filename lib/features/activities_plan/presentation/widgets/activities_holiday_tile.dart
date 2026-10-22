import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';

/// A holiday: one shaded row with its title and dates; nothing to edit.
class ActivitiesHolidayTile extends StatelessWidget {
  final ActivitiesWeekModel week;

  const ActivitiesHolidayTile({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.secondaryText.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.beach_access_outlined, size: 20, color: ColorsManager.secondaryText),
          horizontalSpace10,
          Expanded(
            child: Text(
              week.title.isEmpty ? appTranslation().get('activities_plan_holiday') : week.title,
              style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
            ),
          ),
          Text(
            week.hijriRange ?? week.gregorianRange,
            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
          ),
        ],
      ),
    );
  }
}

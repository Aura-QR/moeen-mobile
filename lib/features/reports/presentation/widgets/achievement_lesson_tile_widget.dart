import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/data/models/achievement_report_model.dart';
import 'package:moean/features/reports/presentation/utils/achievement_date_format.dart';

class AchievementLessonTileWidget extends StatelessWidget {
  final AchievementLessonModel lesson;

  const AchievementLessonTileWidget({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final completedAt = lesson.completedAt;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: ColorsManager.successColor, size: 22),
          horizontalSpace10,
          Expanded(
            child: Text(
              lesson.title,
              style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
            ),
          ),
          if (completedAt != null)
            Text(
              '${formatDayMonth(completedAt, appTranslation().get)} · ${formatTime(completedAt)}',
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
        ],
      ),
    );
  }
}

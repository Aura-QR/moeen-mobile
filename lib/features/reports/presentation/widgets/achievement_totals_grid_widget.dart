import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/reports/data/models/achievement_report_model.dart';
import 'package:moean/features/reports/presentation/widgets/achievement_total_card_widget.dart';

class AchievementTotalsGridWidget extends StatelessWidget {
  final AchievementTotalsModel totals;

  const AchievementTotalsGridWidget({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (Icons.menu_book_rounded, ColorsManager.primaryColor, 'achievement_lessons_prepared', totals.lessonsPrepared),
      (Icons.fact_check_outlined, ColorsManager.statusWaiting, 'achievement_exams', totals.exams),
      (Icons.co_present_rounded, ColorsManager.statusActivity, 'achievement_presentations', totals.presentations),
      (Icons.description_outlined, ColorsManager.statusWarning, 'achievement_worksheets', totals.worksheets),
      (Icons.insights_rounded, ColorsManager.themePink, 'achievement_educational_reports', totals.educationalReports),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.1,
      children: [
        for (final (icon, color, labelKey, value) in cards)
          AchievementTotalCardWidget(icon: icon, color: color, label: appTranslation().get(labelKey), value: value),
      ],
    );
  }
}

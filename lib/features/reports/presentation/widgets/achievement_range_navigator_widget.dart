import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/reports/presentation/cubit/achievement_report_cubit.dart';
import 'package:moean/features/reports/presentation/utils/achievement_date_format.dart';

/// Arrows for the previous and next period around «من … إلى …».
class AchievementRangeNavigatorWidget extends StatelessWidget {
  const AchievementRangeNavigatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementReportCubit, AchievementReportState>(
      buildWhen: (previous, current) =>
          previous.report != current.report || previous.canGoNext != current.canGoNext,
      builder: (context, state) {
        final cubit = AchievementReportCubit.get(context);
        final report = state.report;
        // In RTL the start-side arrow points right and goes back in time.
        return Row(
          children: [
            IconButton.filledTonal(
              onPressed: cubit.previous,
              icon: const Icon(Icons.chevron_left_rounded),
              style: IconButton.styleFrom(
                backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.08),
                foregroundColor: ColorsManager.primaryColor,
              ),
              tooltip: appTranslation().get('achievement_previous'),
            ),
            Expanded(
              child: Text(
                report == null ? '' : formatAchievementRange(report.from, report.to, appTranslation().get),
                textAlign: TextAlign.center,
                style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
              ),
            ),
            IconButton.filledTonal(
              onPressed: state.canGoNext ? cubit.next : null,
              icon: const Icon(Icons.chevron_right_rounded),
              style: IconButton.styleFrom(
                backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.08),
                foregroundColor: ColorsManager.primaryColor,
              ),
              tooltip: appTranslation().get('achievement_next'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/reports/data/models/achievement_period.dart';
import 'package:moean/features/reports/presentation/cubit/achievement_report_cubit.dart';

/// يومي / أسبوعي / شهري.
class AchievementPeriodSelectorWidget extends StatelessWidget {
  const AchievementPeriodSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AchievementReportCubit, AchievementReportState, AchievementPeriod>(
      selector: (state) => state.period,
      builder: (context, period) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorsManager.borderLightGray),
        ),
        child: Row(
          children: [
            for (final option in AchievementPeriod.values)
              Expanded(
                child: GestureDetector(
                  onTap: () => AchievementReportCubit.get(context).changePeriod(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: option == period ? ColorsManager.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appTranslation().get(option.labelKey),
                      textAlign: TextAlign.center,
                      style: TextStylesManager.bold14.copyWith(
                        color: option == period ? ColorsManager.white : ColorsManager.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';

/// Shown on a plan saved before the official layout: it opens as it was, with
/// a way to start a new plan from the 1448 guide.
class ActivitiesLegacyNote extends StatelessWidget {
  const ActivitiesLegacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ActivitiesPlanCubit, ActivitiesPlanState, bool>(
      selector: (state) => state.isLegacy,
      builder: (context, isLegacy) {
        if (!isLegacy) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColorsManager.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ColorsManager.secondaryColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appTranslation().get('activities_plan_legacy_note'),
                  style: TextStylesManager.regular13.copyWith(color: ColorsManager.mainText),
                ),
                verticalSpace10,
                PrimaryElevatedButton(
                  text: appTranslation().get('activities_plan_legacy_button'),
                  height: 44,
                  onPressed: () => Navigator.pushReplacementNamed(context, Routes.activitiesPlan),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

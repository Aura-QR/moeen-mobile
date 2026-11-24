import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';

/// The old layout's stage, shown only for a plan saved before the official one.
class ActivitiesStageField extends StatelessWidget {
  const ActivitiesStageField({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return BlocBuilder<ActivitiesPlanCubit, ActivitiesPlanState>(
      buildWhen: (previous, current) => previous.stage != current.stage,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appTranslation().get('activities_plan_field_stage'),
            style: TextStylesManager.medium13.copyWith(color: ColorsManager.secondaryText),
          ),
          verticalSpace8,
          PrimaryChoiceChips(
            options: state.catalogue.stages,
            labelOf: (stage) => stage.label,
            isSelected: (stage) => stage.key == state.stage,
            onTap: (stage) => cubit.setStage(stage.key),
          ),
        ],
      ),
    );
  }
}

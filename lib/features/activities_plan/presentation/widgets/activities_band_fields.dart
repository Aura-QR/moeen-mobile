import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_number_stepper.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';

/// The official layout's band (4 choices) and the periods per week, which a
/// band prefills with its default.
class ActivitiesBandFields extends StatelessWidget {
  const ActivitiesBandFields({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return BlocBuilder<ActivitiesPlanCubit, ActivitiesPlanState>(
      buildWhen: (previous, current) =>
          previous.band != current.band ||
          previous.periodsPerWeek != current.periodsPerWeek ||
          previous.catalogue != current.catalogue,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appTranslation().get('activities_plan_field_band'),
            style: TextStylesManager.medium13.copyWith(color: ColorsManager.secondaryText),
          ),
          verticalSpace8,
          PrimaryChoiceChips(
            options: state.catalogue.bands,
            labelOf: (band) => band.label,
            isSelected: (band) => band.key == state.band,
            onTap: (band) => cubit.setBand(band.key),
          ),
          verticalSpace16,
          PrimaryNumberStepper(
            label: appTranslation().get('activities_plan_field_periods_per_week'),
            value: state.effectivePeriodsPerWeek,
            min: 1,
            max: 6,
            onChanged: cubit.setPeriodsPerWeek,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/data/models/activities_plan_input.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_option_selector.dart';

/// «إعدادات الخطة»: المرحلة، الفصل الدراسي، التقويم.
class ActivitiesSettingsSection extends StatelessWidget {
  const ActivitiesSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.tune_rounded,
      title: appTranslation().get('activities_plan_section_settings'),
      child: BlocBuilder<ActivitiesPlanCubit, ActivitiesPlanState>(
        buildWhen: (previous, current) =>
            previous.stage != current.stage ||
            previous.term != current.term ||
            previous.effectiveRegion != current.effectiveRegion ||
            previous.grid?.regionVerified != current.grid?.regionVerified,
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
            verticalSpace16,
            DocumentOptionSelector<int>(
              label: appTranslation().get('activities_plan_field_term'),
              options: const [1, 2],
              selected: state.term,
              labelKeyOf: (term) => 'activities_plan_term_$term',
              onChanged: cubit.setTerm,
            ),
            verticalSpace16,
            DocumentOptionSelector<String>(
              label: appTranslation().get('activities_plan_field_region'),
              options: const [ActivitiesPlanInput.general, ActivitiesPlanInput.western],
              selected: state.effectiveRegion,
              labelKeyOf: (region) => 'activities_plan_region_$region',
              onChanged: cubit.setRegion,
            ),
            if (state.grid?.regionVerified == false) ...[
              verticalSpace8,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: ColorsManager.secondaryColor),
                  horizontalSpace6,
                  Expanded(
                    child: Text(
                      appTranslation().get('activities_plan_region_unverified'),
                      style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

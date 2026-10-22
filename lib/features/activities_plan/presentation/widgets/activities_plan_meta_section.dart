import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';

/// «رائد/رائدة النشاط» and «العام الدراسي».
class ActivitiesPlanMetaSection extends StatelessWidget {
  const ActivitiesPlanMetaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.manage_accounts_outlined,
      title: appTranslation().get('activities_plan_section_meta'),
      child: Column(
        children: [
          PrimaryTextField(
            controller: cubit.activityLeaderController,
            label: appTranslation().get('activities_plan_field_activity_leader'),
            hint: appTranslation().get('activities_plan_field_activity_leader_hint'),
            maxLength: 120,
          ),
          verticalSpace12,
          PrimaryTextField(
            controller: cubit.academicYearController,
            label: appTranslation().get('activities_plan_field_academic_year'),
            hint: appTranslation().get('activities_plan_field_academic_year_hint'),
            maxLength: 20,
          ),
        ],
      ),
    );
  }
}

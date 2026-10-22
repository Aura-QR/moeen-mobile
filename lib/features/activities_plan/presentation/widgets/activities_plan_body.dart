import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_domains_section.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_grid_section.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_media_and_design_sections.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_plan_header_section.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_plan_meta_section.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_settings_section.dart';
import 'package:moean/features/documents/presentation/widgets/document_notes_section.dart';

/// The form's sections, in the order the document prints them.
class ActivitiesPlanBody extends StatelessWidget {
  const ActivitiesPlanBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const ActivitiesSettingsSection(),
        verticalSpace14,
        const ActivitiesDomainsSection(),
        verticalSpace14,
        const ActivitiesPlanMetaSection(),
        verticalSpace14,
        const ActivitiesPlanHeaderSection(),
        verticalSpace14,
        const ActivitiesGridSection(),
        verticalSpace14,
        DocumentNotesSection(controller: ActivitiesPlanCubit.get(context).notesController),
        verticalSpace14,
        const ActivitiesMediaAndDesignSections(),
      ],
    );
  }
}

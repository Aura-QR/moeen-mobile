import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/plan_ai_suggestions_card.dart';
import 'package:moean/features/documents/presentation/widgets/plan_checklist_sections.dart';
import 'package:moean/features/documents/presentation/widgets/plan_header_section.dart';
import 'package:moean/features/documents/presentation/widgets/plan_info_section.dart';
import 'package:moean/features/documents/presentation/widgets/plan_lessons_section.dart';
import 'package:moean/features/documents/presentation/widgets/plan_media_and_design_sections.dart';
import 'package:moean/features/documents/presentation/widgets/document_notes_section.dart';
import 'package:moean/features/documents/presentation/widgets/plan_students_section.dart';
import 'package:moean/features/enrichment_plan/presentation/widgets/enrichment_target_groups_section.dart';

/// The enrichment plan's sections: like the remedial plan, without the plan
/// type and the improvement level, and with «الفئة المستهدفة».
class EnrichmentPlanBody extends StatelessWidget {
  const EnrichmentPlanBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Lessons are optional here and only enable the AI suggestions.
        const PlanLessonsSection(),
        const PlanInfoSection(),
        verticalSpace14,
        const EnrichmentTargetGroupsSection(),
        verticalSpace14,
        const PlanHeaderSection(),
        verticalSpace14,
        const PlanStudentsSection(),
        verticalSpace14,
        const PlanAiSuggestionsCard(),
        const PlanChecklistSections(),
        DocumentNotesSection(controller: PlanFormCubit.get(context).notesController),
        verticalSpace14,
        const PlanMediaAndDesignSections(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/plan_ai_suggestions_card.dart';
import 'package:moean/features/documents/presentation/widgets/plan_checklist_sections.dart';
import 'package:moean/features/documents/presentation/widgets/plan_header_section.dart';
import 'package:moean/features/documents/presentation/widgets/plan_info_section.dart';
import 'package:moean/features/documents/presentation/widgets/plan_lessons_section.dart';
import 'package:moean/features/documents/presentation/widgets/plan_media_and_design_sections.dart';
import 'package:moean/features/documents/presentation/widgets/plan_notes_section.dart';
import 'package:moean/features/documents/presentation/widgets/plan_students_section.dart';
import 'package:moean/features/remedial_plan/presentation/widgets/remedial_improvement_section.dart';
import 'package:moean/features/remedial_plan/presentation/widgets/remedial_plan_type_section.dart';

/// The remedial plan's sections, in the order the task lists them.
class RemedialPlanBody extends StatelessWidget {
  const RemedialPlanBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const RemedialPlanTypeSection(),
        verticalSpace14,
        // Each adds its own spacing, since either can be hidden.
        const PlanLessonsSection(),
        const PlanInfoSection(),
        verticalSpace14,
        const PlanHeaderSection(),
        verticalSpace14,
        const PlanStudentsSection(),
        verticalSpace14,
        const PlanAiSuggestionsCard(),
        const PlanChecklistSections(),
        const RemedialImprovementSection(),
        verticalSpace14,
        const PlanNotesSection(),
        verticalSpace14,
        const PlanMediaAndDesignSections(),
      ],
    );
  }
}

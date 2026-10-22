import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/document_notes_section.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_analysis_header_section.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_bands_section.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_classes_section.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_media_and_design_sections.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_recommendations_section.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_report_section.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_results_section.dart';

/// The report, the classes and their grades, the results, then the rest of the document.
class GradeAnalysisBody extends StatelessWidget {
  const GradeAnalysisBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Scrolling to check the results hides the number keyboard.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const GradeReportSection(),
        verticalSpace14,
        const GradeBandsSection(),
        verticalSpace14,
        const GradeClassesSection(),
        verticalSpace14,
        const GradeResultsSection(),
        verticalSpace14,
        const GradeRecommendationsSection(),
        verticalSpace14,
        const GradeAnalysisHeaderSection(),
        verticalSpace14,
        DocumentNotesSection(controller: GradeAnalysisCubit.get(context).notesController),
        verticalSpace14,
        const GradeMediaAndDesignSections(),
      ],
    );
  }
}

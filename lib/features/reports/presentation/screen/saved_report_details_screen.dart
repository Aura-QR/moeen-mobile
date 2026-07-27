import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/reports/data/report_pdf_service.dart';
import 'package:moean/features/reports/data/saved_report_model.dart';
import 'package:moean/features/reports/presentation/screen/pdf_preview_screen.dart';
import 'package:moean/features/reports/presentation/widgets/report_result_section_widget.dart';

class SavedReportDetailsScreen extends StatelessWidget {
  final SavedReportModel report;
  final String teacherName;

  const SavedReportDetailsScreen({
    super.key,
    required this.report,
    required this.teacherName,
  });

  void _handlePrint(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(
          buildPdf: () => ReportPdfService.generatePdf(
            reportData: report.reportData,
            teacherName: teacherName,
            grade: report.grade,
            subject: report.displaySubject,
            unit: '',
            semester: '',
            schoolName: '',
            educationOffice: '',
            reportType: report.reportType,
            reportDate: report.createdAt.split('T').first,
            selectedLessons: report.selectedLessons,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = report.reportData;
    final List<Map<String, dynamic>> achievementRows =
        List<Map<String, dynamic>>.from(data['achievementRows'] ?? []);
    final List<Map<String, dynamic>> lessonPlanRows =
        List<Map<String, dynamic>>.from(data['lessonPlanRows'] ?? []);
    final List<Map<String, dynamic>> goalRows =
        List<Map<String, dynamic>>.from(data['goalRows'] ?? []);
    final List<Map<String, dynamic>> challengeRows =
        List<Map<String, dynamic>>.from(data['challengeRows'] ?? []);
    final List<Map<String, dynamic>> checkUnderstandingRows =
        List<Map<String, dynamic>>.from(data['checkUnderstandingRows'] ?? []);
    final List<Map<String, dynamic>> modelingRows =
        List<Map<String, dynamic>>.from(data['modelingRows'] ?? []);
    final List<Map<String, dynamic>> strategySections =
        List<Map<String, dynamic>>.from(data['strategySections'] ?? []);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            report.displaySubject,
            style: TextStylesManager.bold16.copyWith(
              color: ColorsManager.mainText,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReportPrintBarWidget(
                  onPrint: () => _handlePrint(context),
                ),
                verticalSpace20,

                if (achievementRows.isNotEmpty)
                  ReportResultSectionWidget(
                    sectionTitle: appTranslation().get('report_achievement_rows'),
                    rows: achievementRows,
                    columnKeys: const ['lesson', 'description', 'participation', 'understanding'],
                    columnLabels: [
                      appTranslation().get('report_col_lesson'),
                      appTranslation().get('report_col_description'),
                      appTranslation().get('report_col_participation'),
                      appTranslation().get('report_col_understanding'),
                    ],
                    initiallyExpanded: true,
                  ),

                if (lessonPlanRows.isNotEmpty)
                  ReportResultSectionWidget(
                    sectionTitle: appTranslation().get('report_lesson_plan_rows'),
                    rows: lessonPlanRows,
                    columnKeys: const ['lesson', 'concepts', 'objectives'],
                    columnLabels: [
                      appTranslation().get('report_col_lesson'),
                      appTranslation().get('report_col_concepts'),
                      appTranslation().get('report_col_objectives'),
                    ],
                  ),

                if (goalRows.isNotEmpty)
                  ReportResultSectionWidget(
                    sectionTitle: appTranslation().get('report_goal_rows'),
                    rows: goalRows,
                    columnKeys: const ['lesson', 'goal', 'targetUnderstanding'],
                    columnLabels: [
                      appTranslation().get('report_col_lesson'),
                      appTranslation().get('report_col_goal'),
                      appTranslation().get('report_col_target'),
                    ],
                  ),

                if (challengeRows.isNotEmpty)
                  ReportResultSectionWidget(
                    sectionTitle: appTranslation().get('report_challenge_rows'),
                    rows: challengeRows,
                    columnKeys: const ['lesson', 'challenge', 'plan'],
                    columnLabels: [
                      appTranslation().get('report_col_lesson'),
                      appTranslation().get('report_col_challenge'),
                      appTranslation().get('report_col_plan'),
                    ],
                  ),

                if (checkUnderstandingRows.isNotEmpty)
                  ReportResultSectionWidget(
                    sectionTitle: appTranslation().get('report_check_understanding_rows'),
                    rows: checkUnderstandingRows,
                    columnKeys: const ['lesson', 'method', 'result'],
                    columnLabels: [
                      appTranslation().get('report_col_lesson'),
                      appTranslation().get('report_col_method'),
                      appTranslation().get('report_col_result'),
                    ],
                  ),

                if (modelingRows.isNotEmpty)
                  ReportResultSectionWidget(
                    sectionTitle: appTranslation().get('report_modeling_rows'),
                    rows: modelingRows,
                    columnKeys: const ['lesson', 'modelingMethod', 'notes'],
                    columnLabels: [
                      appTranslation().get('report_col_lesson'),
                      appTranslation().get('report_col_modeling_method'),
                      appTranslation().get('report_col_notes'),
                    ],
                  ),

                if (strategySections.isNotEmpty)
                  ReportResultSectionWidget(
                    sectionTitle: appTranslation().get('report_strategy_sections'),
                    rows: strategySections,
                    columnKeys: const ['strategy', 'description', 'appliedLessons'],
                    columnLabels: [
                      appTranslation().get('report_col_strategy'),
                      appTranslation().get('report_col_description'),
                      appTranslation().get('report_col_applied_lessons'),
                    ],
                  ),

                verticalSpace32,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

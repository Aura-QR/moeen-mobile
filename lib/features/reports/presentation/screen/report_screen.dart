import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/local/cache_helper.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/reports/data/report_pdf_service.dart';
import 'package:moean/features/reports/presentation/cubit/report_cubit.dart';
import 'package:moean/features/reports/presentation/cubit/report_state.dart';
import 'package:moean/features/reports/presentation/screen/pdf_preview_screen.dart';
import 'package:moean/features/reports/presentation/screen/saved_reports_screen.dart';
import 'package:moean/features/reports/presentation/widgets/report_form_widget.dart';
import 'package:moean/features/reports/presentation/widgets/report_result_section_widget.dart';
import 'package:moean/features/payment/presentation/widgets/trial_banner_widget.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _teacherName = '';

  // These are stored after submission to pass to PDF generator
  String _lastGrade = '';
  String _lastSubject = '';
  String _lastUnit = '';
  String _lastSemester = '';
  String _lastSchool = '';
  String _lastOffice = '';
  String _lastReportType = '';
  String _lastReportDate = '';
  List<String> _lastLessons = [];

  @override
  void initState() {
    super.initState();
    _loadTeacherName();
  }

  Future<void> _loadTeacherName() async {
    final cached = CacheHelper.getData(key: 'teacher_name');
    if (cached is String && cached.isNotEmpty) {
      setState(() => _teacherName = cached);
      return;
    }
    final result = await ApiService.getProfile();
    result.fold(
      (_) {},
      (profile) {
        final name = profile.user.name;
        CacheHelper.saveData(key: 'teacher_name', value: name);
        if (mounted) setState(() => _teacherName = name);
      },
    );
  }

  void _handlePrint(Map<String, dynamic> reportData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(
          buildPdf: () => ReportPdfService.generatePdf(
            reportData: reportData,
            teacherName: _teacherName,
            grade: _lastGrade,
            subject: _lastSubject,
            unit: _lastUnit,
            semester: _lastSemester,
            schoolName: _lastSchool,
            educationOffice: _lastOffice,
            reportType: _lastReportType,
            reportDate: _lastReportDate,
            selectedLessons: _lastLessons,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportCubit, ReportState>(
      listener: (context, state) {
        if (state is ReportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: TextStylesManager.bold14),
              backgroundColor: ColorsManager.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ReportPaymentRequired) {
          UpgradePromptBottomSheet.show(
            context,
            message: state.message,
            isQuotaExceeded: state.code == 'quota_exceeded',
          );
        }
      },
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: ColorsManager.background,
            appBar: AppBar(
              backgroundColor: ColorsManager.background,
              elevation: 0,
              centerTitle: true,
              title: Text(
                appTranslation().get('report_title'),
                style: TextStylesManager.bold18.copyWith(
                  color: ColorsManager.mainText,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  tooltip: appTranslation().get('saved_reports_subtitle'),
                  icon: Icon(
                    Icons.inventory_2_outlined,
                    color: ColorsManager.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SavedReportsScreen(teacherName: _teacherName),
                      ),
                    );
                  },
                ),
                if (state is ReportSuccess)
                  IconButton(
                    tooltip: appTranslation().get('report_new'),
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: ColorsManager.primaryColor,
                    ),
                    onPressed: () => ReportCubit.get(context).reset(),
                  ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const TrialBannerWidget(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        children: [
                          // Banner link to Saved Reports above the form/results
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SavedReportsScreen(teacherName: _teacherName),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ColorsManager.primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: ColorsManager.primaryColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    color: ColorsManager.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                horizontalSpace10,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appTranslation().get('saved_reports_subtitle'),
                                      style: TextStylesManager.bold14.copyWith(
                                        color: ColorsManager.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      appTranslation().get('saved_reports_desc'),
                                      style: TextStylesManager.regular12.copyWith(
                                        color: ColorsManager.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                              color: ColorsManager.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    verticalSpace16,

                    state is ReportSuccess
                        ? _ReportResultView(
                            data: state.data,
                            teacherName: _teacherName,
                            onPrint: () => _handlePrint(state.data),
                          )
                        : ReportFormWidget(
                            teacherName: _teacherName,
                            isLoading: state is ReportLoading,
                            onSubmit: ({
                              required reportType,
                              required grade,
                              required subject,
                              required unit,
                              required semester,
                              required schoolName,
                              required educationOffice,
                              required reportDate,
                              required selectedLessons,
                            }) {
                              _lastGrade = grade;
                              _lastSubject = subject;
                              _lastUnit = unit;
                              _lastSemester = semester;
                              _lastSchool = schoolName;
                              _lastOffice = educationOffice;
                              _lastReportType = reportType;
                              _lastReportDate = reportDate;
                              _lastLessons = selectedLessons;

                              // For monthly reports, send units as list. For weekly, combine subject and unit.
                              final dynamic apiSubject = reportType == 'شهري'
                                  ? unit.split('،').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                                  : '$subject - $unit';

                              ReportCubit.get(context).generateReport(
                                reportType: reportType,
                                grade: grade,
                                subject: apiSubject,
                                selectedLessons: selectedLessons,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Result view — shown after successful API response
// ─────────────────────────────────────────────────────────────────────

class _ReportResultView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String teacherName;
  final VoidCallback onPrint;

  const _ReportResultView({
    required this.data,
    required this.teacherName,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success header
        _ReportSuccessBanner(teacherName: teacherName),
        verticalSpace16,

        // Print button
        ReportPrintBarWidget(
          onPrint: onPrint,
        ),
        verticalSpace20,

        // Result tables
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
    );
  }
}

class _ReportSuccessBanner extends StatelessWidget {
  final String teacherName;

  const _ReportSuccessBanner({required this.teacherName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryColor.withValues(alpha: 0.12),
            ColorsManager.primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ColorsManager.successColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: ColorsManager.successColor,
              size: 24,
            ),
          ),
          horizontalSpace12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appTranslation().get('report_success_title'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.mainText,
                  ),
                ),
                verticalSpace2,
                Text(
                  appTranslation().get('report_success_subtitle'),
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

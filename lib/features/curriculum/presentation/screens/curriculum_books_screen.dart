import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';
import 'package:moean/features/curriculum/presentation/cubit/curriculum_books_cubit.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';
import 'package:moean/features/curriculum/presentation/widgets/subject_picker_section.dart';
import 'package:moean/features/curriculum/presentation/cubit/curriculum_distribution_cubit.dart';
import 'package:moean/features/curriculum/presentation/widgets/region_legend_row.dart';
import 'package:moean/features/curriculum/presentation/widgets/weeks_grid.dart';
import 'package:moean/features/curriculum/presentation/widgets/inline_books_section.dart';
import 'package:moean/features/curriculum/presentation/widgets/curriculum_error_view.dart';
import 'package:moean/features/curriculum/presentation/widgets/export_pdf_card.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class CurriculumBooksScreen extends StatefulWidget {
  const CurriculumBooksScreen({super.key});

  @override
  State<CurriculumBooksScreen> createState() => _CurriculumBooksScreenState();
}

class _CurriculumBooksScreenState extends State<CurriculumBooksScreen> {
  List<CurriculumStageModel> _stages = [];
  List<CurriculumGradeModel> _grades = [];
  List<CurriculumSubjectModel> _subjects = [];

  CurriculumStageModel? _selectedStage;
  CurriculumGradeModel? _selectedGrade;
  CurriculumSubjectModel? _selectedSubject;
  int _selectedSemester = 1;

  bool _loadingStages = true;
  String? _pickerError;

  @override
  void initState() {
    super.initState();
    _loadStages();
  }

  Future<void> _loadStages() async {
    setState(() {
      _loadingStages = true;
      _pickerError = null;
    });
    final result = await ApiService.getSubjects();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loadingStages = false;
        _pickerError = failure.toString();
      }),
      (stages) => setState(() {
        _stages = stages;
        _loadingStages = false;
      }),
    );
  }

  void _onStageSelected(CurriculumStageModel stage) {
    setState(() {
      _selectedStage = stage;
      _selectedGrade = null;
      _selectedSubject = null;
      _grades = stage.grades;
      _subjects = [];
    });
  }

  void _onGradeSelected(CurriculumGradeModel grade) {
    setState(() {
      _selectedGrade = grade;
      _selectedSubject = null;
      _subjects = grade.subjects;
    });
  }

  void _onSubjectSelected(CurriculumSubjectModel subject) {
    setState(() => _selectedSubject = subject);
    CurriculumBooksCubit.get(context).loadBooks(subjectId: subject.id);
    CurriculumDistributionCubit.get(context).loadPlans(
      subjectId: subject.id,
      semester: _selectedSemester,
    );
  }
  
  void _onSemesterChanged(int s) {
    setState(() => _selectedSemester = s);
    if (_selectedSubject != null) {
      CurriculumDistributionCubit.get(context).loadPlans(
        subjectId: _selectedSubject!.id,
        semester: s,
      );
    }
  }

  String _selectedRegion = 'general';

  Future<void> _exportSemesterPlanPdf({
    required CurriculumPlanDetailModel detail,
    required String school,
    required String teacher,
    required String manager,
  }) async {
    final plan = detail.plan;
    final weeks = detail.weeks;
    final pdf = pw.Document();

    // Load Tajawal fonts for Arabic text rendering
    final fontData = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/Tajawal-Bold.ttf');
    final ttf = pw.Font.ttf(fontData);
    final ttfBold = pw.Font.ttf(boldFontData);

    const int weeksPerPage = 12;
    final int totalPages = (weeks.length / weeksPerPage).ceil().clamp(1, 999);

    for (int i = 0; i < weeks.length; i += weeksPerPage) {
      final pageWeeks = weeks.sublist(
        i,
        (i + weeksPerPage) < weeks.length ? (i + weeksPerPage) : weeks.length,
      );
      final int pageNum = (i ~/ weeksPerPage) + 1;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context ctx) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Header
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'الخطة الفصلية - ${plan.subjectName} - ${plan.gradeName} - الفصل ${plan.semester}',
                          style: pw.TextStyle(font: ttfBold, fontSize: 13),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                          children: [
                            pw.Text('المدرسة: $school', style: pw.TextStyle(font: ttf, fontSize: 9)),
                            pw.Text('المعلم: $teacher', style: pw.TextStyle(font: ttf, fontSize: 9)),
                            pw.Text('المدير: $manager', style: pw.TextStyle(font: ttf, fontSize: 9)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  // Table
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(2),
                      2: const pw.FlexColumnWidth(4),
                      3: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      // Header row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('الأسبوع', style: pw.TextStyle(font: ttfBold, fontSize: 9), textAlign: pw.TextAlign.center)),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('التاريخ', style: pw.TextStyle(font: ttfBold, fontSize: 9), textAlign: pw.TextAlign.center)),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('الدروس', style: pw.TextStyle(font: ttfBold, fontSize: 9), textAlign: pw.TextAlign.center)),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('ملاحظات', style: pw.TextStyle(font: ttfBold, fontSize: 9), textAlign: pw.TextAlign.center)),
                        ],
                      ),
                      // Week rows
                      ...pageWeeks.map((week) {
                        final isSpecial = week.isHoliday || week.isExam;
                        final weekLabel = week.weekNumber != null
                            ? 'أسبوع ${week.weekNumber}'
                            : (week.title ?? (week.isHoliday ? 'إجازة' : 'اختبارات'));
                        final dateLabel = '${week.startsOn} - ${week.endsOn}';
                        final lessons = week.items.map((e) => e.title).join('\n');
                        final notes = week.notes.join('\n');
                        return pw.TableRow(
                          decoration: isSpecial ? const pw.BoxDecoration(color: PdfColors.grey100) : null,
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(weekLabel, style: pw.TextStyle(font: ttfBold, fontSize: 8))),
                            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(dateLabel, style: pw.TextStyle(font: ttf, fontSize: 8))),
                            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(isSpecial ? (week.title ?? weekLabel) : lessons, style: pw.TextStyle(font: ttf, fontSize: 8))),
                            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(notes, style: pw.TextStyle(font: ttf, fontSize: 8))),
                          ],
                        );
                      }),
                    ],
                  ),
                  pw.Spacer(),
                  // Footer
                  pw.Divider(color: PdfColors.grey400),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('معلم المادة: $teacher', style: pw.TextStyle(font: ttf, fontSize: 9)),
                      pw.Text('صفحة $pageNum من $totalPages', style: pw.TextStyle(font: ttf, fontSize: 9)),
                      pw.Text('مدير المدرسة: $manager', style: pw.TextStyle(font: ttf, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'الخطة الفصلية - ${plan.subjectName}.pdf',
    );
  }

  void _onRegionChanged(String region) {
    setState(() => _selectedRegion = region);
    final cubit = CurriculumDistributionCubit.get(context);
    if (cubit.selectedPlanId != null) {
      cubit.loadPlanDetail(
        cubit.selectedPlanId!,
        region: region == 'west' ? 'west' : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          title: Text(
            'الكتب الدراسية',
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: ColorsManager.mainText,
          ),
        ),
        body: BlocConsumer<CurriculumDistributionCubit,
            CurriculumDistributionState>(
          listener: (context, state) {
            if (state is CurriculumDistributionPrepareSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم تحضير الأسبوع بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state is CurriculumDistributionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            CurriculumPlanDetailModel? detail;
            bool isPreparing = false;

            if (state is CurriculumDistributionDetailLoaded) {
              detail = state.detail;
            } else if (state is CurriculumDistributionPreparing) {
              detail = state.detail;
              isPreparing = true;
            } else if (state is CurriculumDistributionPrepareSuccess) {
              detail = state.detail;
            }

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SubjectPickerSection(
                        stages: _stages,
                        grades: _grades,
                        subjects: _subjects,
                        selectedStage: _selectedStage,
                        selectedGrade: _selectedGrade,
                        selectedSubject: _selectedSubject,
                        selectedSemester: _selectedSemester,
                        loading: _loadingStages,
                        error: _pickerError,
                        onStageSelected: _onStageSelected,
                        onGradeSelected: _onGradeSelected,
                        onSubjectSelected: _onSubjectSelected,
                        onSemesterChanged: _onSemesterChanged,
                      ),
                    ),
                    if (_selectedSubject != null)
                      const SliverToBoxAdapter(
                        child: InlineBooksSection(),
                      ),
                    if (detail != null)
                      SliverToBoxAdapter(
                        child: ExportPdfCard(
                          onExport: (school, teacher, manager) => _exportSemesterPlanPdf(
                            detail: detail!,
                            school: school,
                            teacher: teacher,
                            manager: manager,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: RegionLegendRow(
                        selectedRegion: _selectedRegion,
                        onRegionChanged: _onRegionChanged,
                      ),
                    ),
                    if (_selectedSubject == null)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyPickerView(
                          message: 'الرجاء اختيار المادة لعرض الكتب والتوزيع',
                        ),
                      )
                    else if (state is CurriculumDistributionLoading ||
                        state is CurriculumDistributionInitial ||
                        state is CurriculumDistributionPlansLoaded)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state is CurriculumDistributionError)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: CurriculumErrorView(
                          message: state.message,
                          onRetry: () =>
                              CurriculumDistributionCubit.get(context).loadPlans(
                            subjectId: _selectedSubject!.id,
                            semester: _selectedSemester,
                          ),
                        ),
                      )
                    else if (detail != null)
                      ...WeeksGrid.buildSlivers(
                        context: context,
                        detail: detail,
                        progress: null,
                        onPrepareTap: (weekId) {}, // Disabled as per request
                      ),
                  ],
                ),
                if (isPreparing)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x44000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

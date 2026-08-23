import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
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
        body: Column(
          children: [
            SubjectPickerSection(
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
            if (_selectedSubject != null) const InlineBooksSection(),
            RegionLegendRow(
              selectedRegion: _selectedRegion,
              onRegionChanged: _onRegionChanged,
            ),
            Expanded(
              child: BlocConsumer<CurriculumDistributionCubit, CurriculumDistributionState>(
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
                  if (_selectedSubject == null) {
                    return Center(
                      child: Text(
                        'الرجاء اختيار المادة لعرض الكتب والتوزيع',
                        style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
                      ),
                    );
                  }

                  if (state is CurriculumDistributionLoading ||
                      state is CurriculumDistributionInitial ||
                      state is CurriculumDistributionPlansLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  CurriculumPlanDetailModel? detail;
                  CurriculumProgressModel? progress;
                  bool isPreparing = false;

                  if (state is CurriculumDistributionDetailLoaded) {
                    detail = state.detail;
                    progress = state.progress;
                  } else if (state is CurriculumDistributionPreparing) {
                    detail = state.detail;
                    progress = state.progress;
                    isPreparing = true;
                  } else if (state is CurriculumDistributionPrepareSuccess) {
                    detail = state.detail;
                    progress = state.progress;
                  } else if (state is CurriculumDistributionError) {
                    return CurriculumErrorView(
                      message: state.message,
                      onRetry: () => CurriculumDistributionCubit.get(context).loadPlans(
                        subjectId: _selectedSubject!.id,
                        semester: _selectedSemester,
                      ),
                    );
                  }

                  if (detail == null) return const SizedBox.shrink();

                  return Stack(
                    children: [
                      WeeksGrid(
                        detail: detail,
                        progress: progress,
                        onPrepareTap: (weekId) {}, // Disabled as per user request
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
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Book card
// ─────────────────────────────────────────────────────────────────────────────

class _BookCard extends StatelessWidget {
  final CurriculumBookModel book;
  final bool isDownloading;
  final VoidCallback onDownload;

  const _BookCard({
    required this.book,
    required this.isDownloading,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ColorsManager.primaryColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // PDF icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_outlined,
                color: Colors.red, size: 28),
          ),
          horizontalSpace12,
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStylesManager.bold14
                      .copyWith(color: ColorsManager.mainText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpace4,
                Text(
                  book.subjectName,
                  style: TextStylesManager.regular12
                      .copyWith(color: ColorsManager.secondaryText),
                ),
                if (book.sizeMb != null) ...[
                  verticalSpace2,
                  Text(
                    '${book.sizeMb} ميجا',
                    style: TextStylesManager.regular12.copyWith(
                        color: ColorsManager.secondaryText, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
          horizontalSpace12,
          // Download button — fetches signed URL then launches it
          GestureDetector(
            onTap: isDownloading ? null : onDownload,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.download_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text('تحميل',
                            style: TextStylesManager.bold12
                                .copyWith(color: Colors.white)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _FullError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Colors.red),
            verticalSpace12,
            Text(message,
                textAlign: TextAlign.center,
                style: TextStylesManager.regular14
                    .copyWith(color: ColorsManager.secondaryText)),
            verticalSpace16,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

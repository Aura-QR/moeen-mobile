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

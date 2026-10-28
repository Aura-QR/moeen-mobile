import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_dropdown_field.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_picker_tile.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

/// «البيانات»: المرحلة، الصف، المادة (قوائم منسدلة)، بالإضافة إلى الفصل، مدة الخطة، والتاريخ.
class EnrichmentPlanInfoSection extends StatefulWidget {
  const EnrichmentPlanInfoSection({super.key});

  @override
  State<EnrichmentPlanInfoSection> createState() => _EnrichmentPlanInfoSectionState();
}

class _EnrichmentPlanInfoSectionState extends State<EnrichmentPlanInfoSection> {
  bool _isLoading = true;
  List<CurriculumStageModel> _stages = [];

  CurriculumStageModel? _selectedStage;
  CurriculumGradeModel? _selectedGrade;
  CurriculumSubjectModel? _selectedSubject;

  PlanFormCubit? _cubit;

  @override
  void initState() {
    super.initState();
    _fetchCurriculum();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newCubit = PlanFormCubit.get(context);
    if (_cubit != newCubit) {
      _cubit?.stageController.removeListener(_onControllerChanged);
      _cubit?.gradeController.removeListener(_onControllerChanged);
      _cubit?.subjectController.removeListener(_onControllerChanged);

      _cubit = newCubit;
      _cubit?.stageController.addListener(_onControllerChanged);
      _cubit?.gradeController.addListener(_onControllerChanged);
      _cubit?.subjectController.addListener(_onControllerChanged);

      _syncFromControllers();
    }
  }

  @override
  void dispose() {
    _cubit?.stageController.removeListener(_onControllerChanged);
    _cubit?.gradeController.removeListener(_onControllerChanged);
    _cubit?.subjectController.removeListener(_onControllerChanged);
    super.dispose();
  }

  static int _stageWeight(String name) {
    if (name.contains('الابتدائية')) return 1;
    if (name.contains('المتوسطة')) return 2;
    if (name.contains('الثانوية')) return 3;
    return 4;
  }

  Future<void> _fetchCurriculum() async {
    final result = await ApiService.getSubjects();
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _stages = _fallbackStages();
          _isLoading = false;
        });
        _syncFromControllers();
      },
      (stagesData) {
        final sorted = List<CurriculumStageModel>.from(stagesData)
          ..sort((a, b) => _stageWeight(a.name).compareTo(_stageWeight(b.name)));
        setState(() {
          _stages = sorted.isNotEmpty ? sorted : _fallbackStages();
          _isLoading = false;
        });
        _syncFromControllers();
      },
    );
  }

  void _onControllerChanged() {
    if (!mounted) return;
    _syncFromControllers();
  }

  void _syncFromControllers() {
    final cubit = _cubit;
    if (cubit == null || _stages.isEmpty) return;

    final stageText = cubit.stageController.text.trim();
    final gradeText = cubit.gradeController.text.trim();
    final subjectText = cubit.subjectController.text.trim();

    CurriculumStageModel? matchedStage;
    if (stageText.isNotEmpty) {
      matchedStage = _stages.where((s) => s.name.trim() == stageText).firstOrNull;
    }

    // إذا لم تكن المرحلة محددة ولكن الصف محدد، نبحث عن المرحلة التي تحتوي هذا الصف
    if (matchedStage == null && gradeText.isNotEmpty) {
      for (final s in _stages) {
        if (s.grades.any((g) => g.name.trim() == gradeText)) {
          matchedStage = s;
          cubit.stageController.text = s.name;
          break;
        }
      }
    }

    CurriculumGradeModel? matchedGrade;
    if (matchedStage != null && gradeText.isNotEmpty) {
      matchedGrade = matchedStage.grades.where((g) => g.name.trim() == gradeText).firstOrNull;
    }

    CurriculumSubjectModel? matchedSubject;
    if (matchedGrade != null && subjectText.isNotEmpty) {
      matchedSubject = matchedGrade.subjects.where((s) => s.name.trim() == subjectText).firstOrNull;
    }

    if (matchedStage != _selectedStage || matchedGrade != _selectedGrade || matchedSubject != _selectedSubject) {
      setState(() {
        _selectedStage = matchedStage;
        _selectedGrade = matchedGrade;
        _selectedSubject = matchedSubject;
      });
    }
  }

  void _onStageSelected(CurriculumStageModel? stage) {
    final cubit = _cubit;
    if (cubit == null) return;

    setState(() {
      _selectedStage = stage;
      _selectedGrade = null;
      _selectedSubject = null;
    });

    cubit.stageController.text = stage?.name ?? '';
    cubit.gradeController.clear();
    cubit.subjectController.clear();
  }

  void _onGradeSelected(CurriculumGradeModel? grade) {
    final cubit = _cubit;
    if (cubit == null) return;

    setState(() {
      _selectedGrade = grade;
      _selectedSubject = null;
    });

    cubit.gradeController.text = grade?.name ?? '';
    cubit.subjectController.clear();
  }

  void _onSubjectSelected(CurriculumSubjectModel? subject) {
    final cubit = _cubit;
    if (cubit == null) return;

    setState(() {
      _selectedSubject = subject;
    });

    cubit.subjectController.text = subject?.name ?? '';
  }

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final cubit = _cubit;
    if (cubit == null) return;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (date != null) cubit.setDate(date);
  }

  List<CurriculumGradeModel> _availableGrades() {
    final stage = _selectedStage;
    if (stage == null) return const [];
    final grades = List<CurriculumGradeModel>.from(stage.grades);
    final savedGrade = _cubit?.gradeController.text.trim() ?? '';
    if (savedGrade.isNotEmpty && !grades.any((g) => g.name.trim() == savedGrade)) {
      grades.insert(0, CurriculumGradeModel(id: -1, name: savedGrade, subjects: const []));
    }
    return grades;
  }

  List<CurriculumSubjectModel> _availableSubjects() {
    final grade = _selectedGrade;
    if (grade == null) return const [];
    final subjects = List<CurriculumSubjectModel>.from(grade.subjects);
    final savedSubject = _cubit?.subjectController.text.trim() ?? '';
    if (savedSubject.isNotEmpty && !subjects.any((s) => s.name.trim() == savedSubject)) {
      subjects.insert(0, CurriculumSubjectModel(id: -1, name: savedSubject));
    }
    return subjects;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    final grades = _availableGrades();
    final subjects = _availableSubjects();

    return PrimarySectionCard(
      icon: Icons.class_outlined,
      title: appTranslation().get('plan_section_info'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // المرحلة الدراسية
          PrimaryDropdownField<CurriculumStageModel>(
            label: 'المرحلة الدراسية',
            hint: _isLoading ? 'جاري التحميل...' : 'اختر المرحلة',
            prefixIcon: const Icon(Icons.school_outlined, size: 20),
            isLoading: _isLoading,
            value: _selectedStage,
            items: _stages,
            labelOf: (stage) => stage.name,
            onChanged: _onStageSelected,
          ),
          verticalSpace12,

          // الصف الدراسي
          PrimaryDropdownField<CurriculumGradeModel>(
            label: appTranslation().get('strategy_field_grade'),
            hint: _selectedStage == null ? 'اختر المرحلة أولاً' : 'اختر الصف',
            prefixIcon: const Icon(Icons.class_outlined, size: 20),
            enabled: _selectedStage != null && grades.isNotEmpty,
            value: _selectedGrade,
            items: grades,
            labelOf: (grade) => grade.name,
            onChanged: _onGradeSelected,
          ),
          verticalSpace12,

          // المادة
          PrimaryDropdownField<CurriculumSubjectModel>(
            label: appTranslation().get('strategy_field_subject'),
            hint: _selectedGrade == null ? 'اختر الصف أولاً' : 'اختر المادة',
            prefixIcon: const Icon(Icons.menu_book_outlined, size: 20),
            enabled: _selectedGrade != null && subjects.isNotEmpty,
            value: _selectedSubject,
            items: subjects,
            labelOf: (subject) => subject.name,
            onChanged: _onSubjectSelected,
          ),
          verticalSpace12,

          // الفصل ومدة الخطة
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.classController,
                  label: appTranslation().get('strategy_field_class'),
                  hint: appTranslation().get('strategy_field_class_hint'),
                  maxLength: 60,
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.periodController,
                  label: appTranslation().get('plan_field_period'),
                  hint: appTranslation().get('plan_field_period_hint'),
                  maxLength: 120,
                ),
              ),
            ],
          ),
          verticalSpace12,

          // التاريخ
          BlocSelector<PlanFormCubit, PlanFormState, DateTime?>(
            selector: (state) => state.date,
            builder: (context, date) => DocumentPickerTile(
              icon: Icons.event_outlined,
              hint: appTranslation().get('plan_field_date'),
              value: date == null ? null : isoDate(date),
              onTap: () => _pickDate(context, date),
            ),
          ),
        ],
      ),
    );
  }

  static List<CurriculumStageModel> _fallbackStages() => [
    CurriculumStageModel(
      id: 1,
      name: 'المرحلة الابتدائية',
      grades: [
        CurriculumGradeModel(id: 11, name: 'الصف الأول الابتدائي', subjects: _elementarySubjects(11)),
        CurriculumGradeModel(id: 12, name: 'الصف الثاني الابتدائي', subjects: _elementarySubjects(12)),
        CurriculumGradeModel(id: 13, name: 'الصف الثالث الابتدائي', subjects: _elementarySubjects(13)),
        CurriculumGradeModel(id: 14, name: 'الصف الرابع الابتدائي', subjects: _elementarySubjects(14)),
        CurriculumGradeModel(id: 15, name: 'الصف الخامس الابتدائي', subjects: _elementarySubjects(15)),
        CurriculumGradeModel(id: 16, name: 'الصف السادس الابتدائي', subjects: _elementarySubjects(16)),
      ],
    ),
    CurriculumStageModel(
      id: 2,
      name: 'المرحلة المتوسطة',
      grades: [
        CurriculumGradeModel(id: 21, name: 'الصف الأول المتوسط', subjects: _middleSubjects(21)),
        CurriculumGradeModel(id: 22, name: 'الصف الثاني المتوسط', subjects: _middleSubjects(22)),
        CurriculumGradeModel(id: 23, name: 'الصف الثالث المتوسط', subjects: _middleSubjects(23)),
      ],
    ),
    CurriculumStageModel(
      id: 3,
      name: 'المرحلة الثانوية',
      grades: [
        CurriculumGradeModel(id: 31, name: 'الصف الأول الثانوي', subjects: _secondarySubjects(31)),
        CurriculumGradeModel(id: 32, name: 'الصف الثاني الثانوي', subjects: _secondarySubjects(32)),
        CurriculumGradeModel(id: 33, name: 'الصف الثالث الثانوي', subjects: _secondarySubjects(33)),
      ],
    ),
  ];

  static List<CurriculumSubjectModel> _elementarySubjects(int baseId) => [
    CurriculumSubjectModel(id: baseId * 10 + 1, name: 'القرآن الكريم والدراسات الإسلامية'),
    CurriculumSubjectModel(id: baseId * 10 + 2, name: 'اللغة العربية'),
    CurriculumSubjectModel(id: baseId * 10 + 3, name: 'الرياضيات'),
    CurriculumSubjectModel(id: baseId * 10 + 4, name: 'العلوم'),
    CurriculumSubjectModel(id: baseId * 10 + 5, name: 'اللغة الإنجليزية'),
    CurriculumSubjectModel(id: baseId * 10 + 6, name: 'الدراسات الاجتماعية'),
    CurriculumSubjectModel(id: baseId * 10 + 7, name: 'المهارات الرقمية'),
    CurriculumSubjectModel(id: baseId * 10 + 8, name: 'التربية الفنية'),
    CurriculumSubjectModel(id: baseId * 10 + 9, name: 'التربية البدنية والدفاع عن النفس'),
    CurriculumSubjectModel(id: baseId * 10 + 10, name: 'المهارات الحياتية والأسرية'),
  ];

  static List<CurriculumSubjectModel> _middleSubjects(int baseId) => [
    CurriculumSubjectModel(id: baseId * 10 + 1, name: 'الدراسات الإسلامية'),
    CurriculumSubjectModel(id: baseId * 10 + 2, name: 'اللغة العربية (لغتي الخالدة)'),
    CurriculumSubjectModel(id: baseId * 10 + 3, name: 'الرياضيات'),
    CurriculumSubjectModel(id: baseId * 10 + 4, name: 'العلوم'),
    CurriculumSubjectModel(id: baseId * 10 + 5, name: 'اللغة الإنجليزية'),
    CurriculumSubjectModel(id: baseId * 10 + 6, name: 'الدراسات الاجتماعية'),
    CurriculumSubjectModel(id: baseId * 10 + 7, name: 'المهارات الرقمية'),
    CurriculumSubjectModel(id: baseId * 10 + 8, name: 'التفكير الناقد'),
    CurriculumSubjectModel(id: baseId * 10 + 9, name: 'التربية الفنية'),
    CurriculumSubjectModel(id: baseId * 10 + 10, name: 'التربية البدنية والدفاع عن النفس'),
    CurriculumSubjectModel(id: baseId * 10 + 11, name: 'المهارات الحياتية والأسرية'),
  ];

  static List<CurriculumSubjectModel> _secondarySubjects(int baseId) => [
    CurriculumSubjectModel(id: baseId * 10 + 1, name: 'القرآن الكريم والدراسات الإسلامية'),
    CurriculumSubjectModel(id: baseId * 10 + 2, name: 'الكفايات اللغوية'),
    CurriculumSubjectModel(id: baseId * 10 + 3, name: 'الرياضيات'),
    CurriculumSubjectModel(id: baseId * 10 + 4, name: 'الفيزياء'),
    CurriculumSubjectModel(id: baseId * 10 + 5, name: 'الكيمياء'),
    CurriculumSubjectModel(id: baseId * 10 + 6, name: 'الأحياء'),
    CurriculumSubjectModel(id: baseId * 10 + 7, name: 'علم البيئة'),
    CurriculumSubjectModel(id: baseId * 10 + 8, name: 'اللغة الإنجليزية'),
    CurriculumSubjectModel(id: baseId * 10 + 9, name: 'الدراسات الاجتماعية'),
    CurriculumSubjectModel(id: baseId * 10 + 10, name: 'التقنية الرقمية'),
    CurriculumSubjectModel(id: baseId * 10 + 11, name: 'علم البيانات'),
    CurriculumSubjectModel(id: baseId * 10 + 12, name: 'الذكاء الاصطناعي'),
    CurriculumSubjectModel(id: baseId * 10 + 13, name: 'الهندسة'),
    CurriculumSubjectModel(id: baseId * 10 + 14, name: 'اللياقة والثقافة الصحية'),
    CurriculumSubjectModel(id: baseId * 10 + 15, name: 'التربية المهنية'),
  ];
}

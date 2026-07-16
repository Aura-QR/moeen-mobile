import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';
import 'package:moean/features/reports/presentation/widgets/report_lessons_widget.dart';
import 'package:moean/features/reports/presentation/widgets/report_type_selector_widget.dart';
import 'package:moean/features/reports/presentation/widgets/selection_bottom_sheet.dart';

class ReportFormWidget extends StatefulWidget {
  final String teacherName;
  final void Function({
    required String reportType,
    required String grade,
    required String subject,
    required String unit,
    required String semester,
    required String schoolName,
    required String educationOffice,
    required String reportDate,
    required List<String> selectedLessons,
  }) onSubmit;
  final bool isLoading;

  const ReportFormWidget({
    super.key,
    required this.teacherName,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<ReportFormWidget> createState() => _ReportFormWidgetState();
}

class _ReportFormWidgetState extends State<ReportFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _stageController = TextEditingController();
  final _gradeController = TextEditingController();
  final _subjectController = TextEditingController();
  final _unitController = TextEditingController();
  final _semesterController = TextEditingController();
  final _schoolController = TextEditingController();
  final _educationOfficeController = TextEditingController();
  final _reportDateController = TextEditingController();

  String _selectedType = 'اسبوعي';
  List<String> _selectedLessons = [];

  bool _isLoadingSubjects = false;
  List<CurriculumStageModel> _stages = [];
  
  CurriculumStageModel? _selectedStage;
  CurriculumGradeModel? _selectedGrade;
  CurriculumSubjectModel? _selectedSubject;
  
  bool _isLoadingLessons = false;
  SubjectDetailsModel? _subjectDetails;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    setState(() => _isLoadingSubjects = true);
    final result = await ApiService.getSubjects();
    if (mounted) {
      result.fold(
        (failure) {
          setState(() => _isLoadingSubjects = false);
        },
        (stagesData) {
          setState(() {
            _stages = stagesData;
            _isLoadingSubjects = false;
          });
        },
      );
    }
  }

  void _showStageSelector() {
    if (_isLoadingSubjects) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('جاري التحميل...', style: TextStylesManager.bold14),
          backgroundColor: ColorsManager.primaryColor,
        ),
      );
      return;
    }

    final stageNames = _stages.map((e) => e.name).toList();

    SelectionBottomSheet.show(
      context: context,
      title: 'اختر المرحلة الدراسية',
      items: stageNames,
      initialSelectedItems: _stageController.text.isNotEmpty ? [_stageController.text] : [],
      isMultiSelect: false,
      onSelectionConfirmed: (selected) {
        if (selected.isNotEmpty) {
          setState(() {
            _stageController.text = selected.first;
            _selectedStage = _stages.firstWhere((e) => e.name == selected.first);
            
            _gradeController.clear();
            _selectedGrade = null;
            
            _subjectController.clear();
            _selectedSubject = null;
            
            _unitController.clear();
            _selectedLessons.clear();
            _subjectDetails = null;
          });
        }
      },
    );
  }

  void _showGradeSelector() {
    if (_selectedStage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار المرحلة أولاً', style: TextStylesManager.bold14),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
      return;
    }

    final gradeNames = _selectedStage!.grades.map((e) => e.name).toList();

    SelectionBottomSheet.show(
      context: context,
      title: 'اختر الصف',
      items: gradeNames,
      initialSelectedItems: _gradeController.text.isNotEmpty ? [_gradeController.text] : [],
      isMultiSelect: false,
      onSelectionConfirmed: (selected) {
        if (selected.isNotEmpty) {
          setState(() {
            _gradeController.text = selected.first;
            _selectedGrade = _selectedStage!.grades.firstWhere((e) => e.name == selected.first);
            
            _subjectController.clear();
            _selectedSubject = null;
            
            _unitController.clear();
            _selectedLessons.clear();
            _subjectDetails = null;
          });
        }
      },
    );
  }

  void _showSubjectSelector() {
    if (_selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار الصف أولاً', style: TextStylesManager.bold14),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
      return;
    }

    final subjectNames = _selectedGrade!.subjects.map((e) => e.name).toList();

    SelectionBottomSheet.show(
      context: context,
      title: 'اختر المادة',
      items: subjectNames,
      initialSelectedItems: _subjectController.text.isNotEmpty ? [_subjectController.text] : [],
      isMultiSelect: false,
      onSelectionConfirmed: (selected) {
        if (selected.isNotEmpty) {
          setState(() {
            _subjectController.text = selected.first;
            _selectedSubject = _selectedGrade!.subjects.firstWhere((e) => e.name == selected.first);
            
            _unitController.clear();
            _selectedLessons.clear();
            _subjectDetails = null;
            
            _fetchSubjectDetails(_selectedSubject!.id);
          });
        }
      },
    );
  }

  Future<void> _fetchSubjectDetails(int subjectId) async {
    setState(() => _isLoadingLessons = true);
    final result = await ApiService.getSubjectLessons(subjectId);
    if (mounted) {
      result.fold(
        (failure) {
          setState(() => _isLoadingLessons = false);
        },
        (details) {
          setState(() {
            _subjectDetails = details;
            _isLoadingLessons = false;
          });
        },
      );
    }
  }

  void _showUnitSelector() {
    if (_selectedSubject == null || _subjectDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار المادة والانتظار للتحميل', style: TextStylesManager.bold14),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
      return;
    }

    final isMonthly = _selectedType == 'شهري';
    final chapterTitles = _subjectDetails!.chapters.map((e) => e.title).toSet().toList();

    SelectionBottomSheet.show(
      context: context,
      title: isMonthly ? 'اختر الفصول' : 'اختر الفصل',
      items: chapterTitles,
      initialSelectedItems: _unitController.text.isNotEmpty 
          ? _unitController.text.split('، ').map((e) => e.trim()).toList() 
          : [],
      isMultiSelect: isMonthly,
      onSelectionConfirmed: (selected) {
        setState(() {
          _unitController.text = selected.join('، ');
          _selectedLessons.clear();
        });
      },
    );
  }

  void _showLessonsSelector() {
    if (_unitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار الفصل أولاً', style: TextStylesManager.bold14),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
      return;
    }

    if (_selectedType == 'شهري' || _subjectDetails == null) return;

    final selectedChapterTitle = _unitController.text;
    final chapterModel = _subjectDetails!.chapters.cast<CurriculumChapterModel?>().firstWhere(
      (e) => e?.title == selectedChapterTitle,
      orElse: () => null,
    );

    if (chapterModel == null) return;
    
    // Auto-fill semester based on selected chapter
    _semesterController.text = chapterModel.semester;

    final availableLessons = chapterModel.lessons;

    if (availableLessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد دروس متاحة لهذا الفصل', style: TextStylesManager.bold14),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
      return;
    }

    SelectionBottomSheet.show(
      context: context,
      title: 'اختر الدروس',
      items: availableLessons.map((e) => e.title).toList(),
      initialSelectedItems: _selectedLessons,
      isMultiSelect: true,
      onSelectionConfirmed: (selected) {
        setState(() {
          _selectedLessons = selected;
        });
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == 'اسبوعي' && _selectedLessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appTranslation().get('report_lessons_required'),
            style: TextStylesManager.bold14,
          ),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
      return;
    }
    widget.onSubmit(
      reportType: _selectedType,
      grade: _gradeController.text.trim(),
      subject: _subjectController.text.trim(),
      unit: _unitController.text.trim(),
      semester: _semesterController.text.trim(),
      schoolName: _schoolController.text.trim(),
      educationOffice: _educationOfficeController.text.trim(),
      reportDate: _reportDateController.text.trim(),
      selectedLessons: _selectedType == 'اسبوعي' ? _selectedLessons : [],
    );
  }

  @override
  void dispose() {
    _stageController.dispose();
    _subjectController.dispose();
    _unitController.dispose();
    _gradeController.dispose();
    _semesterController.dispose();
    _schoolController.dispose();
    _educationOfficeController.dispose();
    _reportDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReportInfoCard(teacherName: widget.teacherName),
          verticalSpace20,

          // Report Type
          _FormLabel(label: appTranslation().get('report_type')),
          verticalSpace8,
          ReportTypeSelectorWidget(
            selectedType: _selectedType,
            onChanged: (v) => setState(() => _selectedType = v),
          ),
          verticalSpace16,

          // Stage
          _FormLabel(label: 'المرحلة الدراسية'),
          verticalSpace8,
          GestureDetector(
            onTap: _showStageSelector,
            child: AbsorbPointer(
              child: PrimaryTextField(
                controller: _stageController,
                hint: _isLoadingSubjects ? 'جاري التحميل...' : 'اختر المرحلة',
                prefixIcon: _isLoadingSubjects 
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : const Icon(Icons.school_outlined),
                validator: (v) => (v == null || v.isEmpty)
                    ? appTranslation().get('field_required')
                    : null,
              ),
            ),
          ),
          verticalSpace16,

          // Grade
          _FormLabel(label: appTranslation().get('report_grade')),
          verticalSpace8,
          GestureDetector(
            onTap: _showGradeSelector,
            child: AbsorbPointer(
              child: PrimaryTextField(
                controller: _gradeController,
                hint: 'اختر الصف',
                prefixIcon: const Icon(Icons.school_outlined),
                validator: (v) => (v == null || v.isEmpty)
                    ? appTranslation().get('field_required')
                    : null,
              ),
            ),
          ),
          verticalSpace16,

          // Subject
          _FormLabel(label: appTranslation().get('report_subject')),
          verticalSpace8,
          GestureDetector(
            onTap: _showSubjectSelector,
            child: AbsorbPointer(
              child: PrimaryTextField(
                controller: _subjectController,
                hint: 'اختر المادة',
                prefixIcon: const Icon(Icons.book_outlined),
                validator: (v) => (v == null || v.isEmpty)
                    ? appTranslation().get('field_required')
                    : null,
              ),
            ),
          ),
          verticalSpace16,

          // Unit/Chapter
          _FormLabel(label: appTranslation().get('report_unit')),
          verticalSpace8,
          GestureDetector(
            onTap: _showUnitSelector,
            child: AbsorbPointer(
              child: PrimaryTextField(
                controller: _unitController,
                hint: _selectedType == 'شهري' 
                    ? 'اختر الفصول' 
                    : 'اختر الفصل',
                prefixIcon: _isLoadingLessons
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : const Icon(Icons.layers_outlined),
                validator: (v) => (v == null || v.isEmpty)
                    ? appTranslation().get('field_required')
                    : null,
              ),
            ),
          ),
          verticalSpace16,

          // Semester
          _FormLabel(label: appTranslation().get('report_semester')),
          verticalSpace8,
          PrimaryTextField(
            controller: _semesterController,
            hint: appTranslation().get('report_semester_hint'),
            prefixIcon: const Icon(Icons.calendar_view_week_outlined),
            validator: (v) => (v == null || v.isEmpty)
                ? appTranslation().get('field_required')
                : null,
          ),
          verticalSpace16,

          // Report Date
          _FormLabel(label: appTranslation().get('report_date')),
          verticalSpace8,
          PrimaryTextField(
            controller: _reportDateController,
            hint: appTranslation().get('report_date_hint'),
            prefixIcon: const Icon(Icons.date_range_outlined),
            validator: (v) => (v == null || v.isEmpty)
                ? appTranslation().get('field_required')
                : null,
          ),
          verticalSpace16,

          // School Name
          _FormLabel(label: appTranslation().get('report_school')),
          verticalSpace8,
          PrimaryTextField(
            controller: _schoolController,
            hint: appTranslation().get('report_school_hint'),
            prefixIcon: const Icon(Icons.home_work_outlined),
            validator: (v) => (v == null || v.isEmpty)
                ? appTranslation().get('field_required')
                : null,
          ),
          verticalSpace16,

          // Education Office
          _FormLabel(label: appTranslation().get('report_education_office')),
          verticalSpace8,
          PrimaryTextField(
            controller: _educationOfficeController,
            hint: appTranslation().get('report_education_office_hint'),
            prefixIcon: const Icon(Icons.account_balance_outlined),
            validator: (v) => (v == null || v.isEmpty)
                ? appTranslation().get('field_required')
                : null,
          ),
          verticalSpace24,

          // Lessons (weekly only)
          if (_selectedType == 'اسبوعي') ...[
            ReportLessonsWidget(
              lessons: _selectedLessons,
              onRemove: (index) {
                setState(() => _selectedLessons.removeAt(index));
              },
              onAdd: _showLessonsSelector,
            ),
            verticalSpace24,
          ],

          // Submit Button
          PrimaryElevatedButton(
            text: appTranslation().get('report_generate'),
            isLoading: widget.isLoading,
            onPressed: widget.isLoading ? null : _submit,
            icon: widget.isLoading
                ? null
                : const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          verticalSpace8,
          Text(
            appTranslation().get('report_generate_hint'),
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace16,
        ],
      ),
    );
  }
}

// ─── Helper sub-widgets ───────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
    );
  }
}

class _ReportInfoCard extends StatelessWidget {
  final String teacherName;
  const _ReportInfoCard({required this.teacherName});

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
              color: ColorsManager.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: ColorsManager.primaryColor,
              size: 22,
            ),
          ),
          horizontalSpace12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appTranslation().get('report_teacher_label'),
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
                verticalSpace2,
                Text(
                  teacherName,
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_rounded,
            color: ColorsManager.primaryColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
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
  final _subjectController = TextEditingController();
  final _unitController = TextEditingController();
  final _gradeController = TextEditingController();
  final _semesterController = TextEditingController();
  final _schoolController = TextEditingController();
  final _educationOfficeController = TextEditingController();
  final _reportDateController = TextEditingController();
  final _addLessonController = TextEditingController();

  String _selectedType = 'اسبوعي';
  List<String> _selectedLessons = [];

  // Dummy Data for demonstration based on screenshot
  final Map<String, List<String>> _dummyUnitsData = {
    'أساسيات الإدارة': [
      'أساسيات الإدارة - تعريف وأهمية الإدارة',
      'أساسيات الإدارة - خصائص وأهداف الإدارة',
      'أساسيات الإدارة - مجالات الإدارة',
      'أساسيات الإدارة - عناصر العملية الإدارية',
    ],
    'التخطيط': [
      'التخطيط - تعريف وفوائد وخصائص التخطيط',
      'التخطيط - أنواع التخطيط',
      'التخطيط - عناصر التخطيط',
      'التخطيط - خطوات التخطيط',
      'التخطيط - صفات التخطيط الفعال ومعوقات التخطيط',
      'التخطيط - دور التخطيط في الحياة وأبرز أجهزة التخطيط',
    ],
    'التنظيم': [
      'التنظيم - تعريف وأنواع التنظيم',
      'التنظيم - مبادئ وخصائص التنظيم',
    ],
    'الرقابة': [
      'الرقابة - تعريف وأهمية الرقابة',
      'الرقابة - مبادئ وأنواع الرقابة',
      'الرقابة - خطوات الرقابة',
      'الرقابة - طرق الرقابة والرقابة الإدارية في الإسلام',
    ],
    'الاتصال الإداري': [
      'الاتصال الإداري - عناصر وأهداف الاتصال',
      'الاتصال الإداري - تعريف وأهمية الاتصال',
      'الاتصال الإداري - مبادئ الاتصال الإداري',
      'الاتصال الإداري - معوقات الاتصال الإداري',
      'الاتصال الإداري - أنواع الاتصال',
      'الاتصال الإداري - وسائل الاتصال الإداري',
    ]
  };

  @override
  void dispose() {
    _subjectController.dispose();
    _unitController.dispose();
    _gradeController.dispose();
    _semesterController.dispose();
    _schoolController.dispose();
    _educationOfficeController.dispose();
    _reportDateController.dispose();
    _addLessonController.dispose();
    super.dispose();
  }

  void _showUnitSelector() {
    SelectionBottomSheet.show(
      context: context,
      title: 'اختر الوحدة / المجال',
      items: _dummyUnitsData.keys.toList(),
      initialSelectedItems: _unitController.text.isNotEmpty ? [_unitController.text] : [],
      isMultiSelect: false,
      onSelectionConfirmed: (selected) {
        if (selected.isNotEmpty) {
          setState(() {
            _unitController.text = selected.first;
            // Clear selected lessons when unit changes
            _selectedLessons.clear();
          });
        }
      },
    );
  }

  void _showLessonsSelector() {
    if (_unitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار الوحدة أولاً', style: TextStylesManager.bold14),
          backgroundColor: ColorsManager.errorColor,
        ),
      );
      return;
    }

    final availableLessons = _dummyUnitsData[_unitController.text] ?? [];
    
    SelectionBottomSheet.show(
      context: context,
      title: 'اختر الدروس',
      items: availableLessons,
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

          // Subject
          _FormLabel(label: appTranslation().get('report_subject')),
          verticalSpace8,
          PrimaryTextField(
            controller: _subjectController,
            hint: _selectedType == 'شهري'
                ? appTranslation().get('report_subject_monthly_hint')
                : appTranslation().get('report_subject_hint'),
            prefixIcon: const Icon(Icons.book_outlined),
            validator: (v) => (v == null || v.isEmpty)
                ? appTranslation().get('field_required')
                : null,
          ),
          verticalSpace16,

          // Unit/Field
          _FormLabel(label: appTranslation().get('report_unit')),
          verticalSpace8,
          GestureDetector(
            onTap: _showUnitSelector,
            child: AbsorbPointer(
              child: PrimaryTextField(
                controller: _unitController,
                hint: appTranslation().get('report_unit_hint'),
                prefixIcon: const Icon(Icons.layers_outlined),
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
          PrimaryTextField(
            controller: _gradeController,
            hint: appTranslation().get('report_grade_hint'),
            prefixIcon: const Icon(Icons.school_outlined),
            validator: (v) => (v == null || v.isEmpty)
                ? appTranslation().get('field_required')
                : null,
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

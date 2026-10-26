import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/class_sheets/data/models/class_sheet_input.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';

class SheetClassSelector extends StatefulWidget {
  final ClassSheetInput input;
  final List<SchoolClassModel> classes;
  final bool isLoadingClasses;
  final ValueChanged<bool> onToggleEmptyRows;
  final ValueChanged<SchoolClassModel> onSelectClass;
  final ValueChanged<int> onUpdateEmptyRows;
  final ValueChanged<String> onUpdateSubject;
  final ValueChanged<String> onUpdateGrade;
  final ValueChanged<String> onUpdateTerm;
  final ValueChanged<String> onUpdateTitle;

  const SheetClassSelector({
    super.key,
    required this.input,
    required this.classes,
    required this.isLoadingClasses,
    required this.onToggleEmptyRows,
    required this.onSelectClass,
    required this.onUpdateEmptyRows,
    required this.onUpdateSubject,
    required this.onUpdateGrade,
    required this.onUpdateTerm,
    required this.onUpdateTitle,
  });

  @override
  State<SheetClassSelector> createState() => _SheetClassSelectorState();
}

class _SheetClassSelectorState extends State<SheetClassSelector> {
  late final TextEditingController _subjectController;
  late final TextEditingController _gradeController;
  late final TextEditingController _termController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.input.subject);
    _gradeController = TextEditingController(text: widget.input.grade);
    _termController = TextEditingController(text: widget.input.term);
    _titleController = TextEditingController(text: widget.input.title);
  }

  @override
  void didUpdateWidget(covariant SheetClassSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_subjectController, widget.input.subject);
    _syncController(_gradeController, widget.input.grade);
    _syncController(_termController, widget.input.term);
    _syncController(_titleController, widget.input.title);
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeController.dispose();
    _termController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _showClassesPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ColorsManager.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: ColorsManager.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    appTranslation().get('sheets_pick_class'),
                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                  ),
                ),
                verticalSpace8,
                Divider(color: ColorsManager.borderColor, height: 1),
                if (widget.classes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      'لا توجد فصول محفوظة في «فصولي» بعد',
                      textAlign: TextAlign.center,
                      style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: widget.classes.length,
                      separatorBuilder: (_, _) => Divider(height: 1, color: ColorsManager.borderColor),
                      itemBuilder: (context, index) {
                        final c = widget.classes[index];
                        final isSelected = c.id == widget.input.classId;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ColorsManager.primaryColor
                                  : ColorsManager.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.groups_2_outlined,
                              color: isSelected ? Colors.white : ColorsManager.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            c.name,
                            style: TextStylesManager.bold14.copyWith(
                              color: isSelected ? ColorsManager.primaryColor : ColorsManager.mainText,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              [
                                if (c.grade.isNotEmpty) c.grade,
                                if (c.subject.isNotEmpty) c.subject,
                                appTranslation()
                                    .get('sheets_students_count')
                                    .replaceAll('{count}', '${c.studentsCount}'),
                              ].join(' · '),
                              style: TextStylesManager.medium12.copyWith(
                                color: ColorsManager.mainText.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle_rounded, color: ColorsManager.primaryColor)
                              : null,
                          onTap: () {
                            Navigator.pop(sheetContext);
                            widget.onSelectClass(c);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.input;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appTranslation().get('sheets_class'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          ),
          verticalSpace16,

          // Source Mode Segmented Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: ColorsManager.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColorsManager.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    icon: Icons.groups_2_outlined,
                    label: appTranslation().get('sheets_pick_class'),
                    isSelected: !input.useEmptyRows,
                    onTap: () => widget.onToggleEmptyRows(false),
                  ),
                ),
                horizontalSpace6,
                Expanded(
                  child: _ToggleButton(
                    icon: Icons.table_rows_outlined,
                    label: appTranslation().get('sheets_empty_sheet'),
                    isSelected: input.useEmptyRows,
                    onTap: () => widget.onToggleEmptyRows(true),
                  ),
                ),
              ],
            ),
          ),
          verticalSpace16,

          if (!input.useEmptyRows) ...[
            if (input.classId != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.class_outlined, color: ColorsManager.primaryColor, size: 22),
                    ),
                    horizontalSpace12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            input.className,
                            style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                          ),
                          verticalSpace4,
                          Text(
                            appTranslation()
                                .get('sheets_students_count')
                                .replaceAll('{count}', '${input.students.length}'),
                            style: TextStylesManager.medium12.copyWith(color: ColorsManager.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showClassesPicker(context),
                      style: TextButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'تغيير الفصل',
                        style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                      ),
                    ),
                  ],
                ),
              )
            else
              Material(
                color: ColorsManager.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _showClassesPicker(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorsManager.primaryColor.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: ColorsManager.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            color: ColorsManager.primaryColor,
                            size: 20,
                          ),
                        ),
                        horizontalSpace12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اختر فصلاً من «فصولي»',
                                style: TextStylesManager.bold14.copyWith(
                                  color: ColorsManager.primaryColor,
                                ),
                              ),
                              verticalSpace2,
                              Text(
                                'لتعبئة أسماء الطلاب وبيانات الفصل تلقائياً',
                                style: TextStylesManager.medium12.copyWith(
                                  color: ColorsManager.mainText.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isLoadingClasses)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ColorsManager.primaryColor,
                            ),
                          )
                        else
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: ColorsManager.primaryColor,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ColorsManager.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorsManager.borderColor, width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.format_list_numbered_rtl_rounded,
                    color: ColorsManager.primaryColor,
                    size: 20,
                  ),
                  horizontalSpace8,
                  Expanded(
                    child: Text(
                      appTranslation().get('sheets_empty_rows'),
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                    ),
                  ),
                  _StepperIconButton(
                    icon: Icons.remove_rounded,
                    onTap: input.emptyRows > 5
                        ? () => widget.onUpdateEmptyRows(input.emptyRows - 5)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      '${input.emptyRows}',
                      style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor),
                    ),
                  ),
                  _StepperIconButton(
                    icon: Icons.add_rounded,
                    onTap: input.emptyRows < 100
                        ? () => widget.onUpdateEmptyRows(input.emptyRows + 5)
                        : null,
                  ),
                ],
              ),
            ),
          ],
          verticalSpace16,

          // Subject & Grade Row
          Row(
            children: [
              Expanded(
                child: _SheetLabeledField(
                  label: appTranslation().get('sheets_subject'),
                  hint: 'مثال: لغتي، الرياضيات',
                  controller: _subjectController,
                  onChanged: widget.onUpdateSubject,
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: _SheetLabeledField(
                  label: appTranslation().get('sheets_grade'),
                  hint: 'مثال: الرابع الابتدائي',
                  controller: _gradeController,
                  onChanged: widget.onUpdateGrade,
                ),
              ),
            ],
          ),
          verticalSpace12,

          // Term (Full width so long text like «الفصل الدراسي الأول» is always clear)
          _SheetLabeledField(
            label: appTranslation().get('sheets_term'),
            hint: appTranslation().get('sheets_term_1'),
            controller: _termController,
            onChanged: widget.onUpdateTerm,
          ),
          verticalSpace12,

          // Sheet Title (Full width so placeholder & typed title never truncate)
          _SheetLabeledField(
            label: 'عنوان الكشف (اختياري)',
            hint: 'مثال: كشف متابعة درجات الفترة الأولى',
            controller: _titleController,
            onChanged: widget.onUpdateTitle,
          ),
        ],
      ),
    );
  }
}

class _SheetLabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SheetLabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
        ),
        verticalSpace6,
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorsManager.background,
            hintText: hint,
            hintStyle: TextStylesManager.regular13.copyWith(
              color: ColorsManager.placeholder,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorsManager.borderColor, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorsManager.borderColor, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorsManager.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? ColorsManager.primaryColor.withValues(alpha: 0.1)
          : ColorsManager.borderColor.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? ColorsManager.primaryColor : ColorsManager.placeholder,
          ),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = isSelected ? Colors.white : ColorsManager.mainText.withValues(alpha: 0.85);
    return Material(
      color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fgColor),
              horizontalSpace6,
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: (isSelected ? TextStylesManager.bold13 : TextStylesManager.medium13)
                        .copyWith(color: fgColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

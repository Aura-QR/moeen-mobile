import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/class_sheets/data/models/class_sheet_input.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';

class SheetClassSelector extends StatelessWidget {
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

  void _showClassesPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    appTranslation().get('sheets_pick_class'),
                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                  ),
                ),
                const Divider(),
                if (classes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'لا توجد فصول محفوظة في «فصولي» بعد',
                      style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: classes.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final c = classes[index];
                        final isSelected = c.id == input.classId;
                        return ListTile(
                          title: Text(
                            c.name,
                            style: TextStylesManager.bold14.copyWith(
                              color: isSelected ? ColorsManager.primaryColor : ColorsManager.mainText,
                            ),
                          ),
                          subtitle: Text(
                            [
                              if (c.grade.isNotEmpty) c.grade,
                              if (c.subject.isNotEmpty) c.subject,
                              appTranslation()
                                  .get('sheets_students_count')
                                  .replaceAll('{count}', '${c.studentsCount}'),
                            ].join(' · '),
                            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle_rounded, color: ColorsManager.primaryColor)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            onSelectClass(c);
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appTranslation().get('sheets_class'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          ),
          verticalSpace16,

          // Source Mode Toggle
          Row(
            children: [
              Expanded(
                child: _ToggleButton(
                  icon: Icons.groups_2_outlined,
                  label: appTranslation().get('sheets_pick_class'),
                  isSelected: !input.useEmptyRows,
                  onTap: () => onToggleEmptyRows(false),
                ),
              ),
              horizontalSpace8,
              Expanded(
                child: _ToggleButton(
                  icon: Icons.table_rows_outlined,
                  label: appTranslation().get('sheets_empty_sheet'),
                  isSelected: input.useEmptyRows,
                  onTap: () => onToggleEmptyRows(true),
                ),
              ),
            ],
          ),
          verticalSpace16,

          if (!input.useEmptyRows) ...[
            if (input.classId != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.class_outlined, color: ColorsManager.primaryColor),
                    horizontalSpace12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            input.className,
                            style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                          ),
                          verticalSpace4,
                          Text(
                            appTranslation()
                                .get('sheets_students_count')
                                .replaceAll('{count}', '${input.students.length}'),
                            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showClassesPicker(context),
                      child: const Text('تغيير الفصل'),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _showClassesPicker(context),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: Text(appTranslation().get('sheets_pick_class')),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    appTranslation().get('sheets_empty_rows'),
                    style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                  ),
                ),
                IconButton(
                  onPressed: input.emptyRows > 5 ? () => onUpdateEmptyRows(input.emptyRows - 5) : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${input.emptyRows}',
                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor),
                  ),
                ),
                IconButton(
                  onPressed: input.emptyRows < 100 ? () => onUpdateEmptyRows(input.emptyRows + 5) : null,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
          ],
          verticalSpace16,

          // Subject, Grade, Term
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: TextEditingController(text: input.subject)..selection = TextSelection.collapsed(offset: input.subject.length),
                  hint: appTranslation().get('sheets_subject'),
                  onChanged: onUpdateSubject,
                ),
              ),
              horizontalSpace8,
              Expanded(
                child: PrimaryTextField(
                  controller: TextEditingController(text: input.grade)..selection = TextSelection.collapsed(offset: input.grade.length),
                  hint: appTranslation().get('sheets_grade'),
                  onChanged: onUpdateGrade,
                ),
              ),
            ],
          ),
          verticalSpace12,

          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: TextEditingController(text: input.term)..selection = TextSelection.collapsed(offset: input.term.length),
                  hint: appTranslation().get('sheets_term'),
                  onChanged: onUpdateTerm,
                ),
              ),
              horizontalSpace8,
              Expanded(
                child: PrimaryTextField(
                  controller: TextEditingController(text: input.title)..selection = TextSelection.collapsed(offset: input.title.length),
                  hint: 'عنوان الكشف (اختياري)',
                  onChanged: onUpdateTitle,
                ),
              ),
            ],
          ),
        ],
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
    return Material(
      color: isSelected ? ColorsManager.primaryColor : ColorsManager.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderLightGray,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : ColorsManager.secondaryText,
              ),
              horizontalSpace6,
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStylesManager.medium12.copyWith(
                    color: isSelected ? Colors.white : ColorsManager.secondaryText,
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

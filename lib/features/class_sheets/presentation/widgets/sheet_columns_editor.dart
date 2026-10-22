import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/class_sheets/data/models/class_sheet_column.dart';
import 'package:moean/features/class_sheets/data/models/class_sheet_input.dart';
import 'package:moean/features/class_sheets/data/models/class_sheets_catalogue_model.dart';

class SheetColumnsEditor extends StatelessWidget {
  final SheetKindModel kind;
  final ClassSheetInput input;
  final ValueChanged<DateTime> onUpdateStartDate;
  final ValueChanged<int> onUpdateWeeks;
  final ValueChanged<DateTime> onUpdateFollowUpDate;
  final Function(int, int) onReorderColumns;
  final ValueChanged<ClassSheetColumn> onAddColumn;
  final Function(int, ClassSheetColumn) onUpdateColumn;
  final ValueChanged<int> onRemoveColumn;
  final VoidCallback onResetColumns;

  const SheetColumnsEditor({
    super.key,
    required this.kind,
    required this.input,
    required this.onUpdateStartDate,
    required this.onUpdateWeeks,
    required this.onUpdateFollowUpDate,
    required this.onReorderColumns,
    required this.onAddColumn,
    required this.onUpdateColumn,
    required this.onRemoveColumn,
    required this.onResetColumns,
  });

  void _showColumnDialog(BuildContext context, {ClassSheetColumn? initial, int? index}) {
    final labelController = TextEditingController(text: initial?.label ?? '');
    final maxController = TextEditingController(text: initial?.max?.toString() ?? '');

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          initial == null ? appTranslation().get('sheets_add_column') : 'تعديل العمود',
          style: TextStylesManager.bold16,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryTextField(
              controller: labelController,
              hint: appTranslation().get('sheets_column_label'),
            ),
            verticalSpace12,
            PrimaryTextField(
              controller: maxController,
              hint: appTranslation().get('sheets_column_max'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final label = labelController.text.trim();
              if (label.isEmpty) return;
              final max = num.tryParse(maxController.text.trim());
              final col = ClassSheetColumn(label: label, max: max);

              if (index != null) {
                onUpdateColumn(index, col);
              } else {
                onAddColumn(col);
              }
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) onPicked(picked);
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
          // Attendance Specific Section
          if (kind.kindType == SheetKindType.attendance) ...[
            Text(
              'إعدادات كشف الحضور والغياب',
              style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace16,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(
                      context,
                      input.startDate ?? DateTime.now(),
                      onUpdateStartDate,
                    ),
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(
                      input.startDate != null
                          ? isoDate(input.startDate!)
                          : appTranslation().get('sheets_start_date'),
                      style: TextStylesManager.medium12,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace16,
            Text(
              appTranslation().get('sheets_weeks_count'),
              style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace8,
            Row(
              children: [
                for (int w = 1; w <= 4; w++) ...[
                  Expanded(
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          '$w ${w == 1 ? "أسبوع" : "أسابيع"}',
                          style: TextStylesManager.medium12.copyWith(
                            color: input.weeks == w ? Colors.white : ColorsManager.mainText,
                          ),
                        ),
                      ),
                      selected: input.weeks == w,
                      selectedColor: ColorsManager.primaryColor,
                      onSelected: (_) => onUpdateWeeks(w),
                    ),
                  ),
                  if (w < 4) horizontalSpace8,
                ],
              ],
            ),
          ] else ...[
            // Daily Follow-up date
            if (kind.kindType == SheetKindType.dailyFollowUp) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(
                        context,
                        input.date ?? DateTime.now(),
                        onUpdateFollowUpDate,
                      ),
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      label: Text(
                        input.date != null
                            ? isoDate(input.date!)
                            : appTranslation().get('sheets_follow_up_date'),
                        style: TextStylesManager.medium12,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpace16,
            ],

            // Columns Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    appTranslation().get('sheets_columns'),
                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                  ),
                ),
                TextButton.icon(
                  onPressed: onResetColumns,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    appTranslation().get('sheets_reset_defaults'),
                    style: TextStylesManager.regular12,
                  ),
                ),
              ],
            ),
            verticalSpace8,

            // Reorderable Columns List
            if (input.columns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'لا توجد أعمدة مضافة',
                    style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: input.columns.length,
                onReorder: onReorderColumns,
                itemBuilder: (context, index) {
                  final col = input.columns[index];
                  return Container(
                    key: ValueKey('col_${index}_${col.label}'),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ColorsManager.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorsManager.borderLightGray),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.drag_indicator_rounded, color: ColorsManager.secondaryText, size: 20),
                        horizontalSpace8,
                        Expanded(
                          child: Text(
                            col.label,
                            style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
                          ),
                        ),
                        if (col.max != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'الدرجة: ${col.max}',
                              style: TextStylesManager.medium12.copyWith(color: ColorsManager.primaryColor),
                            ),
                          ),
                          horizontalSpace4,
                        ],
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _showColumnDialog(context, initial: col, index: index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, size: 18, color: ColorsManager.errorColor),
                          onPressed: () => onRemoveColumn(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            verticalSpace8,

            OutlinedButton.icon(
              onPressed: () => _showColumnDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(appTranslation().get('sheets_add_column')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

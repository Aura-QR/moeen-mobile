import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
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

  String _cleanAddColumnLabel() {
    return appTranslation()
        .get('sheets_add_column')
        .replaceFirst(RegExp(r'^\+\s*'), '')
        .trim();
  }

  static String _weekLabel(int weeks) => switch (weeks) {
        1 => 'أسبوع واحد',
        2 => 'أسبوعان',
        _ => '$weeks أسابيع',
      };

  void _showColumnDialog(BuildContext context, {ClassSheetColumn? initial, int? index}) {
    final labelController = TextEditingController(text: initial?.label ?? '');
    final maxController = TextEditingController(text: initial?.max?.toString() ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ColorsManager.surfacePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          initial == null ? _cleanAddColumnLabel() : 'تعديل العمود',
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appTranslation().get('sheets_column_label'),
              style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace6,
            TextFormField(
              controller: labelController,
              autofocus: true,
              style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorsManager.background,
                hintText: 'مثال: المشاركة، الواجبات',
                hintStyle: TextStylesManager.regular13.copyWith(color: ColorsManager.placeholder),
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
            verticalSpace12,
            Text(
              appTranslation().get('sheets_column_max'),
              style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace6,
            TextFormField(
              controller: maxController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorsManager.background,
                hintText: 'مثال: 10',
                hintStyle: TextStylesManager.regular13.copyWith(color: ColorsManager.placeholder),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: TextStylesManager.bold13.copyWith(color: ColorsManager.secondaryText),
            ),
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
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text('حفظ', style: TextStylesManager.bold13.copyWith(color: Colors.white)),
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
          // Attendance Specific Section
          if (kind.kindType == SheetKindType.attendance) ...[
            Text(
              'إعدادات كشف الحضور والغياب',
              style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace16,
            _DateSelectorField(
              label: appTranslation().get('sheets_start_date'),
              dateText: input.startDate != null
                  ? isoDate(input.startDate!)
                  : isoDate(DateTime.now()),
              onTap: () => _pickDate(
                context,
                input.startDate ?? DateTime.now(),
                onUpdateStartDate,
              ),
            ),
            verticalSpace16,
            Text(
              appTranslation().get('sheets_weeks_count'),
              style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace8,
            Row(
              children: [
                for (int w = 1; w <= 4; w++) ...[
                  Expanded(
                    child: _WeekOptionButton(
                      label: _weekLabel(w),
                      isSelected: input.weeks == w,
                      onTap: () => onUpdateWeeks(w),
                    ),
                  ),
                  if (w < 4) horizontalSpace8,
                ],
              ],
            ),
          ] else ...[
            // Daily Follow-up date
            if (kind.kindType == SheetKindType.dailyFollowUp) ...[
              _DateSelectorField(
                label: appTranslation().get('sheets_follow_up_date'),
                dateText: input.date != null
                    ? isoDate(input.date!)
                    : isoDate(DateTime.now()),
                onTap: () => _pickDate(
                  context,
                  input.date ?? DateTime.now(),
                  onUpdateFollowUpDate,
                ),
              ),
              verticalSpace16,
            ],

            // Columns Header
            Row(
              children: [
                Text(
                  appTranslation().get('sheets_columns'),
                  style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                ),
                horizontalSpace8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${input.columns.length}',
                    style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onResetColumns,
                  style: TextButton.styleFrom(
                    backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(Icons.refresh_rounded, size: 16, color: ColorsManager.primaryColor),
                  label: Text(
                    appTranslation().get('sheets_reset_defaults'),
                    style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                  ),
                ),
              ],
            ),
            verticalSpace12,

            // Reorderable Columns List
            if (input.columns.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: ColorsManager.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsManager.borderColor),
                ),
                child: Text(
                  'لا توجد أعمدة مضافة بعد',
                  textAlign: TextAlign.center,
                  style: TextStylesManager.medium13.copyWith(color: ColorsManager.secondaryText),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: input.columns.length,
                onReorderItem: onReorderColumns,
                proxyDecorator: (child, _, animation) => AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Material(
                    color: Colors.transparent,
                    elevation: 4 * animation.value,
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  ),
                  child: child,
                ),
                itemBuilder: (context, index) {
                  final col = input.columns[index];
                  return Container(
                    key: ValueKey('col_${index}_${col.label}'),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: ColorsManager.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorsManager.borderColor, width: 1.1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.drag_indicator_rounded,
                          color: ColorsManager.placeholder,
                          size: 20,
                        ),
                        horizontalSpace8,
                        Expanded(
                          child: Text(
                            col.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStylesManager.bold14.copyWith(
                              color: ColorsManager.mainText,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (col.max != null) ...[
                          horizontalSpace8,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: ColorsManager.primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: ColorsManager.primaryColor.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              'الدرجة: ${col.max}',
                              style: TextStylesManager.bold12.copyWith(
                                color: ColorsManager.primaryColor,
                              ),
                            ),
                          ),
                        ],
                        horizontalSpace8,
                        _CompactActionIconButton(
                          icon: Icons.edit_outlined,
                          iconColor: ColorsManager.mainText,
                          backgroundColor: ColorsManager.surfacePrimary,
                          borderColor: ColorsManager.borderColor,
                          tooltip: 'تعديل العمود',
                          onTap: () => _showColumnDialog(context, initial: col, index: index),
                        ),
                        horizontalSpace6,
                        _CompactActionIconButton(
                          icon: Icons.delete_outline_rounded,
                          iconColor: ColorsManager.errorColor,
                          backgroundColor: ColorsManager.errorColor.withValues(alpha: 0.08),
                          borderColor: ColorsManager.errorColor.withValues(alpha: 0.2),
                          tooltip: 'حذف العمود',
                          onTap: () => onRemoveColumn(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            verticalSpace8,

            Material(
              color: ColorsManager.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _showColumnDialog(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorsManager.primaryColor.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: ColorsManager.primaryColor,
                        size: 20,
                      ),
                      horizontalSpace8,
                      Text(
                        _cleanAddColumnLabel(),
                        style: TextStylesManager.bold14.copyWith(
                          color: ColorsManager.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateSelectorField extends StatelessWidget {
  final String label;
  final String dateText;
  final VoidCallback onTap;

  const _DateSelectorField({
    required this.label,
    required this.dateText,
    required this.onTap,
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
        Material(
          color: ColorsManager.background,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorsManager.borderColor, width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 19,
                    color: ColorsManager.primaryColor,
                  ),
                  horizontalSpace10,
                  Expanded(
                    child: Text(
                      dateText,
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'تغيير',
                      style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekOptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _WeekOptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? ColorsManager.primaryColor : ColorsManager.background,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderColor,
              width: isSelected ? 1.5 : 1.2,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: (isSelected ? TextStylesManager.bold13 : TextStylesManager.medium13).copyWith(
                color: isSelected ? Colors.white : ColorsManager.mainText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String tooltip;
  final VoidCallback onTap;

  const _CompactActionIconButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
        ),
      ),
    );
  }
}

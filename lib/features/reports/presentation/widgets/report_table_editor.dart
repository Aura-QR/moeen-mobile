import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_fields_sheet.dart';
import 'package:moean/features/reports/presentation/widgets/report_table_row_tile.dart';

/// A table: the header and each row open in a sheet, one field per column.
class ReportTableEditor extends StatelessWidget {
  final TableBlock block;

  const ReportTableEditor({super.key, required this.block});

  String _columnLabel(int index) {
    final header = block.columns[index].trim();
    return header.isEmpty
        ? appTranslation().get('report_table_column_n').replaceAll('{n}', '${index + 1}')
        : header;
  }

  Future<void> _editHeader(BuildContext context) async {
    final cubit = ReportEditorCubit.get(context);
    final values = await ReportFieldsSheet.show(context, titleKey: 'report_table_header', fields: [
      for (var i = 0; i < block.columns.length; i++)
        ReportField(
          label: appTranslation().get('report_table_column_n').replaceAll('{n}', '${i + 1}'),
          initialValue: block.columns[i],
          maxLength: 100,
        ),
    ]);
    if (values != null) cubit.updateBlock(block.setColumns(values));
  }

  Future<void> _editRow(BuildContext context, int index) async {
    final cubit = ReportEditorCubit.get(context);
    final row = block.squaredRows[index];
    final values = await ReportFieldsSheet.show(context, titleKey: 'report_table_edit_row', fields: [
      for (var i = 0; i < block.columns.length; i++)
        ReportField(label: _columnLabel(i), initialValue: row[i], maxLines: 3, maxLength: cubit.state.limits.itemChars),
    ]);
    if (values != null) cubit.updateBlock(block.setRow(index, values));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    final limits = cubit.state.limits;
    final rows = block.squaredRows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportTableRowTile(
          cells: [for (var i = 0; i < block.columns.length; i++) _columnLabel(i)],
          isHeader: true,
          onTap: () => _editHeader(context),
        ),
        for (var i = 0; i < rows.length; i++)
          ReportTableRowTile(
            cells: rows[i],
            onTap: () => _editRow(context, i),
            onRemove: () => cubit.updateBlock(block.removeRow(i)),
          ),
        verticalSpace8,
        Wrap(
          spacing: 4,
          children: [
            TextButton.icon(
              onPressed: rows.length < limits.tableRows ? () => cubit.updateBlock(block.addRow(limits.tableRows)) : null,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(appTranslation().get('report_table_add_row')),
            ),
            TextButton.icon(
              onPressed: block.columns.length < limits.tableColumns
                  ? () => cubit.updateBlock(block.addColumn(limits.tableColumns))
                  : null,
              icon: const Icon(Icons.view_column_outlined, size: 18),
              label: Text(appTranslation().get('report_table_add_column')),
            ),
            TextButton.icon(
              onPressed: block.columns.length > 1
                  ? () => cubit.updateBlock(block.removeColumn(block.columns.length - 1))
                  : null,
              icon: const Icon(Icons.remove_rounded, size: 18),
              label: Text(appTranslation().get('report_table_remove_column')),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: block.compact,
          activeThumbColor: ColorsManager.primaryColor,
          onChanged: (compact) => cubit.updateBlock(block.copyWith(compact: compact)),
          title: Text(
            appTranslation().get('report_table_compact'),
            style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
          ),
        ),
      ],
    );
  }
}

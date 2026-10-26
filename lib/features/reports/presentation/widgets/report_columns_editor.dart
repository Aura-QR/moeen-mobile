import 'package:flutter/material.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_editable_list.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_fields_sheet.dart';
import 'package:moean/features/reports/presentation/widgets/report_tap_to_edit.dart';

/// Two or three columns side by side, each a heading and its lines.
class ReportColumnsEditor extends StatelessWidget {
  final ColumnsBlock block;

  const ReportColumnsEditor({super.key, required this.block});

  Future<void> _editHeading(BuildContext context, int index) async {
    final cubit = ReportEditorCubit.get(context);
    final column = block.columns[index];
    final values = await ReportFieldsSheet.show(context, titleKey: 'report_column_heading', fields: [
      ReportField(label: '', initialValue: column.heading, maxLength: 150),
    ]);
    if (values != null) cubit.updateBlock(block.setColumn(index, column.copyWith(heading: values.first.trim())));
  }

  void _setItems(BuildContext context, int index, List<String> items) {
    ReportEditorCubit.get(context).updateBlock(block.setColumn(index, block.columns[index].copyWith(items: items)));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    final limits = cubit.state.limits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryChoiceChips<int>(
          options: const [2, 3],
          labelOf: (count) => appTranslation().get('report_columns_count').replaceAll('{n}', '$count'),
          isSelected: (count) => block.columns.length == count,
          onTap: (count) => cubit.updateBlock(block.setCount(count)),
        ),
        for (var i = 0; i < block.columns.length; i++) ...[
          verticalSpace12,
          ReportTapToEdit(
            text: block.columns[i].heading,
            placeholderKey: 'report_column_heading',
            style: TextStylesManager.bold14,
            onTap: () => _editHeading(context, i),
          ),
          PrimaryEditableList(
            title: appTranslation().get('report_table_column_n').replaceAll('{n}', '${i + 1}'),
            items: block.columns[i].items,
            maxItems: limits.listItems,
            maxLength: limits.itemChars,
            addKey: 'report_add_item',
            onAdd: (text) => _setItems(context, i, block.columns[i].items.addLine(text, limits.listItems)),
            onEdit: (index, text) => _setItems(context, i, block.columns[i].items.editLine(index, text)),
            onRemove: (index) => _setItems(context, i, block.columns[i].items.removeLine(index)),
            onReorder: (oldIndex, newIndex) =>
                _setItems(context, i, block.columns[i].items.moveLine(oldIndex, newIndex)),
          ),
        ],
      ],
    );
  }
}

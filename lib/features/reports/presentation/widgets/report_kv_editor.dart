import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_fields_sheet.dart';
import 'package:moean/features/reports/presentation/widgets/report_table_row_tile.dart';

/// Label and value rows.
class ReportKvEditor extends StatelessWidget {
  final KvBlock block;

  const ReportKvEditor({super.key, required this.block});

  /// [index] null adds a row.
  Future<void> _edit(BuildContext context, int? index) async {
    final cubit = ReportEditorCubit.get(context);
    final pair = index == null ? const ReportPair() : block.pairs[index];
    final values = await ReportFieldsSheet.show(context, titleKey: 'report_kind_kv', fields: [
      ReportField(label: appTranslation().get('report_label'), initialValue: pair.label, maxLength: 120),
      ReportField(
        label: appTranslation().get('report_value'),
        initialValue: pair.value,
        maxLines: 3,
        maxLength: cubit.state.limits.itemChars,
      ),
    ]);
    if (values == null) return;
    cubit.updateBlock(index == null
        ? block.addPair(values[0], values[1], cubit.state.limits.kvPairs)
        : block.setPair(index, values[0], values[1]));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < block.pairs.length; i++)
          ReportTableRowTile(
            cells: [block.pairs[i].label, block.pairs[i].value],
            onTap: () => _edit(context, i),
            onRemove: () => cubit.updateBlock(block.removePair(i)),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: block.pairs.length < cubit.state.limits.kvPairs ? () => _edit(context, null) : null,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(appTranslation().get('report_add_line')),
          ),
        ),
      ],
    );
  }
}

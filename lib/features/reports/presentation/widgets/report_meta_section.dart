import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/reports/data/models/report_input.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_fields_sheet.dart';
import 'package:moean/features/reports/presentation/widgets/report_table_row_tile.dart';

/// «بيانات التقرير»: label and value rows printed under the title.
/// In sensitive forms, labels remain editable while values are read-only.
class ReportMetaSection extends StatelessWidget {
  const ReportMetaSection({super.key});

  /// [row] null adds one.
  Future<void> _edit(BuildContext context, ReportMetaRow? row, {required bool isSensitive}) async {
    final cubit = ReportEditorCubit.get(context);
    final values = await ReportFieldsSheet.show(
      context,
      titleKey: 'report_meta',
      fields: [
        ReportField(
          label: appTranslation().get('report_label'),
          initialValue: row?.label ?? '',
          maxLength: 80,
        ),
        ReportField(
          label: appTranslation().get('report_value'),
          hint: isSensitive
              ? appTranslation().get('role_sensitive_handwritten_hint')
              : appTranslation().get('report_value'),
          initialValue: isSensitive ? '' : (row?.value ?? ''),
          maxLength: 200,
          readOnly: isSensitive,
        ),
      ],
    );
    if (values == null) return;
    if (row == null) {
      cubit.addMeta(values[0], values[1]);
    } else {
      cubit.updateMeta(row.id, values[0], values[1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.info_outline_rounded,
      title: appTranslation().get('report_meta'),
      child: BlocBuilder<ReportEditorCubit, ReportEditorState>(
        buildWhen: (previous, current) =>
            previous.input.meta != current.input.meta || previous.isSensitive != current.isSensitive,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final row in state.input.meta)
              ReportTableRowTile(
                cells: [row.label, isSensitiveCell(state.isSensitive, row.value)],
                onTap: () => _edit(context, row, isSensitive: state.isSensitive),
                onRemove: () => cubit.removeMeta(row.id),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: state.input.meta.length < state.limits.meta
                    ? () => _edit(context, null, isSensitive: state.isSensitive)
                    : null,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(appTranslation().get('report_add_line')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String isSensitiveCell(bool isSensitive, String value) => isSensitive ? '' : value;
}

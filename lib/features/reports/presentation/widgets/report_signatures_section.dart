import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_fields_sheet.dart';
import 'package:moean/features/reports/presentation/widgets/report_table_row_tile.dart';

/// «التوقيعات» at the end of the report: a title and an optional name each.
class ReportSignaturesSection extends StatelessWidget {
  const ReportSignaturesSection({super.key});

  /// [index] null adds one.
  Future<void> _edit(BuildContext context, int? index) async {
    final cubit = ReportEditorCubit.get(context);
    final signature = index == null ? null : cubit.state.input.signatures[index];
    final values = await ReportFieldsSheet.show(context, titleKey: 'report_signatures', fields: [
      ReportField(label: appTranslation().get('report_signature_title'), initialValue: signature?.title ?? '', maxLength: 80),
      ReportField(label: appTranslation().get('report_signature_name'), initialValue: signature?.name ?? '', maxLength: 80),
    ]);
    if (values == null) return;
    if (index == null) {
      cubit.addSignature(values[0], values[1]);
    } else {
      cubit.updateSignature(index, values[0], values[1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.draw_outlined,
      title: appTranslation().get('report_signatures'),
      child: BlocBuilder<ReportEditorCubit, ReportEditorState>(
        buildWhen: (previous, current) => previous.input.signatures != current.input.signatures,
        builder: (context, state) {
          final signatures = state.input.signatures;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < signatures.length; i++)
                ReportTableRowTile(
                  cells: [signatures[i].title, signatures[i].name],
                  onTap: () => _edit(context, i),
                  onRemove: () => cubit.removeSignature(i),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: signatures.length < ReportEditorState.maxSignatures ? () => _edit(context, null) : null,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(appTranslation().get('report_add_signature')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

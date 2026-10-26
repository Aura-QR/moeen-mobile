import 'package:flutter/material.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_fields_sheet.dart';
import 'package:moean/features/reports/presentation/widgets/report_tap_to_edit.dart';

/// A heading (one line) or a paragraph.
class ReportTextBlockEditor extends StatelessWidget {
  final ReportBlock block;

  const ReportTextBlockEditor({super.key, required this.block});

  bool get _isHeading => block is HeadingBlock;

  String get _text => switch (block) {
        HeadingBlock(:final text) => text,
        ParagraphBlock(:final text) => text,
        _ => '',
      };

  Future<void> _edit(BuildContext context) async {
    final cubit = ReportEditorCubit.get(context);
    final values = await ReportFieldsSheet.show(
      context,
      titleKey: _isHeading ? 'report_kind_heading' : 'report_kind_paragraph',
      fields: [
        ReportField(
          label: '',
          initialValue: _text,
          maxLines: _isHeading ? 1 : 8,
          maxLength: _isHeading ? 200 : cubit.state.limits.textChars,
        ),
      ],
    );
    if (values == null) return;
    final current = block;
    cubit.updateBlock(switch (current) {
      HeadingBlock() => current.copyWith(text: values.first.trim()),
      ParagraphBlock() => current.copyWith(text: values.first.trim()),
      _ => current,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReportTapToEdit(
      text: _text,
      placeholderKey: 'report_tap_to_write',
      style: _isHeading ? TextStylesManager.bold16 : TextStylesManager.regular14,
      onTap: () => _edit(context),
    );
  }
}

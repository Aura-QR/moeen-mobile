import 'package:flutter/material.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_fields_sheet.dart';
import 'package:moean/features/reports/presentation/widgets/report_tap_to_edit.dart';

/// A heading (one line) or a paragraph.
/// On sensitive forms, headings remain editable while paragraph text is read-only.
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
    if (cubit.state.isSensitive && !_isHeading) return;
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
    final isSensitiveParagraph = ReportEditorCubit.get(context).state.isSensitive && !_isHeading;
    return ReportTapToEdit(
      text: isSensitiveParagraph ? '' : _text,
      placeholderKey: isSensitiveParagraph ? 'role_sensitive_handwritten_hint' : 'report_tap_to_write',
      style: _isHeading ? TextStylesManager.bold16 : TextStylesManager.regular14,
      onTap: isSensitiveParagraph ? null : () => _edit(context),
    );
  }
}

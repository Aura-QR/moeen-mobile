import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// One field of [ReportFieldsSheet]. [label] is shown as is (a column's
/// header, or a translated label).
class ReportField {
  final String label;
  final String initialValue;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;

  const ReportField({
    required this.label,
    this.initialValue = '',
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
  });
}

/// A scrollable sheet of text fields: a table row, a chart series, a link.
/// Pops with the texts in order, or null when dismissed. Holds only the
/// controllers.
class ReportFieldsSheet extends StatefulWidget {
  final String titleKey;
  final List<ReportField> fields;

  const ReportFieldsSheet({super.key, required this.titleKey, required this.fields});

  static Future<List<String>?> show(BuildContext context, {required String titleKey, required List<ReportField> fields}) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ReportFieldsSheet(titleKey: titleKey, fields: fields),
    );
  }

  @override
  State<ReportFieldsSheet> createState() => _ReportFieldsSheetState();
}

class _ReportFieldsSheetState extends State<ReportFieldsSheet> {
  late final List<TextEditingController> _controllers = [
    for (final field in widget.fields) TextEditingController(text: field.initialValue),
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            children: [
              Text(
                appTranslation().get(widget.titleKey),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace14,
              for (var i = 0; i < widget.fields.length; i++) ...[
                PrimaryTextField(
                  controller: _controllers[i],
                  label: widget.fields[i].label,
                  hint: widget.fields[i].label,
                  maxLines: widget.fields[i].maxLines,
                  maxLength: widget.fields[i].maxLength,
                  keyboardType: widget.fields[i].keyboardType,
                ),
                verticalSpace10,
              ],
              verticalSpace6,
              PrimaryElevatedButton(
                text: appTranslation().get('save'),
                onPressed: () => Navigator.pop(context, _controllers.map((c) => c.text).toList()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

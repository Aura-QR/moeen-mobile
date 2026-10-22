import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/widgets/custom_app_dialog.dart';

/// One text field in a [PrimaryInputDialog].
class PrimaryInputField {
  final String hintKey;
  final String initialValue;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;

  const PrimaryInputField({
    required this.hintKey,
    this.initialValue = '',
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
  });
}

/// A dialog with text fields. Pops with the values, in field order.
class PrimaryInputDialog extends StatefulWidget {
  final String titleKey;
  final List<PrimaryInputField> fields;

  const PrimaryInputDialog({super.key, required this.titleKey, required this.fields});

  static Future<List<String>?> show(
    BuildContext context, {
    required String titleKey,
    required List<PrimaryInputField> fields,
  }) {
    return showDialog<List<String>>(
      context: context,
      builder: (_) => PrimaryInputDialog(titleKey: titleKey, fields: fields),
    );
  }

  @override
  State<PrimaryInputDialog> createState() => _PrimaryInputDialogState();
}

class _PrimaryInputDialogState extends State<PrimaryInputDialog> {
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
    return CustomAppDialog(
      title: appTranslation().get(widget.titleKey),
      message: '',
      cancelText: appTranslation().get('cancel'),
      confirmText: appTranslation().get('save'),
      onConfirm: () => Navigator.pop(context, _controllers.map((c) => c.text).toList()),
      child: Column(
        children: [
          for (var i = 0; i < widget.fields.length; i++) ...[
            if (i > 0) verticalSpace10,
            PrimaryTextField(
              controller: _controllers[i],
              hint: appTranslation().get(widget.fields[i].hintKey),
              maxLines: widget.fields[i].maxLines,
              maxLength: widget.fields[i].maxLength,
              keyboardType: widget.fields[i].keyboardType,
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';

/// A text field per header field; used by the defaults form and by the
/// per-document overrides.
class DocumentHeaderFields extends StatelessWidget {
  final Map<DocumentHeaderField, TextEditingController> controllers;

  const DocumentHeaderFields({super.key, required this.controllers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final field in DocumentHeaderField.values) ...[
          PrimaryTextField(
            controller: controllers[field]!,
            label: appTranslation().get(field.labelKey),
            hint: appTranslation().get('${field.labelKey}_hint'),
            maxLength: field.maxLength,
          ),
          if (field != DocumentHeaderField.values.last) verticalSpace12,
        ],
      ],
    );
  }
}

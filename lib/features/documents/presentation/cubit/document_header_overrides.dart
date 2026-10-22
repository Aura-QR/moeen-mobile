import 'package:flutter/material.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';

/// The «تعديل لهذا المستند فقط» fields (`input.header`), owned by a tool's cubit.
class DocumentHeaderOverrides {
  final Map<DocumentHeaderField, TextEditingController> controllers = {
    for (final field in DocumentHeaderField.values) field: TextEditingController(),
  };

  /// Starts empty fields from the defaults, so the teacher edits what they see.
  void prefill(DocumentDefaultsModel defaults) {
    for (final field in DocumentHeaderField.values) {
      final controller = controllers[field]!;
      if (controller.text.isEmpty) controller.text = defaults.text(field);
    }
  }

  void fill(Map<String, dynamic> header) {
    for (final field in DocumentHeaderField.values) {
      controllers[field]!.text = header[field.jsonKey]?.toString() ?? '';
    }
  }

  /// Only values that differ from [defaults]; the rest keep following them.
  Map<String, String> toJson(DocumentDefaultsModel defaults) => {
        for (final field in DocumentHeaderField.values)
          if (_value(field).isNotEmpty && _value(field) != defaults.text(field)) field.jsonKey: _value(field),
      };

  String _value(DocumentHeaderField field) => controllers[field]!.text.trim();

  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
  }
}

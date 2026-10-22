import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/presentation/cubit/document_header_overrides.dart';

const _defaults = DocumentDefaultsModel(texts: {
  DocumentHeaderField.schoolName: 'ابتدائية الأمل',
  DocumentHeaderField.principalName: 'أ. نورة',
});

void main() {
  late DocumentHeaderOverrides overrides;

  setUp(() => overrides = DocumentHeaderOverrides());
  tearDown(() => overrides.dispose());

  test('prefill starts empty fields from the defaults', () {
    overrides.controllers[DocumentHeaderField.schoolName]!.text = 'مدرسة أخرى';
    overrides.prefill(_defaults);

    expect(overrides.controllers[DocumentHeaderField.schoolName]!.text, 'مدرسة أخرى');
    expect(overrides.controllers[DocumentHeaderField.principalName]!.text, 'أ. نورة');
  });

  test('toJson keeps only values that differ from the defaults', () {
    overrides.prefill(_defaults);
    overrides.controllers[DocumentHeaderField.schoolName]!.text = ' مدرسة أخرى ';
    overrides.controllers[DocumentHeaderField.deputyName]!.text = 'أ. هند';

    expect(overrides.toJson(_defaults), {'school_name': 'مدرسة أخرى', 'deputy_name': 'أ. هند'});
  });

  test('fill reads a saved header', () {
    overrides.fill({'school_name': 'مدرسة أخرى'});

    expect(overrides.controllers[DocumentHeaderField.schoolName]!.text, 'مدرسة أخرى');
    expect(overrides.controllers[DocumentHeaderField.principalName]!.text, isEmpty);
  });
}

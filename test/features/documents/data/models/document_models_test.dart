import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_export_models.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/data/models/document_upload_rules.dart';
import 'package:moean/features/documents/data/services/document_file_service.dart';

void main() {
  group('DocumentDefaultsModel', () {
    test('reads resolved values and drops empty ones', () {
      final defaults = DocumentDefaultsModel.fromJson({
        'teacher_name': 'سارة أحمد',
        'school_name': ' ابتدائية الأمل ',
        'deputy_name': null,
        'principal_name': '',
        'region_calendar': 'western',
        'gender_form': 'female',
        'logo_right': 'documents/12/uploads/a.png',
        'logo_left': null,
      });

      expect(defaults.text(DocumentHeaderField.schoolName), 'ابتدائية الأمل');
      expect(defaults.texts.containsKey(DocumentHeaderField.principalName), isFalse);
      expect(defaults.genderForm, DocumentGenderForm.female);
      expect(defaults.regionCalendar, DocumentRegionCalendar.western);
      expect(defaults.logos, {DocumentLogoSlot.right: 'documents/12/uploads/a.png'});
    });

    test('unknown wording and calendar fall back to the API defaults', () {
      final defaults = DocumentDefaultsModel.fromJson({'gender_form': 'x', 'region_calendar': null});

      expect(defaults.genderForm, DocumentGenderForm.male);
      expect(defaults.regionCalendar, DocumentRegionCalendar.general);
    });

    test('toJson sends the whole form, with nulls for empty fields', () {
      final json = const DocumentDefaultsModel(
        texts: {DocumentHeaderField.schoolName: 'الأمل'},
        genderForm: DocumentGenderForm.female,
        logos: {DocumentLogoSlot.left: 'documents/12/uploads/b.png'},
      ).toJson();

      expect(json['school_name'], 'الأمل');
      expect(json.containsKey('principal_name'), isTrue);
      expect(json['principal_name'], isNull);
      expect(json['gender_form'], 'female');
      expect(json['region_calendar'], 'general');
      expect(json['logo_right'], isNull);
      expect(json['logo_left'], 'documents/12/uploads/b.png');
    });
  });

  test('DocumentModel reads the full document with signed image URLs', () {
    final document = DocumentModel.fromJson({
      'id': 12,
      'type': 'strategy_documentation',
      'title': 'توثيق جيكسو — دورة الماء',
      'status': 'final',
      'updated_at': '2026-10-22T09:00:00+03:00',
      'input': {'strategy_key': 'jigsaw'},
      'images': [
        {'storage_path': 'documents/12/uploads/a.jpg', 'url': 'https://r2/a.jpg'},
      ],
    });

    expect(document.isFinal, isTrue);
    expect(document.input['strategy_key'], 'jigsaw');
    expect(document.images.single.url, 'https://r2/a.jpg');
    expect(document.updatedAt, isNotNull);
  });

  test('DocumentsPageModel reads meta and knows if more pages exist', () {
    final page = DocumentsPageModel.fromJson({
      'data': [
        {'id': 1, 'type': 'strategy_documentation', 'title': 'أ', 'status': 'draft'},
      ],
      'meta': {'current_page': 1, 'last_page': 3, 'total': 41},
    });

    expect(page.items.single.input, isEmpty);
    expect(page.hasMore, isTrue);
    expect(page.total, 41);
  });

  test('DocumentExportModel status helpers', () {
    DocumentExportModel export(String status) => DocumentExportModel.fromJson({
          'id': 31,
          'format': 'docx',
          'status': status,
          'is_current': true,
          'url': null,
          'file_name': 'a.docx',
          'error': null,
        });

    expect(export('pending').isPending, isTrue);
    expect(export('rendering').isPending, isTrue);
    expect(export('done').isDone, isTrue);
    expect(export('failed').isFailed, isTrue);
  });

  test('DocumentTheme falls back to teal', () {
    expect(DocumentTheme.fromJson('purple'), DocumentTheme.purple);
    expect(DocumentTheme.fromJson('pink'), DocumentTheme.teal);
    expect(DocumentTheme.fromJson(null), DocumentTheme.teal);
  });

  group('DocumentUploadRules.validate', () {
    DevicePickedFile file(String? mime, int size) =>
        DevicePickedFile(bytes: Uint8List(size), name: 'a', mime: mime);

    test('accepts JPEG, PNG and WebP up to 10 MB', () {
      expect(DocumentUploadRules.validate(file('image/jpeg', 100)), isNull);
      expect(DocumentUploadRules.validate(file('image/webp', DocumentUploadRules.maxBytes)), isNull);
    });

    test('rejects PDF, unknown types and big files', () {
      expect(DocumentUploadRules.validate(file('application/pdf', 100)), 'document_unsupported_image');
      expect(DocumentUploadRules.validate(file(null, 100)), 'document_unsupported_image');
      expect(DocumentUploadRules.validate(file('image/png', DocumentUploadRules.maxBytes + 1)), 'document_image_too_large');
    });
  });

  test('safeFileName drops characters file systems reject', () {
    expect(DocumentFileService.safeFileName('توثيق جيكسو — الفصل 5/1'), 'توثيق جيكسو — الفصل 5 1');
    expect(DocumentFileService.safeFileName('a:b*"c"?.pdf'), 'a b c .pdf');
    expect(DocumentFileService.safeFileName('  '), 'document');
  });
}

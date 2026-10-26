import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/qr_codes/data/models/shared_file_model.dart';

void main() {
  group('SharedFileModel', () {
    test('fromJson parses complete file object', () {
      final json = {
        'id': 12,
        'title': 'ملخص الوحدة',
        'file_name': 'درس الكسور.pdf',
        'mime': 'application/pdf',
        'kind': 'pdf',
        'byte_size': 482113,
        'downloads': 3,
        'expires_at': '2026-11-23T10:00:00+00:00',
        'is_expired': false,
        'share_url': 'https://haderedu.com/f/Xk3',
        'qr_png': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
        'created_at': '2026-10-24T10:00:00+00:00',
      };

      final model = SharedFileModel.fromJson(json);

      expect(model.id, 12);
      expect(model.title, 'ملخص الوحدة');
      expect(model.displayName, 'ملخص الوحدة');
      expect(model.fileName, 'درس الكسور.pdf');
      expect(model.mime, 'application/pdf');
      expect(model.kind, SharedFileKind.pdf);
      expect(model.byteSize, 482113);
      expect(model.downloads, 3);
      expect(model.isExpired, isFalse);
      expect(model.shareUrl, 'https://haderedu.com/f/Xk3');
      expect(model.qrPngBytes, isNotNull);
    });

    test('displayName falls back to fileName when title is null or empty', () {
      final json = {
        'id': 15,
        'title': null,
        'file_name': 'ورقة_عمل.docx',
        'mime': 'application/msword',
        'kind': 'word',
        'byte_size': 12000,
        'share_url': 'https://haderedu.com/f/abc',
      };

      final model = SharedFileModel.fromJson(json);

      expect(model.displayName, 'ورقة_عمل.docx');
    });

    test('SharedFileKind handles unknown kind gracefully', () {
      expect(SharedFileKind.fromApi('unknown_type'), SharedFileKind.other);
      expect(SharedFileKind.fromApi(null), SharedFileKind.other);
      expect(SharedFileKind.fromApi('PDF'), SharedFileKind.pdf);
      expect(SharedFileKind.fromApi('video'), SharedFileKind.video);
    });

    test('qrPngBytes correctly decodes raw or prefixed base64', () {
      const rawBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
      final expectedBytes = base64Decode(rawBase64);

      const modelWithPrefix = SharedFileModel(
        id: 1,
        fileName: 'test.png',
        mime: 'image/png',
        kind: SharedFileKind.image,
        byteSize: 100,
        shareUrl: 'https://haderedu.com',
        qrPng: 'data:image/png;base64,$rawBase64',
      );
      expect(modelWithPrefix.qrPngBytes, expectedBytes);

      const modelWithoutPrefix = SharedFileModel(
        id: 2,
        fileName: 'test.png',
        mime: 'image/png',
        kind: SharedFileKind.image,
        byteSize: 100,
        shareUrl: 'https://haderedu.com',
        qrPng: rawBase64,
      );
      expect(modelWithoutPrefix.qrPngBytes, expectedBytes);

      const modelNullQr = SharedFileModel(
        id: 3,
        fileName: 'test.png',
        mime: 'image/png',
        kind: SharedFileKind.image,
        byteSize: 100,
        shareUrl: 'https://haderedu.com',
        qrPng: null,
      );
      expect(modelNullQr.qrPngBytes, isNull);
    });
  });
}

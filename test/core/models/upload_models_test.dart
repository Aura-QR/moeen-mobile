import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:moean/core/models/upload_models.dart';

void main() {
  group('DevicePickedFile.mimeFromName', () {
    test('maps the accepted types', () {
      expect(DevicePickedFile.mimeFromName('a.JPG'), 'image/jpeg');
      expect(DevicePickedFile.mimeFromName('a.jpeg'), 'image/jpeg');
      expect(DevicePickedFile.mimeFromName('a.png'), 'image/png');
      expect(DevicePickedFile.mimeFromName('a.webp'), 'image/webp');
      expect(DevicePickedFile.mimeFromName('خطة.pdf'), 'application/pdf');
    });

    test('rejects HEIC and names without an extension', () {
      expect(DevicePickedFile.mimeFromName('IMG_1.HEIC'), isNull);
      expect(DevicePickedFile.mimeFromName('file'), isNull);
    });
  });

  test('isImage is true for image mimes only', () {
    expect(DevicePickedFile(bytes: Uint8List(1), name: 'a.png', mime: 'image/png').isImage, isTrue);
    expect(DevicePickedFile(bytes: Uint8List(1), name: 'a.pdf', mime: 'application/pdf').isImage, isFalse);
    expect(DevicePickedFile(bytes: Uint8List(1), name: 'a.heic', mime: null).isImage, isFalse);
  });

  test('StorageUploadTicketModel keeps the headers as strings', () {
    final ticket = StorageUploadTicketModel.fromJson({
      'upload_url': 'https://r2/put',
      'headers': {'Content-Type': 'image/jpeg', 'x-amz-acl': 1},
      'storage_path': 'documents/12/uploads/a.jpg',
    });

    expect(ticket.uploadUrl, 'https://r2/put');
    expect(ticket.headers, {'Content-Type': 'image/jpeg', 'x-amz-acl': '1'});
    expect(ticket.storagePath, 'documents/12/uploads/a.jpg');
  });
}

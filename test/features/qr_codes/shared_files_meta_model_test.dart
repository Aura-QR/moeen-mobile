import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/qr_codes/data/models/shared_files_meta_model.dart';

void main() {
  group('SharedFilesMetaModel', () {
    test('mimeForExtension finds mime from types and handles fallbacks', () {
      final json = {
        'used_bytes': 1000,
        'quota_bytes': 5000,
        'max_file_bytes': 10000,
        'expiry_days': [7, 30, 90, 365],
        'default_expiry_days': 30,
        'types': [
          {'mime': 'application/pdf', 'ext': 'pdf', 'kind': 'pdf'},
          {'mime': 'image/jpeg', 'ext': 'jpg', 'kind': 'image'},
        ],
      };

      final meta = SharedFilesMetaModel.fromJson(json);

      expect(meta.mimeForExtension('pdf'), 'application/pdf');
      expect(meta.mimeForExtension('.PDF'), 'application/pdf');
      expect(meta.mimeForExtension('jpg'), 'image/jpeg');

      // Fallbacks
      expect(meta.mimeForExtension('MOV'), 'video/quicktime');
      expect(meta.mimeForExtension('.heic'), 'image/heic');

      // Unknown
      expect(meta.mimeForExtension('exe'), isNull);
      expect(meta.mimeForExtension(''), isNull);
    });

    test('usedRatio clamps between 0.0 and 1.0', () {
      const normal = SharedFilesMetaModel(usedBytes: 50, quotaBytes: 100);
      expect(normal.usedRatio, 0.5);

      const overQuota = SharedFilesMetaModel(usedBytes: 150, quotaBytes: 100);
      expect(overQuota.usedRatio, 1.0);

      const zeroQuota = SharedFilesMetaModel(usedBytes: 50, quotaBytes: 0);
      expect(zeroQuota.usedRatio, 0.0);
    });

    test('extensions list extracts clean set of extensions', () {
      const meta = SharedFilesMetaModel(
        types: [
          SharedFileTypeModel(mime: 'application/pdf', ext: '.pdf', kind: 'pdf'),
          SharedFileTypeModel(mime: 'image/png', ext: 'png', kind: 'image'),
        ],
      );

      expect(meta.extensions, containsAll(['pdf', 'png']));
    });
  });
}

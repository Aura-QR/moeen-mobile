import 'package:moean/core/models/upload_models.dart';

/// What `POST /documents/uploads` accepts (DOCUMENTS_API.md § 3).
abstract final class DocumentUploadRules {
  static const int maxBytes = 10 * 1024 * 1024;
  static const int maxImagesPerDocument = 6;
  static const Set<String> allowedMimes = {'image/jpeg', 'image/png', 'image/webp'};

  /// A translation key when [file] can't be uploaded, otherwise null.
  static String? validate(DevicePickedFile file) {
    if (!allowedMimes.contains(file.mime)) return 'document_unsupported_image';
    if (file.byteSize > maxBytes) return 'document_image_too_large';
    return null;
  }
}

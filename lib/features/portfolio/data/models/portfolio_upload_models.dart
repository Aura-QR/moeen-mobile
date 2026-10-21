import 'dart:typed_data';

/// Where the teacher picks evidence from.
enum PortfolioFileSource { camera, gallery, pdf }

/// A file picked on the device, ready to upload.
class PortfolioPickedFile {
  final Uint8List bytes;
  final String name;

  /// Null when the extension isn't one the API accepts (e.g. HEIC).
  final String? mime;

  const PortfolioPickedFile({
    required this.bytes,
    required this.name,
    required this.mime,
  });

  int get byteSize => bytes.length;

  /// The API accepts JPEG, PNG, WebP and PDF only.
  static String? mimeFromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0) return null;
    switch (name.substring(dot + 1).toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return null;
    }
  }
}

/// Step 1 of an upload: a signed R2 URL to PUT the bytes to.
class PortfolioUploadTicketModel {
  final String uploadUrl;
  final Map<String, String> headers;
  final String storagePath;

  const PortfolioUploadTicketModel({
    required this.uploadUrl,
    required this.headers,
    required this.storagePath,
  });

  factory PortfolioUploadTicketModel.fromJson(Map<String, dynamic> json) {
    final headers = json['headers'];
    return PortfolioUploadTicketModel(
      uploadUrl: json['upload_url']?.toString() ?? '',
      headers: headers is Map
          ? headers.map((key, value) => MapEntry(key.toString(), value.toString()))
          : const {},
      storagePath: json['storage_path']?.toString() ?? '',
    );
  }
}

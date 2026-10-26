import 'dart:typed_data';

/// Where a file is picked from on the device.
enum DeviceFileSource { camera, gallery, pdf }

/// A file picked on the device, ready to upload.
class DevicePickedFile {
  final Uint8List bytes;
  final String name;

  /// Null when the extension isn't one the API accepts (e.g. HEIC).
  final String? mime;

  const DevicePickedFile({
    required this.bytes,
    required this.name,
    required this.mime,
  });

  int get byteSize => bytes.length;

  bool get isImage => mime != null && mime!.startsWith('image/');

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

/// A picked file read from disk when uploaded, for files too big to hold in memory.
class DevicePickedPath {
  final String path;
  final String name;
  final int byteSize;

  const DevicePickedPath({
    required this.path,
    required this.name,
    required this.byteSize,
  });

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot >= 0 ? name.substring(dot + 1).toLowerCase() : '';
  }
}

/// Step 1 of an upload: a signed R2 URL to PUT the bytes to.
class StorageUploadTicketModel {
  final String uploadUrl;
  final Map<String, String> headers;
  final String storagePath;

  const StorageUploadTicketModel({
    required this.uploadUrl,
    required this.headers,
    required this.storagePath,
  });

  factory StorageUploadTicketModel.fromJson(Map<String, dynamic> json) {
    final headers = json['headers'];
    return StorageUploadTicketModel(
      uploadUrl: json['upload_url']?.toString() ?? '',
      headers: headers is Map
          ? headers.map((key, value) => MapEntry(key.toString(), value.toString()))
          : const {},
      storagePath: json['storage_path']?.toString() ?? '',
    );
  }
}

/// Models for printing and exports (DOCUMENTS_API.md § 4).
library;

/// `GET /documents/{id}/print`: the saved version as one A4 HTML page.
class DocumentPrintModel {
  final String html;
  final String fileName;

  const DocumentPrintModel({required this.html, required this.fileName});

  static final RegExp _landscapePage = RegExp(r'@page\s*\{[^}]*size:\s*A4\s+landscape');

  /// The page sets A4 landscape (`@page { size: A4 landscape }`), as certificates,
  /// the activities plan and wide class sheets do. The PDF must use the same size.
  bool get isLandscape => _landscapePage.hasMatch(html);

  factory DocumentPrintModel.fromJson(Map<String, dynamic> json) {
    return DocumentPrintModel(
      html: json['html']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
    );
  }
}

abstract final class DocumentExportFormat {
  static const String docx = 'docx';
  static const String xlsx = 'xlsx';
}

/// A server-built file. Poll while [isPending].
class DocumentExportModel {
  final int id;
  final String format;
  final String status;
  final bool isCurrent;

  /// Signed for 60 minutes. Don't store it.
  final String? url;
  final String fileName;
  final String? error;

  const DocumentExportModel({
    required this.id,
    required this.format,
    required this.status,
    required this.isCurrent,
    required this.url,
    required this.fileName,
    required this.error,
  });

  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';
  bool get isPending => !isDone && !isFailed;

  factory DocumentExportModel.fromJson(Map<String, dynamic> json) {
    return DocumentExportModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      format: json['format']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      isCurrent: json['is_current'] != false,
      url: json['url']?.toString(),
      fileName: json['file_name']?.toString() ?? '',
      error: json['error']?.toString(),
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

enum SharedFileKind {
  pdf,
  image,
  word,
  excel,
  powerpoint,
  video,
  other;

  static SharedFileKind fromApi(String? raw) {
    if (raw == null) return SharedFileKind.other;
    switch (raw.toLowerCase().trim()) {
      case 'pdf':
        return SharedFileKind.pdf;
      case 'image':
        return SharedFileKind.image;
      case 'word':
        return SharedFileKind.word;
      case 'excel':
        return SharedFileKind.excel;
      case 'powerpoint':
        return SharedFileKind.powerpoint;
      case 'video':
        return SharedFileKind.video;
      default:
        return SharedFileKind.other;
    }
  }
}

class SharedFileModel extends Equatable {
  final int id;
  final String? title;
  final String fileName;
  final String mime;
  final SharedFileKind kind;
  final int byteSize;
  final int downloads;
  final DateTime? expiresAt;
  final bool isExpired;
  final String shareUrl;
  final String? qrPng;
  final DateTime? createdAt;

  const SharedFileModel({
    required this.id,
    this.title,
    required this.fileName,
    required this.mime,
    required this.kind,
    required this.byteSize,
    this.downloads = 0,
    this.expiresAt,
    this.isExpired = false,
    required this.shareUrl,
    this.qrPng,
    this.createdAt,
  });

  String get displayName =>
      (title != null && title!.trim().isNotEmpty) ? title!.trim() : fileName;

  Uint8List? get qrPngBytes {
    if (qrPng == null || qrPng!.trim().isEmpty) return null;
    try {
      var raw = qrPng!.trim();
      const prefix = 'data:image/png;base64,';
      if (raw.startsWith(prefix)) {
        raw = raw.substring(prefix.length);
      }
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  factory SharedFileModel.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}') ?? 0;
    final title = json['title']?.toString();
    final fileName = json['file_name']?.toString() ?? json['original_name']?.toString() ?? '';
    final mime = json['mime']?.toString() ?? 'application/octet-stream';
    final kind = SharedFileKind.fromApi(json['kind']?.toString());
    final byteSize = int.tryParse('${json['byte_size']}') ?? 0;
    final downloads = int.tryParse('${json['downloads']}') ?? 0;

    DateTime? expiresAt;
    if (json['expires_at'] != null) {
      expiresAt = DateTime.tryParse(json['expires_at'].toString());
    }

    final isExpired = json['is_expired'] == true ||
        (expiresAt != null && DateTime.now().isAfter(expiresAt));

    final shareUrl = json['share_url']?.toString() ?? '';
    final qrPng = json['qr_png']?.toString();

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString());
    }

    return SharedFileModel(
      id: id,
      title: title,
      fileName: fileName,
      mime: mime,
      kind: kind,
      byteSize: byteSize,
      downloads: downloads,
      expiresAt: expiresAt,
      isExpired: isExpired,
      shareUrl: shareUrl,
      qrPng: qrPng,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        fileName,
        mime,
        kind,
        byteSize,
        downloads,
        expiresAt,
        isExpired,
        shareUrl,
        qrPng,
        createdAt,
      ];
}

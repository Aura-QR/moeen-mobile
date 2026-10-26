import 'package:equatable/equatable.dart';

class SharedFileTypeModel extends Equatable {
  final String mime;
  final String ext;
  final String kind;

  const SharedFileTypeModel({
    required this.mime,
    required this.ext,
    required this.kind,
  });

  factory SharedFileTypeModel.fromJson(Map<String, dynamic> json) {
    return SharedFileTypeModel(
      mime: json['mime']?.toString() ?? '',
      ext: json['ext']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [mime, ext, kind];
}

class SharedFilesMetaModel extends Equatable {
  final int usedBytes;
  final int quotaBytes;
  final int maxFileBytes;
  final List<int> expiryDays;
  final int defaultExpiryDays;
  final List<SharedFileTypeModel> types;

  const SharedFilesMetaModel({
    this.usedBytes = 0,
    this.quotaBytes = 0,
    this.maxFileBytes = 100 * 1024 * 1024,
    this.expiryDays = const [7, 30, 90, 365],
    this.defaultExpiryDays = 30,
    this.types = const [],
  });

  double get usedRatio =>
      quotaBytes > 0 ? (usedBytes / quotaBytes).clamp(0.0, 1.0) : 0.0;

  List<String> get extensions => types
      .map((t) => t.ext.toLowerCase().replaceAll('.', '').trim())
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList();

  String? mimeForExtension(String rawExt) {
    final clean = rawExt.toLowerCase().replaceAll('.', '').trim();
    if (clean.isEmpty) return null;

    for (final t in types) {
      final typeExt = t.ext.toLowerCase().replaceAll('.', '').trim();
      if (typeExt == clean && t.mime.isNotEmpty) {
        return t.mime;
      }
    }

    // Required fallbacks
    if (clean == 'mov') return 'video/quicktime';
    if (clean == 'heic') return 'image/heic';

    return null;
  }

  factory SharedFilesMetaModel.fromJson(Map<String, dynamic> json) {
    final usedBytes = int.tryParse('${json['used_bytes']}') ?? 0;
    final quotaBytes = int.tryParse('${json['quota_bytes']}') ?? 0;
    final maxFileBytes =
        int.tryParse('${json['max_file_bytes']}') ?? 100 * 1024 * 1024;
    final defaultExpiryDays =
        int.tryParse('${json['default_expiry_days']}') ?? 30;

    List<int> expiryDays = const [7, 30, 90, 365];
    if (json['expiry_days'] is List) {
      final parsed = (json['expiry_days'] as List)
          .map((e) => int.tryParse('$e'))
          .whereType<int>()
          .toList();
      if (parsed.isNotEmpty) {
        expiryDays = parsed;
      }
    }

    List<SharedFileTypeModel> types = const [];
    if (json['types'] is List) {
      types = (json['types'] as List)
          .whereType<Map<String, dynamic>>()
          .map(SharedFileTypeModel.fromJson)
          .toList();
    }

    return SharedFilesMetaModel(
      usedBytes: usedBytes,
      quotaBytes: quotaBytes,
      maxFileBytes: maxFileBytes,
      expiryDays: expiryDays,
      defaultExpiryDays: defaultExpiryDays,
      types: types,
    );
  }

  @override
  List<Object?> get props => [
        usedBytes,
        quotaBytes,
        maxFileBytes,
        expiryDays,
        defaultExpiryDays,
        types,
      ];
}

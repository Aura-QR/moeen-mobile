/// Models for `/documents` responses (DOCUMENTS_API.md § 2).
library;

import 'dart:typed_data';

abstract final class DocumentStatus {
  static const String draft = 'draft';
  static const String finalized = 'final';
}

/// Every registered document type. Add new tools here.
abstract final class DocumentTypes {
  static const String strategyDocumentation = 'strategy_documentation';
  static const String remedialPlan = 'remedial_plan';
  static const String enrichmentPlan = 'enrichment_plan';
  static const String activitiesPlan = 'activities_plan';
  static const String gradeAnalysis = 'grade_analysis';
  static const String certificates = 'certificates';
  static const String classSheet = 'class_sheet';
  static const String lessonPreparation = 'lesson_preparation';
  static const String report = 'report';
  static const String conceptMap = 'concept_map';
  static const String readingComprehension = 'reading_comprehension';

  /// Made by the server from a portfolio (T9); it has no form.
  static const String performanceFile = 'performance_file';

  static const List<String> all = [
    strategyDocumentation,
    remedialPlan,
    enrichmentPlan,
    activitiesPlan,
    gradeAnalysis,
    certificates,
    classSheet,
    lessonPreparation,
    report,
    performanceFile,
    conceptMap,
    readingComprehension,
  ];

  static String labelKey(String type) => 'document_type_$type';

  /// Tools whose tables matter, so their export offers Excel.
  static bool hasExcel(String type) =>
      type == classSheet || type == gradeAnalysis;
}

/// The `element` value that keeps a document out of the performance file.
const String noDocumentElement = 'none';

/// The exam a document was copied into by `POST /documents/{id}/to-exam`
/// (L12 «الفهم القرائي»). The share flow continues with [examId].
class DocumentExamRef {
  final int examId;
  final String title;

  const DocumentExamRef({required this.examId, this.title = ''});

  factory DocumentExamRef.fromJson(Map<String, dynamic> json) {
    final exam = json['exam'] is Map ? Map<String, dynamic>.from(json['exam'] as Map) : json;
    return DocumentExamRef(
      examId: exam['id'] is int ? exam['id'] as int : int.tryParse('${exam['id']}') ?? 0,
      title: exam['title']?.toString() ?? '',
    );
  }
}

/// A photo in `input.images`, with its signed URL once saved.
class DocumentImageModel {
  final String storagePath;

  /// Signed for 60 minutes; null for a photo picked in this session.
  final String? url;

  /// The picked photo, shown until the document is reopened.
  final Uint8List? bytes;

  const DocumentImageModel({required this.storagePath, this.url, this.bytes});

  factory DocumentImageModel.fromJson(Map<String, dynamic> json) {
    return DocumentImageModel(
      storagePath: json['storage_path']?.toString() ?? '',
      url: json['url']?.toString(),
    );
  }
}

class DocumentModel {
  final int id;
  final String type;
  final String title;
  final String status;

  /// The portfolio element this document is evidence for (T9), or null.
  final String? element;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Only on the full document, not on list items.
  final Map<String, dynamic> input;
  final List<DocumentImageModel> images;

  /// The printed meta rows (`definition.meta`), label → value, e.g. the
  /// lesson titles the server looked up for `lesson_ids`.
  final Map<String, String> meta;

  const DocumentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.status,
    this.element,
    this.createdAt,
    this.updatedAt,
    this.input = const {},
    this.images = const [],
    this.meta = const {},
  });

  bool get isFinal => status == DocumentStatus.finalized;

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    final input = json['input'];
    final images = json['images'];
    final definition = json['definition'];
    final meta = definition is Map ? definition['meta'] : null;
    return DocumentModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? DocumentStatus.draft,
      element: json['element']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      input: input is Map<String, dynamic> ? input : const {},
      images: images is List
          ? images
                .whereType<Map<String, dynamic>>()
                .map(DocumentImageModel.fromJson)
                .toList()
          : const [],
      meta: meta is List
          ? {
              for (final row in meta.whereType<Map>())
                if (row['label'] != null)
                  row['label'].toString(): row['value']?.toString() ?? '',
            }
          : const {},
    );
  }
}

/// One page of `GET /documents`, 20 per page.
class DocumentsPageModel {
  final List<DocumentModel> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const DocumentsPageModel({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory DocumentsPageModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : const {};
    return DocumentsPageModel(
      items: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .map(DocumentModel.fromJson)
                .toList()
          : const [],
      currentPage: _asInt(meta['current_page'], 1),
      lastPage: _asInt(meta['last_page'], 1),
      total: _asInt(meta['total'], 0),
    );
  }
}

int _asInt(dynamic value, int fallback) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

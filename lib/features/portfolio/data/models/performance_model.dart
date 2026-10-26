/// `GET /portfolios/{id}/performance` (PORTFOLIO_AND_ACHIEVEMENTS_API.md § 1.1).
library;

import 'package:moean/features/portfolio/data/models/portfolio_model.dart';

/// The CV fields of the performance file, in the order they're shown.
abstract final class PerformanceCvFields {
  static const List<String> all = [
    'name',
    'qualification',
    'specialty',
    'job_title',
    'rank',
    'service_start',
    'stage',
    'subjects',
    'school_name',
    'academic_year',
  ];

  static String labelKey(String field) => 'performance_cv_$field';
}

/// How much evidence an item has: none, below the target, or enough.
enum PerformanceEvidenceState {
  none,
  some,
  complete;

  static PerformanceEvidenceState fromJson(dynamic value) =>
      values.where((state) => state.name == value).firstOrNull ?? none;
}

class PerformanceModel {
  final int portfolioId;
  final String title;
  final String roleLabel;

  /// Field → value for [PerformanceCvFields.all]; missing ones are absent.
  final Map<String, String> cv;
  final int evidenceTarget;
  final int ratingMin;
  final int ratingMax;
  final PerformanceRatingModel rating;

  /// The exported `performance_file` document, if there is one.
  final int? documentId;
  final List<PerformanceItemModel> items;

  const PerformanceModel({
    required this.portfolioId,
    required this.title,
    required this.roleLabel,
    required this.cv,
    required this.evidenceTarget,
    required this.ratingMin,
    required this.ratingMax,
    required this.rating,
    required this.documentId,
    required this.items,
  });

  PerformanceItemModel? itemById(int id) => items.where((item) => item.id == id).firstOrNull;

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    final cv = json['cv'];
    final scale = json['rating_scale'];
    final rating = json['rating'];
    final items = json['items'];
    return PerformanceModel(
      portfolioId: _asInt(json['portfolio_id']) ?? 0,
      title: json['title']?.toString() ?? '',
      roleLabel: json['role_label']?.toString() ?? '',
      cv: cv is Map
          ? {
              for (final field in PerformanceCvFields.all)
                if (cv[field] != null && cv[field].toString().isNotEmpty) field: cv[field].toString(),
            }
          : const {},
      evidenceTarget: _asInt(json['evidence_target']) ?? 3,
      ratingMin: scale is Map ? _asInt(scale['min']) ?? 1 : 1,
      ratingMax: scale is Map ? _asInt(scale['max']) ?? 5 : 5,
      rating: PerformanceRatingModel.fromJson(rating is Map ? Map<String, dynamic>.from(rating) : const {}),
      documentId: _asInt(json['document_id']),
      items: items is List
          ? items.whereType<Map>().map((e) => PerformanceItemModel.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
    );
  }

  PerformanceModel copyWith({List<PerformanceItemModel>? items}) => PerformanceModel(
        portfolioId: portfolioId,
        title: title,
        roleLabel: roleLabel,
        cv: cv,
        evidenceTarget: evidenceTarget,
        ratingMin: ratingMin,
        ratingMax: ratingMax,
        rating: rating,
        documentId: documentId,
        items: items ?? this.items,
      );
}

/// The self-assessment over the included elements with a weight.
class PerformanceRatingModel {
  final int elements;
  final int rated;
  final double points;
  final int outOf;

  /// Null until something is rated.
  final double? percent;
  final double? average;

  const PerformanceRatingModel({
    required this.elements,
    required this.rated,
    required this.points,
    required this.outOf,
    this.percent,
    this.average,
  });

  factory PerformanceRatingModel.fromJson(Map<String, dynamic> json) {
    return PerformanceRatingModel(
      elements: _asInt(json['elements']) ?? 0,
      rated: _asInt(json['rated']) ?? 0,
      points: _asDouble(json['points']) ?? 0,
      outOf: _asInt(json['out_of']) ?? 0,
      percent: _asDouble(json['percent']),
      average: _asDouble(json['average']),
    );
  }
}

class PerformanceItemModel {
  final int id;
  final String? itemKey;
  final int? number;
  final int? weight;
  final String title;
  final String? description;
  final bool included;
  final int? selfRating;
  final int evidenceCount;
  final PerformanceEvidenceState state;
  final List<PortfolioFileModel> files;

  /// Documents tagged with this element and not attached to it.
  final List<PerformanceDocumentModel> documents;

  const PerformanceItemModel({
    required this.id,
    required this.itemKey,
    required this.number,
    required this.weight,
    required this.title,
    required this.description,
    required this.included,
    required this.selfRating,
    required this.evidenceCount,
    required this.state,
    required this.files,
    required this.documents,
  });

  /// Only the Ministry elements (with a weight) can be rated.
  bool get isRatable => weight != null;

  factory PerformanceItemModel.fromJson(Map<String, dynamic> json) {
    final files = json['files'];
    final documents = json['documents'];
    return PerformanceItemModel(
      id: _asInt(json['id']) ?? 0,
      itemKey: json['item_key']?.toString(),
      number: _asInt(json['number']),
      weight: _asInt(json['weight']),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      included: json['included'] != false,
      selfRating: _asInt(json['self_rating']),
      evidenceCount: _asInt(json['evidence_count']) ?? 0,
      state: PerformanceEvidenceState.fromJson(json['state']),
      files: files is List
          ? files.whereType<Map>().map((e) => PortfolioFileModel.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      documents: documents is List
          ? documents.whereType<Map>().map((e) => PerformanceDocumentModel.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
    );
  }

  PerformanceItemModel copyWith({int? selfRating, bool clearRating = false}) => PerformanceItemModel(
        id: id,
        itemKey: itemKey,
        number: number,
        weight: weight,
        title: title,
        description: description,
        included: included,
        selfRating: clearRating ? null : (selfRating ?? this.selfRating),
        evidenceCount: evidenceCount,
        state: state,
        files: files,
        documents: documents,
      );
}

class PerformanceDocumentModel {
  final int id;
  final String type;
  final String title;
  final DateTime? createdAt;

  const PerformanceDocumentModel({required this.id, required this.type, required this.title, this.createdAt});

  factory PerformanceDocumentModel.fromJson(Map<String, dynamic> json) {
    return PerformanceDocumentModel(
      id: _asInt(json['id']) ?? 0,
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

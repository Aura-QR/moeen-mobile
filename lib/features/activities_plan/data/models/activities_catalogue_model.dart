/// Models for `GET /tools/activities` (DOCUMENTS_API.md § 6).
library;

/// `primary`, `intermediate` or `secondary`, with a short [label] for the
/// picker and the full [name] for the document.
class ActivitiesStageModel {
  final String key;
  final String label;
  final String name;

  const ActivitiesStageModel({required this.key, required this.label, required this.name});

  factory ActivitiesStageModel.fromJson(Map<String, dynamic> json) => ActivitiesStageModel(
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );
}

/// An activity domain: one column of the plan.
class ActivitiesDomainModel {
  final String key;
  final String label;

  const ActivitiesDomainModel({required this.key, required this.label});

  factory ActivitiesDomainModel.fromJson(Map<String, dynamic> json) => ActivitiesDomainModel(
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
      );
}

class ActivitiesCatalogueModel {
  final List<ActivitiesStageModel> stages;
  final List<ActivitiesDomainModel> domains;

  const ActivitiesCatalogueModel({this.stages = const [], this.domains = const []});

  factory ActivitiesCatalogueModel.fromJson(Map<String, dynamic> json) {
    final stages = json['stages'];
    final domains = json['domains'];
    return ActivitiesCatalogueModel(
      stages: stages is List
          ? stages.whereType<Map<String, dynamic>>().map(ActivitiesStageModel.fromJson).toList()
          : const [],
      domains: domains is List
          ? domains.whereType<Map<String, dynamic>>().map(ActivitiesDomainModel.fromJson).toList()
          : const [],
    );
  }

  /// The domain's label, or its key when the catalogue doesn't list it.
  String domainLabel(String key) => domains.where((domain) => domain.key == key).firstOrNull?.label ?? key;
}

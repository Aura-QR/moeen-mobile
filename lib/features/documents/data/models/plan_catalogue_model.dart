import 'package:moean/features/documents/data/models/checklist_models.dart';

/// `GET /tools/remedial` or `/tools/enrichment`: the sections' ready options,
/// plus the remedial «مستوى التحسن» or the enrichment «الفئة المستهدفة».
class PlanCatalogueModel {
  final List<ChecklistCatalogueSection> sections;
  final String improvementLabel;
  final List<String> improvementOptions;
  final List<String> targetGroups;

  const PlanCatalogueModel({
    this.sections = const [],
    this.improvementLabel = '',
    this.improvementOptions = const [],
    this.targetGroups = const [],
  });

  factory PlanCatalogueModel.fromJson(Map<String, dynamic> json) {
    final sections = json['sections'];
    final improvement = json['improvement'] is Map ? json['improvement'] as Map : const {};
    return PlanCatalogueModel(
      sections: sections is List
          ? sections.whereType<Map<String, dynamic>>().map(ChecklistCatalogueSection.fromJson).toList()
          : const [],
      improvementLabel: improvement['label']?.toString() ?? '',
      improvementOptions: _strings(improvement['options']),
      targetGroups: _strings(json['target_groups']),
    );
  }

  static List<String> _strings(dynamic value) =>
      value is List ? value.map((e) => e.toString()).toList() : const [];
}

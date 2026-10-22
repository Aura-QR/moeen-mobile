import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/documents/data/models/document_model.dart';

/// A tool that saves into «مستنداتي». Its screen takes the document id
/// (int) as the route argument, or none for a new document.
class DocumentTool {
  final String type;
  final IconData icon;
  final String route;

  const DocumentTool({required this.type, required this.icon, required this.route});

  String get titleKey => DocumentTypes.labelKey(type);
  String get subtitleKey => '${titleKey}_subtitle';
}

/// Register every new tool here so «مستنداتي» can create and open it.
const List<DocumentTool> documentTools = [
  DocumentTool(
    type: DocumentTypes.strategyDocumentation,
    icon: Icons.tips_and_updates_outlined,
    route: Routes.strategyDocumentation,
  ),
  DocumentTool(
    type: DocumentTypes.remedialPlan,
    icon: Icons.healing_outlined,
    route: Routes.remedialPlan,
  ),
  DocumentTool(
    type: DocumentTypes.enrichmentPlan,
    icon: Icons.rocket_launch_outlined,
    route: Routes.enrichmentPlan,
  ),
  DocumentTool(
    type: DocumentTypes.activitiesPlan,
    icon: Icons.local_activity_outlined,
    route: Routes.activitiesPlan,
  ),
];

DocumentTool? documentToolFor(String type) => documentTools.where((tool) => tool.type == type).firstOrNull;

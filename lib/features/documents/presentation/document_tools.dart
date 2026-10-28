import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/documents/data/models/document_model.dart';

/// A tool that saves into «مستنداتي». Its screen takes the document id
/// (int) as the route argument, or none for a new document.
class DocumentTool {
  final String type;
  final IconData icon;
  final String route;

  const DocumentTool({
    required this.type,
    required this.icon,
    required this.route,
  });

  String get titleKey => DocumentTypes.labelKey(type);
  String get subtitleKey => '${titleKey}_subtitle';
}

/// Menu key for L1 «حقائب الأدوار» (role documents save as `report` or `certificates`).
const String roleSuitesToolType = 'role_suites';

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
  DocumentTool(
    type: DocumentTypes.gradeAnalysis,
    icon: Icons.insights_rounded,
    route: Routes.gradeAnalysis,
  ),
  DocumentTool(
    type: DocumentTypes.certificates,
    icon: Icons.workspace_premium_outlined,
    route: Routes.thankYouCertificates,
  ),
  DocumentTool(
    type: DocumentTypes.classSheet,
    icon: Icons.table_chart_outlined,
    route: Routes.classSheets,
  ),
  DocumentTool(
    type: DocumentTypes.lessonPreparation,
    icon: Icons.print_outlined,
    route: Routes.preparationPrint,
  ),
  DocumentTool(
    type: DocumentTypes.report,
    icon: Icons.summarize_outlined,
    route: Routes.reportEditor,
  ),
  DocumentTool(
    type: DocumentTypes.conceptMap,
    icon: Icons.account_tree_outlined,
    route: Routes.conceptMapsEditor,
  ),
  DocumentTool(
    type: DocumentTypes.outcomesMap,
    icon: Icons.checklist_rtl_outlined,
    route: Routes.outcomesMapEditor,
  ),
  DocumentTool(
    type: DocumentTypes.readingComprehension,
    icon: Icons.chrome_reader_mode_outlined,
    route: Routes.readingComprehensionEditor,
  ),
  DocumentTool(
    type: roleSuitesToolType,
    icon: Icons.work_outline_rounded,
    route: Routes.roleSuites,
  ),
];

DocumentTool? documentToolFor(String type) =>
    documentTools.where((tool) => tool.type == type).firstOrNull;

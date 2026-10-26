import 'package:moean/features/role_suites/data/models/role_suite_models.dart';

/// Route argument when opening T8 (`ReportEditorScreen`) for a role suite document.
class RoleReportEditorArgs {
  final String role;
  final String doc;
  final RoleDocumentTemplateModel? template;

  const RoleReportEditorArgs({
    required this.role,
    required this.doc,
    this.template,
  });

  factory RoleReportEditorArgs.fromTemplate(RoleDocumentTemplateModel template) =>
      RoleReportEditorArgs(role: template.role, doc: template.doc, template: template);
}

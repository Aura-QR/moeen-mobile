import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/cubit/plan_tool_config.dart';

/// T2 «الخطة الإثرائية»: optional lessons, and «الفئة المستهدفة».
const PlanToolConfig enrichmentPlanTool = PlanToolConfig(
  documentType: DocumentTypes.enrichmentPlan,
  aiKind: AiJobKinds.enrichmentSuggestions,
  catalogueUrl: enrichmentToolApi,
  hasTargetGroups: true,
);

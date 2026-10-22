import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/cubit/plan_tool_config.dart';

/// T1 «الخطة العلاجية»: a plan type, and «مستوى التحسن».
const PlanToolConfig remedialPlanTool = PlanToolConfig(
  documentType: DocumentTypes.remedialPlan,
  aiKind: AiJobKinds.remedialSuggestions,
  catalogueUrl: remedialToolApi,
  hasPlanType: true,
  hasImprovement: true,
);

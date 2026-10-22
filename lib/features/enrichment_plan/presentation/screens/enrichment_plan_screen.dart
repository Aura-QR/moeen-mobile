import 'package:flutter/material.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/widgets/plan_form_scaffold.dart';
import 'package:moean/features/enrichment_plan/presentation/widgets/enrichment_plan_body.dart';

/// T2 «الخطة الإثرائية».
class EnrichmentPlanScreen extends StatelessWidget {
  const EnrichmentPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlanFormScaffold(
      titleKey: DocumentTypes.labelKey(DocumentTypes.enrichmentPlan),
      body: const EnrichmentPlanBody(),
    );
  }
}

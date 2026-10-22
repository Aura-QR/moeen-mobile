import 'package:flutter/material.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/widgets/plan_form_scaffold.dart';
import 'package:moean/features/remedial_plan/presentation/widgets/remedial_plan_body.dart';

/// T1 «الخطة العلاجية».
class RemedialPlanScreen extends StatelessWidget {
  const RemedialPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlanFormScaffold(
      titleKey: DocumentTypes.labelKey(DocumentTypes.remedialPlan),
      body: const RemedialPlanBody(),
    );
  }
}

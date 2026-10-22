import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/documents/data/models/plan_form_input.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_option_selector.dart';

/// «نوع الخطة»: مرتبطة بدروس / عامة.
class RemedialPlanTypeSection extends StatelessWidget {
  const RemedialPlanTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.alt_route_rounded,
      title: appTranslation().get('plan_section_type'),
      child: BlocSelector<PlanFormCubit, PlanFormState, String>(
        selector: (state) => state.planType ?? PlanFormInput.linked,
        builder: (context, planType) => DocumentOptionSelector<String>(
          label: appTranslation().get('plan_type_label'),
          options: const [PlanFormInput.linked, PlanFormInput.general],
          selected: planType,
          labelKeyOf: (type) => 'plan_type_$type',
          onChanged: cubit.setPlanType,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';

/// «مستوى التحسن»: one of the catalogue's levels; tap again to clear.
class RemedialImprovementSection extends StatelessWidget {
  const RemedialImprovementSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    final catalogue = cubit.state.catalogue;
    return PrimarySectionCard(
      icon: Icons.trending_up_rounded,
      title: catalogue.improvementLabel,
      child: BlocSelector<PlanFormCubit, PlanFormState, String>(
        selector: (state) => state.improvement,
        builder: (context, improvement) => PrimaryChoiceChips<String>(
          options: catalogue.improvementOptions,
          labelOf: (level) => level,
          isSelected: (level) => level == improvement,
          onTap: cubit.setImprovement,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
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
        builder: (context, improvement) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final level in catalogue.improvementOptions)
              ChoiceChip(
                label: Text(level),
                selected: level == improvement,
                onSelected: (_) => cubit.setImprovement(level),
                showCheckmark: false,
                selectedColor: ColorsManager.primaryColor,
                backgroundColor: ColorsManager.background,
                side: BorderSide(color: level == improvement ? ColorsManager.primaryColor : ColorsManager.borderColor),
                labelStyle: TextStylesManager.medium13.copyWith(
                  color: level == improvement ? ColorsManager.white : ColorsManager.mainText,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

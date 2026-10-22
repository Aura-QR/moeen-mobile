import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_checklist_section.dart';

/// Every section of the plan, in the catalogue's order.
class PlanChecklistSections extends StatelessWidget {
  const PlanChecklistSections({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    return BlocBuilder<PlanFormCubit, PlanFormState>(
      buildWhen: (previous, current) => previous.sections != current.sections,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in state.sections) ...[
            DocumentChecklistSection(
              section: section,
              onToggle: (index) => cubit.toggleLine(section.key, index),
              onAdd: (text) => cubit.addCustomLine(section.key, text),
              onEdit: (index, text) => cubit.editCustomLine(section.key, index, text),
              onRemove: (index) => cubit.removeCustomLine(section.key, index),
            ),
            verticalSpace14,
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';

/// «ملاحظات».
class PlanNotesSection extends StatelessWidget {
  const PlanNotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.sticky_note_2_outlined,
      title: appTranslation().get('strategy_section_notes'),
      child: PrimaryTextField(
        controller: PlanFormCubit.get(context).notesController,
        hint: appTranslation().get('strategy_notes_hint'),
        maxLines: 4,
        maxLength: 2000,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
      ),
    );
  }
}

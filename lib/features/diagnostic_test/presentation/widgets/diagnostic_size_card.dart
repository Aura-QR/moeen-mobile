import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_cubit.dart';
import 'package:moean/features/diagnostic_test/presentation/widgets/diagnostic_count_row.dart';

class DiagnosticSizeCard extends StatefulWidget {
  final DiagnosticCreateState state;

  const DiagnosticSizeCard({super.key, required this.state});

  @override
  State<DiagnosticSizeCard> createState() => _DiagnosticSizeCardState();
}

class _DiagnosticSizeCardState extends State<DiagnosticSizeCard> {
  late final TextEditingController _notesController = TextEditingController(text: widget.state.notes);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = DiagnosticCreateCubit.get(context);
    final writing = widget.state.step == DiagnosticStep.writing;

    return PrimarySectionCard(
      icon: Icons.tune_rounded,
      title: appTranslation().get('diagnostic_step_size'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DiagnosticCountRow(
            labelKey: 'diagnostic_skills_count',
            value: widget.state.skillsCount,
            values: const [2, 3, 4, 5, 6, 7, 8],
            enabled: !writing,
            onChanged: cubit.setSkillsCount,
          ),
          DiagnosticCountRow(
            labelKey: 'diagnostic_per_skill',
            value: widget.state.perSkill,
            values: const [1, 2, 3, 4, 5],
            enabled: !writing,
            onChanged: cubit.setPerSkill,
          ),
          verticalSpace8,
          PrimaryTextField(
            controller: _notesController,
            label: appTranslation().get('diagnostic_notes'),
            hint: appTranslation().get('diagnostic_notes'),
            maxLength: 500,
            maxLines: 2,
            enabled: !writing,
            onChanged: cubit.setNotes,
          ),
          verticalSpace10,
          Text(
            appTranslation().get('diagnostic_size_hint').replaceAll('{n}', '${widget.state.skillsCount * widget.state.perSkill}'),
            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
          ),
        ],
      ),
    );
  }
}

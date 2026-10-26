import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_cubit.dart';
import 'package:moean/features/diagnostic_test/presentation/widgets/diagnostic_question_card.dart';

class DiagnosticSkillCard extends StatefulWidget {
  final int skillIndex;
  final DiagnosticSkill skill;

  const DiagnosticSkillCard({
    super.key,
    required this.skillIndex,
    required this.skill,
  });

  @override
  State<DiagnosticSkillCard> createState() => _DiagnosticSkillCardState();
}

class _DiagnosticSkillCardState extends State<DiagnosticSkillCard> {
  late final TextEditingController _nameController = TextEditingController(text: widget.skill.name);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = DiagnosticCreateCubit.get(context);
    final label = '${appTranslation().get('diagnostic_skill')} ${widget.skillIndex + 1}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: _nameController,
                  label: label,
                  hint: label,
                  maxLength: 120,
                  onChanged: (v) => cubit.renameSkill(widget.skillIndex, v),
                ),
              ),
              horizontalSpace6,
              IconButton(
                icon: const Icon(Icons.delete_outline, color: ColorsManager.errorColor),
                tooltip: appTranslation().get('diagnostic_remove_skill'),
                onPressed: () => cubit.removeSkill(widget.skillIndex),
              ),
            ],
          ),
          verticalSpace12,
          for (var qi = 0; qi < widget.skill.questions.length; qi++) ...[
            DiagnosticQuestionCard(
              key: ValueKey('q-${widget.skillIndex}-$qi-${widget.skill.questions.length}'),
              index: qi,
              question: widget.skill.questions[qi],
              onChanged: (q) => cubit.updateQuestion(widget.skillIndex, qi, q),
              onRemove: () => cubit.removeQuestion(widget.skillIndex, qi),
            ),
            verticalSpace8,
          ],
          TextButton.icon(
            icon: Icon(Icons.add, color: ColorsManager.primaryColor),
            label: Text(appTranslation().get('diagnostic_add_question')),
            onPressed: () => cubit.addQuestion(widget.skillIndex),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_cubit.dart';
import 'package:moean/features/diagnostic_test/presentation/widgets/diagnostic_skill_card.dart';

class DiagnosticReviewView extends StatefulWidget {
  final DiagnosticCreateState state;

  const DiagnosticReviewView({super.key, required this.state});

  @override
  State<DiagnosticReviewView> createState() => _DiagnosticReviewViewState();
}

class _DiagnosticReviewViewState extends State<DiagnosticReviewView> {
  late final TextEditingController _titleController = TextEditingController(text: widget.state.title);

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = DiagnosticCreateCubit.get(context);
    final state = widget.state;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PrimarySectionCard(
          icon: Icons.assignment_turned_in_outlined,
          title: appTranslation().get('online_tests_test_title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryTextField(
                controller: _titleController,
                hint: appTranslation().get('online_tests_test_title'),
                maxLength: 255,
                onChanged: cubit.setTitle,
              ),
              verticalSpace8,
              Text(
                appTranslation()
                    .get('diagnostic_review_hint')
                    .replaceAll('{skills}', '${state.skills.length}')
                    .replaceAll('{n}', '${state.questionsCount}'),
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
              ),
            ],
          ),
        ),
        verticalSpace12,
        for (var si = 0; si < state.skills.length; si++)
          DiagnosticSkillCard(
            key: ValueKey('skill-$si-${state.skills.length}'),
            skillIndex: si,
            skill: state.skills[si],
          ),
        verticalSpace4,
        PrimaryElevatedButton(
          text: appTranslation().get('diagnostic_save'),
          isLoading: state.isSaving,
          onPressed: cubit.save,
        ),
        verticalSpace8,
        OutlinedButton(
          onPressed: cubit.restart,
          child: Text(
            appTranslation().get('diagnostic_restart'),
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
          ),
        ),
        verticalSpace8,
        Text(
          appTranslation().get('diagnostic_after_save'),
          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
        ),
        verticalSpace16,
      ],
    );
  }
}

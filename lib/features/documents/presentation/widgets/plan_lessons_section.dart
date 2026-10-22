import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/plan_tool_config.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_sheet.dart';

/// «الدروس»: up to five lessons from the curriculum, picked one at a time.
/// Hidden for a general remedial plan.
class PlanLessonsSection extends StatelessWidget {
  const PlanLessonsSection({super.key});

  Future<void> _pick(BuildContext context) async {
    final cubit = PlanFormCubit.get(context);
    final lesson = await LessonPickerSheet.show(context);
    if (lesson != null) cubit.addLesson(lesson);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    return BlocBuilder<PlanFormCubit, PlanFormState>(
      buildWhen: (previous, current) =>
          previous.lessons != current.lessons || previous.usesLessons != current.usesLessons,
      builder: (context, state) {
        if (!state.usesLessons) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: PrimarySectionCard(
            icon: Icons.menu_book_rounded,
            title: appTranslation().get('plan_section_lessons'),
            trailing: Text(
              '${state.lessons.length}/${PlanToolConfig.maxLessons}',
              style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appTranslation().get(cubit.config.hasPlanType ? 'plan_lessons_note' : 'plan_lessons_optional_note'),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
                if (state.lessons.isNotEmpty) ...[
                  verticalSpace12,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < state.lessons.length; i++)
                        InputChip(
                          label: Text(
                            state.lessons[i].lessonTitle.isEmpty
                                ? appTranslation().get('plan_lesson_saved')
                                : state.lessons[i].lessonTitle,
                            style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
                          ),
                          avatar: Icon(Icons.menu_book_rounded, size: 16, color: ColorsManager.primaryColor),
                          backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.08),
                          side: BorderSide(color: ColorsManager.primaryColor.withValues(alpha: 0.25)),
                          onDeleted: () => cubit.removeLesson(i),
                        ),
                    ],
                  ),
                ],
                if (state.lessons.length < PlanToolConfig.maxLessons)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => _pick(context),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(appTranslation().get('plan_add_lesson')),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

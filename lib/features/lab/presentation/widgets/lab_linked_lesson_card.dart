import 'package:flutter/material.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/presentation/widgets/lab_create_experiment_sheet.dart';
import 'package:moean/features/lab/presentation/widgets/lab_request_experiment_sheet.dart';
import 'package:moean/features/lab/presentation/widgets/lesson_lab_action_chip.dart';

/// Card for a single linked lesson inside [LabLinkedLessonsBottomSheet].
class LabLinkedLessonCard extends StatelessWidget {
  final LabLinkedLessonModel lesson;

  const LabLinkedLessonCard({super.key, required this.lesson});

  void _openLessonExperiments(BuildContext context) {
    AppRouter.pop(null, context);
    AppRouter.push(
      Routes.labLibrary,
      arguments: LabLibraryArgs(
        lessonId: lesson.id,
        lessonTitle: lesson.title,
      ),
      context: context,
    );
  }

  void _openCreateExperiment(BuildContext context) {
    LabCreateExperimentSheet.show(
      context,
      lessonId: lesson.id,
      lessonTitle: lesson.title,
    );
  }

  void _openRequestExperiment(BuildContext context) {
    LabRequestExperimentSheet.show(
      context,
      lessonId: lesson.id,
      lessonTitle: lesson.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = lesson.curriculumSubtitle;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            style: TextStylesManager.bold14.copyWith(
              color: ColorsManager.mainText,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            verticalSpace4,
            Text(
              subtitle,
              style: TextStylesManager.regular12.copyWith(
                color: ColorsManager.secondaryText,
              ),
            ),
          ],
          verticalSpace10,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LessonLabActionChip(
                icon: Icons.science_outlined,
                label: appTranslation().get('lab_view_lesson_experiments'),
                isPrimary: true,
                onTap: () => _openLessonExperiments(context),
              ),
              LessonLabActionChip(
                icon: Icons.add_circle_outline_rounded,
                label: appTranslation().get('lab_create_experiment'),
                onTap: () => _openCreateExperiment(context),
              ),
              LessonLabActionChip(
                icon: Icons.lightbulb_outline_rounded,
                label: appTranslation().get('lab_request_experiment'),
                onTap: () => _openRequestExperiment(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

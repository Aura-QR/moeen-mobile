import 'package:flutter/material.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';

class LessonExperimentsChip extends StatelessWidget {
  final int count;
  final int lessonId;
  final String? lessonTitle;

  const LessonExperimentsChip({
    super.key,
    required this.count,
    required this.lessonId,
    this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final label = appTranslation()
        .get('lab_interactive_experiments_chip')
        .replaceAll('{count}', count.toString());

    return InkWell(
      onTap: () {
        AppRouter.push(
          Routes.labLibrary,
          arguments: LabLibraryArgs(
            lessonId: lessonId,
            lessonTitle: lessonTitle,
          ),
          context: context,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ColorsManager.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorsManager.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStylesManager.bold12.copyWith(
            color: ColorsManager.primaryColor,
          ),
        ),
      ),
    );
  }
}

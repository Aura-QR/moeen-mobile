import 'package:flutter/material.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_linked_lesson_model.dart';
import 'package:moean/features/lab/presentation/widgets/lab_linked_lesson_card.dart';

/// Bottom sheet displaying all lessons linked to an experiment.
class LabLinkedLessonsBottomSheet extends StatelessWidget {
  final List<LabLinkedLessonModel> lessons;

  const LabLinkedLessonsBottomSheet({
    super.key,
    required this.lessons,
  });

  static Future<void> show(
    BuildContext context, {
    required List<LabLinkedLessonModel> lessons,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LabLinkedLessonsBottomSheet(lessons: lessons),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: ColorsManager.primaryColor,
                  size: 22,
                ),
                horizontalSpace8,
                Expanded(
                  child: Text(
                    appTranslation()
                        .get('lab_linked_lessons_count')
                        .replaceAll('{count}', lessons.length.toString()),
                    style: TextStylesManager.bold16.copyWith(
                      color: ColorsManager.mainText,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: ColorsManager.secondaryText,
                  onPressed: () => AppRouter.pop(null, context),
                ),
              ],
            ),
            verticalSpace12,
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: lessons.length,
                separatorBuilder: (_, _) => verticalSpace10,
                itemBuilder: (context, index) => LabLinkedLessonCard(
                  lesson: lessons[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

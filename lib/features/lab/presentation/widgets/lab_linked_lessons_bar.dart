import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_linked_lesson_model.dart';
import 'package:moean/features/lab/presentation/widgets/lab_linked_lessons_bottom_sheet.dart';

/// Bottom bar shown on [LabExperimentScreen] when linked lessons are available.
class LabLinkedLessonsBar extends StatelessWidget {
  final List<LabLinkedLessonModel> lessons;

  const LabLinkedLessonsBar({
    super.key,
    required this.lessons,
  });

  void _openSheet(BuildContext context) {
    LabLinkedLessonsBottomSheet.show(context, lessons: lessons);
  }

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) return const SizedBox.shrink();

    final label = appTranslation()
        .get('lab_linked_lessons_count')
        .replaceAll('{count}', lessons.length.toString());

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          border: Border(
            top: BorderSide(color: ColorsManager.borderColor),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _openSheet(context),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: ColorsManager.primaryColor,
                  ),
                  horizontalSpace8,
                  Expanded(
                    child: Text(
                      label,
                      style: TextStylesManager.bold13.copyWith(
                        color: ColorsManager.mainText,
                      ),
                    ),
                  ),
                  Text(
                    appTranslation().get('lab_show_all_lessons'),
                    style: TextStylesManager.bold12.copyWith(
                      color: ColorsManager.primaryColor,
                    ),
                  ),
                  horizontalSpace4,
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 18,
                    color: ColorsManager.primaryColor,
                  ),
                ],
              ),
            ),
            verticalSpace8,
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: lessons.length,
                separatorBuilder: (_, _) => horizontalSpace8,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return InkWell(
                    onTap: () => _openSheet(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ColorsManager.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        lesson.title,
                        style: TextStylesManager.medium12.copyWith(
                          color: ColorsManager.primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

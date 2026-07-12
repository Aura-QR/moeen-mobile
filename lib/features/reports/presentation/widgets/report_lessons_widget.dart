import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ReportLessonsWidget extends StatelessWidget {
  final List<String> lessons;
  final ValueChanged<int> onRemove;
  final VoidCallback onAdd;

  const ReportLessonsWidget({
    super.key,
    required this.lessons,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          appTranslation().get('report_lessons'),
          style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
        ),
        verticalSpace4,
        Text(
          appTranslation().get('report_lessons_hint'),
          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
        ),
        verticalSpace10,
        // Existing lessons list
        if (lessons.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: ColorsManager.surfacePrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorsManager.borderColor),
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: lessons.length,
              separatorBuilder: (context2, index2) => Divider(
                height: 1,
                color: ColorsManager.borderColor,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                return _LessonTile(
                  lesson: lessons[index],
                  index: index,
                  onRemove: () => onRemove(index),
                );
              },
            ),
          ),
          verticalSpace10,
        ],
        // Select button
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: ColorsManager.surfacePrimary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ColorsManager.borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.checklist_rtl_rounded,
                  color: ColorsManager.primaryColor,
                  size: 20,
                ),
                horizontalSpace12,
                Expanded(
                  child: Text(
                    appTranslation().get('report_add_lesson_hint'),
                    style: TextStylesManager.regular14.copyWith(
                      color: ColorsManager.mainText,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  final String lesson;
  final int index;
  final VoidCallback onRemove;

  const _LessonTile({
    required this.lesson,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStylesManager.bold12.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
            ),
          ),
          horizontalSpace10,
          Expanded(
            child: Text(
              lesson,
              style: TextStylesManager.regular14.copyWith(
                color: ColorsManager.mainText,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ColorsManager.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: ColorsManager.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

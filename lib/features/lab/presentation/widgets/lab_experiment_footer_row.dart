import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class LabExperimentFooterRow extends StatelessWidget {
  final int lessonsCount;
  final int plays;

  const LabExperimentFooterRow({
    super.key,
    required this.lessonsCount,
    required this.plays,
  });

  String _formatLessonsCount(int count) {
    if (count <= 0) return '';
    if (count == 1) return appTranslation().get('lab_single_lesson_linked');
    if (count == 2) return appTranslation().get('lab_two_lessons_linked');
    return appTranslation()
        .get('lab_linked_lessons_count')
        .replaceAll('{count}', count.toString());
  }

  @override
  Widget build(BuildContext context) {
    final lessonsText = _formatLessonsCount(lessonsCount);

    return Row(
      children: [
        if (lessonsText.isNotEmpty) ...[
          Icon(
            Icons.menu_book_outlined,
            size: 14,
            color: ColorsManager.secondaryText,
          ),
          horizontalSpace4,
          Expanded(
            child: Text(
              lessonsText,
              style: TextStylesManager.regular12.copyWith(
                color: ColorsManager.secondaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          const Spacer(),
        if (plays > 0) ...[
          Icon(
            Icons.play_circle_outline_rounded,
            size: 14,
            color: ColorsManager.secondaryText,
          ),
          horizontalSpace4,
          Text(
            appTranslation()
                .get('lab_plays_count')
                .replaceAll('{count}', plays.toString()),
            style: TextStylesManager.regular10.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
        ],
      ],
    );
  }
}

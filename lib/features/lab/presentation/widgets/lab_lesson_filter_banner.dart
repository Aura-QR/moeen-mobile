import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/presentation/cubit/lab_library_cubit.dart';

class LabLessonFilterBanner extends StatelessWidget {
  final String? lessonTitle;

  const LabLessonFilterBanner({
    super.key,
    this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 16,
            color: ColorsManager.primaryColor,
          ),
          horizontalSpace6,
          Expanded(
            child: Text(
              lessonTitle?.isNotEmpty == true
                  ? '${appTranslation().get('lab_filtered_by_lesson')}: $lessonTitle'
                  : appTranslation().get('lab_filtered_by_lesson'),
              style: TextStylesManager.medium12.copyWith(
                color: ColorsManager.primaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => LabLibraryCubit.get(context).clearLessonFilter(),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: ColorsManager.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

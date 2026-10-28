import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';

/// One lesson row inside a unit card: title, outcome count, AI spinner.
class OutcomesMapLessonTile extends StatelessWidget {
  final OutcomeLesson lesson;
  final bool isAiBusy;
  final String? errorMessage;
  final VoidCallback onTap;

  const OutcomesMapLessonTile({
    super.key,
    required this.lesson,
    required this.isAiBusy,
    required this.onTap,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;
    final count = lesson.outcomes.where((o) => o.trim().isNotEmpty).length;
    final isEmptyTitle = lesson.title.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: hasError
            ? ColorsManager.errorColor.withValues(alpha: 0.06)
            : ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 8, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError ? ColorsManager.errorColor : ColorsManager.borderLightGray,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book_outlined, size: 18, color: ColorsManager.primaryColor),
                horizontalSpace8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEmptyTitle
                            ? appTranslation().get('outcomes_map_lesson_untitled')
                            : lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStylesManager.medium13.copyWith(
                          color: isEmptyTitle ? ColorsManager.secondaryText : ColorsManager.mainText,
                        ),
                      ),
                      verticalSpace2,
                      Text(
                        count == 0
                            ? appTranslation().get('outcomes_map_no_outcomes')
                            : '$count ${appTranslation().get('outcomes_map_outcomes_count')}',
                        style: TextStylesManager.regular12.copyWith(
                          color: count == 0 ? ColorsManager.errorColor : ColorsManager.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAiBusy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(Icons.edit_outlined, size: 18, color: ColorsManager.secondaryText),
                horizontalSpace4,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

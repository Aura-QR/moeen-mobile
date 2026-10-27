import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';

/// A tappable row for one question inside its level group.
class ReadingQuestionTile extends StatelessWidget {
  final int order;
  final ReadingQuestion question;
  final String? error;
  final VoidCallback onTap;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onDelete;

  const ReadingQuestionTile({
    super.key,
    required this.order,
    required this.question,
    required this.onTap,
    required this.onDelete,
    this.error,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    final text = question.text.trim();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: error != null ? ColorsManager.errorColor : ColorsManager.borderLightGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                    child: Text('$order', style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor)),
                  ),
                  horizontalSpace10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text.isEmpty ? appTranslation().get('reading_question_empty') : text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStylesManager.medium14.copyWith(
                            color: text.isEmpty ? ColorsManager.secondaryText : ColorsManager.mainText,
                          ),
                        ),
                        verticalSpace4,
                        Text(
                          appTranslation().get(question.type.labelKey),
                          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined, size: 18, color: ColorsManager.secondaryText),
                  horizontalSpace8,
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onMoveUp,
                icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onMoveDown,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: ColorsManager.errorColor),
              ),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                appTranslation().get(error!),
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.errorColor),
              ),
            ),
        ],
      ),
    );
  }
}

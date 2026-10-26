import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_cubit.dart';

class ExtractionQuestionHeader extends StatelessWidget {
  final int index;
  final ExtractedQuestionModel question;

  const ExtractionQuestionHeader({
    super.key,
    required this.index,
    required this.question,
  });

  String _typeLabel(String type) {
    switch (type) {
      case QuestionType.mcq:
        return appTranslation().get('exam_extract_type_mcq');
      case QuestionType.trueFalse:
        return appTranslation().get('exam_extract_type_true_false');
      case QuestionType.fillBlank:
        return appTranslation().get('exam_extract_type_fill_blank');
      case QuestionType.essay:
        return appTranslation().get('exam_extract_type_essay');
      case QuestionType.matching:
        return appTranslation().get('exam_extract_type_matching');
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${index + 1}',
            style: TextStylesManager.bold13.copyWith(
              color: ColorsManager.primaryColor,
            ),
          ),
        ),
        horizontalSpace8,
        Expanded(
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: ColorsManager.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorsManager.borderLightGray),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: question.type,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                style: TextStylesManager.medium12.copyWith(
                  color: ColorsManager.mainText,
                ),
                items: QuestionType.all.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      _typeLabel(type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (newType) {
                  if (newType != null) {
                    ExtractionReviewCubit.get(context).changeType(index, newType);
                  }
                },
              ),
            ),
          ),
        ),
        if (question.suggested) ...[
          horizontalSpace6,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: ColorsManager.statusWarning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 13,
                  color: ColorsManager.statusWarning,
                ),
                horizontalSpace4,
                Text(
                  appTranslation().get('exam_extract_suggested'),
                  style: TextStylesManager.medium10.copyWith(
                    color: ColorsManager.statusWarning,
                  ),
                ),
              ],
            ),
          ),
        ],
        horizontalSpace4,
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Icon(
            Icons.delete_outline_rounded,
            color: ColorsManager.errorColor,
            size: 20,
          ),
          onPressed: () async {
            final confirmed = await showPrimaryConfirmDialog(
              context,
              titleKey: 'delete',
              messageKey: 'exam_extract_delete_confirm',
            );
            if (confirmed && context.mounted) {
              ExtractionReviewCubit.get(context).delete(index);
            }
          },
        ),
      ],
    );
  }
}

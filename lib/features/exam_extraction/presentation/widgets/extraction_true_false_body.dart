import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_cubit.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_answer_toggle_button.dart';

class ExtractionTrueFalseBody extends StatelessWidget {
  final int index;
  final ExtractedQuestionModel question;

  const ExtractionTrueFalseBody({
    super.key,
    required this.index,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final isTrue = question.correctAnswer == ExtractedQuestionModel.answerTrue;
    final isFalse = question.correctAnswer == ExtractedQuestionModel.answerFalse;

    return Row(
      children: [
        Expanded(
          child: ExtractionAnswerToggleButton(
            label: appTranslation().get('exam_extract_true'),
            isSelected: isTrue,
            activeColor: ColorsManager.successColor,
            onTap: () =>
                ExtractionReviewCubit.get(context).setTrueFalse(index, true),
          ),
        ),
        horizontalSpace12,
        Expanded(
          child: ExtractionAnswerToggleButton(
            label: appTranslation().get('exam_extract_false'),
            isSelected: isFalse,
            activeColor: ColorsManager.errorColor,
            onTap: () =>
                ExtractionReviewCubit.get(context).setTrueFalse(index, false),
          ),
        ),
      ],
    );
  }
}

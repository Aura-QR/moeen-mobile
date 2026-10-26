import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_cubit.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_state.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_matching_body.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_mcq_body.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_points_field.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_question_header.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_text_answer_body.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_true_false_body.dart';

class ExtractionQuestionCard extends StatefulWidget {
  final int index;

  const ExtractionQuestionCard({
    super.key,
    required this.index,
  });

  @override
  State<ExtractionQuestionCard> createState() => _ExtractionQuestionCardState();
}

class _ExtractionQuestionCardState extends State<ExtractionQuestionCard> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final cubit = ExtractionReviewCubit.get(context);
    final initialText = widget.index < cubit.state.questions.length
        ? cubit.state.questions[widget.index].questionText
        : '';
    _textController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExtractionReviewCubit, ExtractionReviewState>(
      buildWhen: (previous, current) {
        if (widget.index >= current.questions.length ||
            widget.index >= previous.questions.length) {
          return true;
        }
        return previous.questions[widget.index] !=
            current.questions[widget.index];
      },
      builder: (context, state) {
        if (widget.index >= state.questions.length) {
          return const SizedBox.shrink();
        }

        final question = state.questions[widget.index];
        if (_textController.text != question.questionText) {
          _textController.text = question.questionText;
        }

        final isHighlighted = question.isHighlighted;
        final borderColor = isHighlighted
            ? ColorsManager.statusWarning
            : ColorsManager.borderLightGray;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isHighlighted ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExtractionQuestionHeader(
                index: widget.index,
                question: question,
              ),
              verticalSpace12,
              PrimaryTextField(
                controller: _textController,
                label: appTranslation().get('exam_extract_question_label'),
                hint: appTranslation().get('exam_extract_question_label'),
                maxLines: 2,
                onChanged: (text) {
                  ExtractionReviewCubit.get(context)
                      .updateText(widget.index, text);
                },
              ),
              verticalSpace12,
              if (question.type == QuestionType.mcq)
                ExtractionMcqBody(index: widget.index, question: question)
              else if (question.type == QuestionType.trueFalse)
                ExtractionTrueFalseBody(index: widget.index, question: question)
              else if (question.type == QuestionType.matching)
                ExtractionMatchingBody(index: widget.index, question: question)
              else
                ExtractionTextAnswerBody(index: widget.index, question: question),
              verticalSpace12,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ExtractionPointsField(
                    index: widget.index,
                    question: question,
                  ),
                  if (isHighlighted)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: Text(
                          question.mcqAnswerMismatch
                              ? appTranslation()
                                  .get('exam_extract_mcq_mismatch_hint')
                              : appTranslation()
                                  .get('exam_extract_needs_answer_hint'),
                          style: TextStylesManager.medium12.copyWith(
                            color: ColorsManager.statusWarning,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

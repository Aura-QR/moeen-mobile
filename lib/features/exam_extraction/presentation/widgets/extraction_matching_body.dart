import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_cubit.dart';

class ExtractionMatchingBody extends StatefulWidget {
  final int index;
  final ExtractedQuestionModel question;

  const ExtractionMatchingBody({
    super.key,
    required this.index,
    required this.question,
  });

  @override
  State<ExtractionMatchingBody> createState() => _ExtractionMatchingBodyState();
}

class _ExtractionMatchingBodyState extends State<ExtractionMatchingBody> {
  late final TextEditingController _colAController;
  late final TextEditingController _colBController;
  late final TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _colAController = TextEditingController(
      text: widget.question.columnA.join('\n'),
    );
    _colBController = TextEditingController(
      text: widget.question.columnB.join('\n'),
    );
    _answerController = TextEditingController(
      text: widget.question.correctAnswer,
    );
  }

  @override
  void didUpdateWidget(covariant ExtractionMatchingBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final aJoined = widget.question.columnA.join('\n');
    if (_colAController.text.trim() != aJoined.trim()) {
      _colAController.text = aJoined;
    }
    final bJoined = widget.question.columnB.join('\n');
    if (_colBController.text.trim() != bJoined.trim()) {
      _colBController.text = bJoined;
    }
    if (_answerController.text != widget.question.correctAnswer) {
      _answerController.text = widget.question.correctAnswer;
    }
  }

  @override
  void dispose() {
    _colAController.dispose();
    _colBController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PrimaryTextField(
                controller: _colAController,
                label: appTranslation().get('exam_extract_column_a'),
                hint: appTranslation().get('exam_extract_column_a'),
                maxLines: 4,
                onChanged: (text) {
                  final list = text
                      .split('\n')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  ExtractionReviewCubit.get(context)
                      .updateColumnA(widget.index, list);
                },
              ),
            ),
            horizontalSpace8,
            Expanded(
              child: PrimaryTextField(
                controller: _colBController,
                label: appTranslation().get('exam_extract_column_b'),
                hint: appTranslation().get('exam_extract_column_b'),
                maxLines: 4,
                onChanged: (text) {
                  final list = text
                      .split('\n')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  ExtractionReviewCubit.get(context)
                      .updateColumnB(widget.index, list);
                },
              ),
            ),
          ],
        ),
        verticalSpace10,
        PrimaryTextField(
          controller: _answerController,
          label: appTranslation().get('exam_extract_answer_label'),
          hint: appTranslation().get('exam_extract_answer_label'),
          onChanged: (text) {
            ExtractionReviewCubit.get(context)
                .setCorrectAnswer(widget.index, text);
          },
        ),
      ],
    );
  }
}

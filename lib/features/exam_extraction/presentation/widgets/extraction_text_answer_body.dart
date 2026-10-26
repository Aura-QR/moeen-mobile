import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_cubit.dart';

class ExtractionTextAnswerBody extends StatefulWidget {
  final int index;
  final ExtractedQuestionModel question;

  const ExtractionTextAnswerBody({
    super.key,
    required this.index,
    required this.question,
  });

  @override
  State<ExtractionTextAnswerBody> createState() =>
      _ExtractionTextAnswerBodyState();
}

class _ExtractionTextAnswerBodyState extends State<ExtractionTextAnswerBody> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.question.correctAnswer);
  }

  @override
  void didUpdateWidget(covariant ExtractionTextAnswerBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.question.correctAnswer) {
      _controller.text = widget.question.correctAnswer;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryTextField(
      controller: _controller,
      label: appTranslation().get('exam_extract_answer_label'),
      hint: appTranslation().get('exam_extract_answer_label'),
      onChanged: (text) {
        ExtractionReviewCubit.get(context).setCorrectAnswer(widget.index, text);
      },
    );
  }
}

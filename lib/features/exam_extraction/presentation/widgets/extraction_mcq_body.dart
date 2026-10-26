import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_cubit.dart';

class ExtractionMcqBody extends StatefulWidget {
  final int index;
  final ExtractedQuestionModel question;

  const ExtractionMcqBody({
    super.key,
    required this.index,
    required this.question,
  });

  @override
  State<ExtractionMcqBody> createState() => _ExtractionMcqBodyState();
}

class _ExtractionMcqBodyState extends State<ExtractionMcqBody> {
  late final TextEditingController _optionsController;

  @override
  void initState() {
    super.initState();
    _optionsController = TextEditingController(
      text: widget.question.options.join('\n'),
    );
  }

  @override
  void didUpdateWidget(covariant ExtractionMcqBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final joined = widget.question.options.join('\n');
    if (_optionsController.text != joined &&
        _optionsController.text.trim() != joined.trim()) {
      _optionsController.text = joined;
    }
  }

  @override
  void dispose() {
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validOptions = widget.question.options
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryTextField(
          controller: _optionsController,
          label: appTranslation().get('exam_extract_options_label'),
          hint: appTranslation().get('exam_extract_options_label'),
          maxLines: 4,
          onChanged: (text) {
            final lines = text
                .split('\n')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            ExtractionReviewCubit.get(context).updateOptions(widget.index, lines);
          },
        ),
        if (validOptions.isNotEmpty) ...[
          verticalSpace10,
          Text(
            appTranslation().get('exam_extract_correct_answer'),
            style: TextStylesManager.bold13.copyWith(
              color: ColorsManager.mainText,
            ),
          ),
          verticalSpace6,
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: validOptions.map((opt) {
              final isSelected = widget.question.correctAnswer.trim() == opt;
              return ChoiceChip(
                label: Text(
                  opt,
                  style: isSelected
                      ? TextStylesManager.bold12.copyWith(color: Colors.white)
                      : TextStylesManager.medium12.copyWith(
                          color: ColorsManager.mainText,
                        ),
                ),
                selected: isSelected,
                selectedColor: ColorsManager.primaryColor,
                backgroundColor: ColorsManager.surfacePrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected
                        ? ColorsManager.primaryColor
                        : ColorsManager.borderLightGray,
                  ),
                ),
                onSelected: (_) {
                  ExtractionReviewCubit.get(context)
                      .setCorrectAnswer(widget.index, opt);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_cubit.dart';

class ExtractionPointsField extends StatefulWidget {
  final int index;
  final ExtractedQuestionModel question;

  const ExtractionPointsField({
    super.key,
    required this.index,
    required this.question,
  });

  @override
  State<ExtractionPointsField> createState() => _ExtractionPointsFieldState();
}

class _ExtractionPointsFieldState extends State<ExtractionPointsField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.question.points == widget.question.points.roundToDouble()
          ? widget.question.points.toInt().toString()
          : widget.question.points.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant ExtractionPointsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pts = widget.question.points;
    final formatted = pts == pts.roundToDouble()
        ? pts.toInt().toString()
        : pts.toString();
    if (_controller.text != formatted && double.tryParse(_controller.text) != pts) {
      _controller.text = formatted;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: ColorsManager.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appTranslation().get('exam_extract_points'),
            style: TextStylesManager.medium12.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
          horizontalSpace8,
          SizedBox(
            width: 42,
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.primaryColor,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (text) {
                final pts = double.tryParse(text);
                if (pts != null && pts > 0) {
                  ExtractionReviewCubit.get(context).setPoints(widget.index, pts);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

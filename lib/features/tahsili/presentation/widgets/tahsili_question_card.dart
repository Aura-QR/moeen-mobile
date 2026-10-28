import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/tahsili/data/models/tahsili_models.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_question_option_row.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_solution_tile.dart';

class TahsiliQuestionCard extends StatefulWidget {
  final int index;
  final TahsiliQuestion question;
  final String? errorMessage;
  final ValueChanged<TahsiliQuestion> onChanged;
  final VoidCallback onRemove;

  const TahsiliQuestionCard({
    super.key,
    required this.index,
    required this.question,
    this.errorMessage,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<TahsiliQuestionCard> createState() => _TahsiliQuestionCardState();
}

class _TahsiliQuestionCardState extends State<TahsiliQuestionCard> {
  late final TextEditingController _text = TextEditingController(text: widget.question.text);
  late final List<TextEditingController> _optionControllers;

  static const List<String> _letters = ['أ', 'ب', 'ج', 'د'];

  @override
  void initState() {
    super.initState();
    _optionControllers = List.generate(4, (i) {
      final initialVal = i < widget.question.options.length ? widget.question.options[i] : '';
      return TextEditingController(text: initialVal);
    });
  }

  @override
  void didUpdateWidget(covariant TahsiliQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.text != widget.question.text && _text.text != widget.question.text) {
      _text.text = widget.question.text;
    }
    for (var i = 0; i < 4; i++) {
      final val = i < widget.question.options.length ? widget.question.options[i] : '';
      if (_optionControllers[i].text != val) {
        _optionControllers[i].text = val;
      }
    }
  }

  @override
  void dispose() {
    _text.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onOptionChanged(int index, String value) {
    final oldAnswer = widget.question.answer;
    final oldVal = index < widget.question.options.length ? widget.question.options[index] : '';
    final newOptions = List<String>.generate(4, (i) => _optionControllers[i].text.trim());

    String nextAnswer = oldAnswer;
    if (oldAnswer == oldVal || oldAnswer.isEmpty) {
      nextAnswer = value.trim();
    } else if (!newOptions.contains(oldAnswer)) {
      nextAnswer = newOptions.firstWhere((o) => o.isNotEmpty, orElse: () => '');
    }

    widget.onChanged(widget.question.copyWith(
      options: newOptions,
      answer: nextAnswer,
    ));
  }

  void _selectCorrectAnswer(String optionText) {
    widget.onChanged(widget.question.copyWith(answer: optionText.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final isComplete = q.isComplete;
    final hasError = widget.errorMessage != null && widget.errorMessage!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError
              ? ColorsManager.errorColor
              : isComplete
                  ? ColorsManager.borderLightGray
                  : ColorsManager.statusWarning,
          width: (hasError || !isComplete) ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${widget.index + 1}.',
                style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
              ),
              horizontalSpace8,
              Expanded(
                child: Text(
                  appTranslation().get('reading_qtype_mcq'),
                  style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: ColorsManager.errorColor),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          if (hasError) ...[
            verticalSpace4,
            Text(
              widget.errorMessage!,
              style: TextStylesManager.bold12.copyWith(color: ColorsManager.errorColor),
            ),
          ],
          verticalSpace8,
          PrimaryTextField(
            controller: _text,
            hint: appTranslation().get('reading_question_text_hint'),
            maxLines: 2,
            onChanged: (v) => widget.onChanged(q.copyWith(text: v)),
          ),
          verticalSpace10,
          for (var i = 0; i < 4; i++) ...[
            TahsiliQuestionOptionRow(
              letter: _letters[i],
              controller: _optionControllers[i],
              isCorrect: _optionControllers[i].text.trim().isNotEmpty &&
                  _optionControllers[i].text.trim() == q.answer.trim(),
              onSelectAsCorrect: () => _selectCorrectAnswer(_optionControllers[i].text),
              onChanged: (val) => _onOptionChanged(i, val),
            ),
            if (i < 3) verticalSpace6,
          ],
          if (q.check != null && q.check!.trim().isNotEmpty) ...[
            verticalSpace10,
            TahsiliSolutionTile(solution: q.check!),
          ],
        ],
      ),
    );
  }
}

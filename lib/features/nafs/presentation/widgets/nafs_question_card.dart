import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/nafs/data/models/nafs_models.dart';

class NafsQuestionCard extends StatefulWidget {
  final int index;
  final NafsQuestion question;
  final ValueChanged<NafsQuestion> onChanged;
  final VoidCallback onRemove;

  const NafsQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<NafsQuestionCard> createState() => _NafsQuestionCardState();
}

class _NafsQuestionCardState extends State<NafsQuestionCard> {
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
  void didUpdateWidget(covariant NafsQuestionCard oldWidget) {
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? ColorsManager.borderLightGray : ColorsManager.statusWarning,
          width: isComplete ? 1 : 1.5,
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
          verticalSpace8,
          PrimaryTextField(
            controller: _text,
            hint: appTranslation().get('reading_question_text_hint'),
            maxLines: 2,
            onChanged: (v) => widget.onChanged(q.copyWith(text: v)),
          ),
          verticalSpace10,
          for (var i = 0; i < 4; i++) ...[
            _OptionRow(
              letter: _letters[i],
              controller: _optionControllers[i],
              isCorrect: _optionControllers[i].text.trim().isNotEmpty &&
                  _optionControllers[i].text.trim() == q.answer.trim(),
              onSelectAsCorrect: () => _selectCorrectAnswer(_optionControllers[i].text),
              onChanged: (val) => _onOptionChanged(i, val),
            ),
            if (i < 3) verticalSpace6,
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String letter;
  final TextEditingController controller;
  final bool isCorrect;
  final VoidCallback onSelectAsCorrect;
  final ValueChanged<String> onChanged;

  const _OptionRow({
    required this.letter,
    required this.controller,
    required this.isCorrect,
    required this.onSelectAsCorrect,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onSelectAsCorrect,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCorrect
                  ? ColorsManager.successColor
                  : ColorsManager.borderLightGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect ? ColorsManager.successColor : ColorsManager.borderLightGray,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStylesManager.bold13.copyWith(
                color: isCorrect ? ColorsManager.surfacePrimary : ColorsManager.mainText,
              ),
            ),
          ),
        ),
        horizontalSpace8,
        Expanded(
          child: PrimaryTextField(
            controller: controller,
            hint: '${appTranslation().get('reading_question_options_hint').split('\n').firstOrNull ?? ''} ($letter)',
            onChanged: onChanged,
          ),
        ),
        horizontalSpace6,
        IconButton(
          icon: Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: isCorrect ? ColorsManager.successColor : ColorsManager.secondaryText,
          ),
          onPressed: onSelectAsCorrect,
        ),
      ],
    );
  }
}

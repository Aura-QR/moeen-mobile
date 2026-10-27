import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';

/// One question to review: type, text, options (mcq) and the right answer.
class DiagnosticQuestionCard extends StatefulWidget {
  final int index;
  final DiagnosticQuestion question;
  final ValueChanged<DiagnosticQuestion> onChanged;
  final VoidCallback onRemove;

  const DiagnosticQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<DiagnosticQuestionCard> createState() => _DiagnosticQuestionCardState();
}

class _DiagnosticQuestionCardState extends State<DiagnosticQuestionCard> {
  late final TextEditingController _text = TextEditingController(text: widget.question.text);
  late final TextEditingController _options = TextEditingController(text: widget.question.options.join('\n'));
  late final TextEditingController _answer = TextEditingController(text: widget.question.answer);

  @override
  void dispose() {
    _text.dispose();
    _options.dispose();
    _answer.dispose();
    super.dispose();
  }

  void _onTypeChanged(String? nextType) {
    if (nextType == null || nextType == widget.question.type) return;
    final q = widget.question;
    String nextAnswer = '';
    if (nextType == DiagnosticQuestionTypes.trueFalse) {
      nextAnswer = 'صح';
    } else if (nextType == DiagnosticQuestionTypes.mcq) {
      final opts = q.options.map((o) => o.trim()).where((o) => o.isNotEmpty).toSet().toList();
      if (opts.isNotEmpty) nextAnswer = opts.first;
    }
    _answer.text = nextAnswer;
    widget.onChanged(q.copyWith(type: nextType, answer: nextAnswer));
  }

  void _onOptionsChanged(String value) {
    final q = widget.question;
    final newOptions = value.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();
    final oldTrimmed = q.options.map((e) => e.trim()).toList();
    final currentAnswer = q.answer.trim();
    final oldIndex = oldTrimmed.indexOf(currentAnswer);

    String nextAnswer;
    if (newOptions.contains(currentAnswer)) {
      nextAnswer = currentAnswer;
    } else if (oldIndex >= 0 && oldIndex < newOptions.length) {
      nextAnswer = newOptions[oldIndex];
    } else if (newOptions.isNotEmpty) {
      nextAnswer = newOptions.first;
    } else {
      nextAnswer = '';
    }
    widget.onChanged(q.copyWith(options: newOptions, answer: nextAnswer));
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final style = TextStylesManager.regular14.copyWith(color: ColorsManager.mainText);
    final uniqueOptions = q.options.map((o) => o.trim()).where((o) => o.isNotEmpty).toSet().toList();
    final selectedMcqAnswer = uniqueOptions.contains(q.answer.trim()) ? q.answer.trim() : null;
    final tfAnswer = q.answer.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: q.isComplete ? ColorsManager.borderLightGray : ColorsManager.statusWarning,
          width: q.isComplete ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('${widget.index + 1}.', style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
              horizontalSpace8,
              DropdownButton<String>(
                value: DiagnosticQuestionTypes.all.contains(q.type) ? q.type : DiagnosticQuestionTypes.mcq,
                dropdownColor: ColorsManager.surfacePrimary,
                items: [
                  for (final t in DiagnosticQuestionTypes.all)
                    DropdownMenuItem(value: t, child: Text(appTranslation().get('online_tests_type_$t'), style: style)),
                ],
                onChanged: _onTypeChanged,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: ColorsManager.errorColor),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          PrimaryTextField(
            controller: _text,
            label: appTranslation().get('diagnostic_question_text'),
            hint: appTranslation().get('diagnostic_question_text'),
            maxLines: 2,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onChanged: (v) => widget.onChanged(q.copyWith(text: v)),
          ),
          verticalSpace8,
          if (q.type == DiagnosticQuestionTypes.mcq) ...[
            PrimaryTextField(
              controller: _options,
              label: appTranslation().get('diagnostic_options'),
              hint: appTranslation().get('diagnostic_options'),
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onChanged: _onOptionsChanged,
            ),
            verticalSpace8,
            InputDecorator(
              decoration: InputDecoration(
                labelText: appTranslation().get('online_tests_right_answer'),
                labelStyle: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                filled: true,
                fillColor: ColorsManager.surfacePrimary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: ColorsManager.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: ColorsManager.borderColor),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedMcqAnswer,
                  isExpanded: true,
                  dropdownColor: ColorsManager.surfacePrimary,
                  hint: Text(
                    appTranslation().get('diagnostic_select_placeholder'),
                    style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                  ),
                  items: [
                    for (final o in uniqueOptions)
                      DropdownMenuItem<String>(
                        value: o,
                        child: Text(o, style: style, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => widget.onChanged(q.copyWith(answer: v ?? '')),
                ),
              ),
            ),
          ] else if (q.type == DiagnosticQuestionTypes.trueFalse)
            SegmentedButton<String>(
              emptySelectionAllowed: true,
              segments: [
                ButtonSegment(value: 'صح', label: Text(appTranslation().get('true_text'))),
                ButtonSegment(value: 'خطأ', label: Text(appTranslation().get('false_text'))),
              ],
              selected: {if (tfAnswer == 'صح' || tfAnswer == 'خطأ') tfAnswer},
              onSelectionChanged: (v) {
                if (v.isNotEmpty) widget.onChanged(q.copyWith(answer: v.first));
              },
            )
          else
            PrimaryTextField(
              controller: _answer,
              label: appTranslation().get('diagnostic_answer_optional'),
              hint: appTranslation().get('online_tests_right_answer'),
              onChanged: (v) => widget.onChanged(q.copyWith(answer: v)),
            ),
          if (!q.isComplete) ...[
            verticalSpace6,
            Text(
              appTranslation().get('diagnostic_question_incomplete'),
              style: TextStylesManager.bold12.copyWith(color: ColorsManager.statusWarning),
            ),
          ],
        ],
      ),
    );
  }
}

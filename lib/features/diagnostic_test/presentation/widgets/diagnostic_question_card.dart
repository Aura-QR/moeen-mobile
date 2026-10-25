import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';

/// One question to review: type, text, options (mcq) and the right answer.
class DiagnosticQuestionCard extends StatefulWidget {
  final int index;
  final DiagnosticQuestion question;
  final ValueChanged<DiagnosticQuestion> onChanged;
  final VoidCallback onRemove;

  const DiagnosticQuestionCard({super.key, required this.index, required this.question, required this.onChanged, required this.onRemove});

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

  InputDecoration _decoration(String key) => InputDecoration(labelText: appTranslation().get(key), isDense: true, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final style = TextStylesManager.regular14.copyWith(color: ColorsManager.mainText);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: q.isComplete ? ColorsManager.borderLightGray : ColorsManager.statusWarning, width: q.isComplete ? 1 : 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('${widget.index + 1}.', style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: q.type,
                items: [
                  for (final t in DiagnosticQuestionTypes.all)
                    DropdownMenuItem(value: t, child: Text(appTranslation().get('online_tests_type_$t'), style: style)),
                ],
                onChanged: (t) {
                  if (t == null) return;
                  final answer = t == DiagnosticQuestionTypes.trueFalse ? 'صح' : '';
                  _answer.text = answer;
                  widget.onChanged(q.copyWith(type: t, answer: answer));
                },
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.delete_outline, color: ColorsManager.errorColor), onPressed: widget.onRemove),
            ],
          ),
          TextField(controller: _text, maxLines: null, style: style, decoration: _decoration('diagnostic_question_text'), onChanged: (v) => widget.onChanged(q.copyWith(text: v))),
          const SizedBox(height: 8),
          if (q.type == DiagnosticQuestionTypes.mcq) ...[
            TextField(
              controller: _options,
              maxLines: null,
              style: style,
              decoration: _decoration('diagnostic_options'),
              onChanged: (v) => widget.onChanged(q.copyWith(options: v.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList())),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: q.options.contains(q.answer) ? q.answer : null,
              isExpanded: true,
              decoration: _decoration('online_tests_right_answer'),
              items: [for (final o in q.options.toSet()) DropdownMenuItem(value: o, child: Text(o, style: style, overflow: TextOverflow.ellipsis))],
              onChanged: (v) => widget.onChanged(q.copyWith(answer: v ?? '')),
            ),
          ] else if (q.type == DiagnosticQuestionTypes.trueFalse)
            SegmentedButton<String>(
              segments: const [ButtonSegment(value: 'صح', label: Text('صح')), ButtonSegment(value: 'خطأ', label: Text('خطأ'))],
              selected: {q.answer == 'خطأ' ? 'خطأ' : 'صح'},
              onSelectionChanged: (v) => widget.onChanged(q.copyWith(answer: v.first)),
            )
          else
            TextField(controller: _answer, style: style, decoration: _decoration('online_tests_right_answer'), onChanged: (v) => widget.onChanged(q.copyWith(answer: v))),
          if (!q.isComplete)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(appTranslation().get('diagnostic_question_incomplete'), style: TextStylesManager.bold12.copyWith(color: ColorsManager.statusWarning)),
            ),
        ],
      ),
    );
  }
}

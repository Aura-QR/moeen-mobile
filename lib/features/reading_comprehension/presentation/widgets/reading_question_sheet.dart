import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_field_label.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/reading_editor_cubit.dart';

/// Editor sheet for one reading question: level, type, text, options and answer.
class ReadingQuestionSheet extends StatefulWidget {
  final ReadingEditorCubit cubit;
  final int index;

  const ReadingQuestionSheet({super.key, required this.cubit, required this.index});

  static Future<void> show(BuildContext context, {required ReadingEditorCubit cubit, required int index}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ReadingQuestionSheet(cubit: cubit, index: index),
    );
  }

  @override
  State<ReadingQuestionSheet> createState() => _ReadingQuestionSheetState();
}

class _ReadingQuestionSheetState extends State<ReadingQuestionSheet> {
  late ReadingQuestion _question;
  late final TextEditingController _text;
  late final TextEditingController _options;
  late final TextEditingController _answer;
  String? _error;

  @override
  void initState() {
    super.initState();
    final questions = widget.cubit.state.input.questions;
    _question = widget.index >= 0 && widget.index < questions.length ? questions[widget.index] : const ReadingQuestion();
    _text = TextEditingController(text: _question.text);
    _options = TextEditingController(text: _question.options.join('\n'));
    _answer = TextEditingController(text: _question.correctAnswer);
  }

  @override
  void dispose() {
    _text.dispose();
    _options.dispose();
    _answer.dispose();
    super.dispose();
  }

  bool get _isEnglish => widget.cubit.state.input.language == ReadingLanguage.english;

  List<String> get _optionLines =>
      _options.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  void _save() {
    final text = _text.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'reading_question_text_required');
      return;
    }
    final options = _question.type.needsOptions ? _optionLines : const <String>[];
    if (_question.type.needsOptions && options.length < 2) {
      setState(() => _error = 'reading_question_options_required');
      return;
    }
    var answer = _answer.text.trim();
    if (_question.type == ReadingQuestionType.trueFalse && answer.isEmpty) {
      answer = ReadingTrueFalse.isTrue;
    }
    if (_question.type.needsAnswer && answer.isEmpty) {
      setState(() => _error = 'reading_question_answer_required');
      return;
    }
    widget.cubit.updateQuestion(
      widget.index,
      _question.copyWith(text: text, options: options, correctAnswer: answer),
    );
    Navigator.of(context).pop();
  }

  InputDecoration _decoration(String hintKey) => InputDecoration(
        hintText: appTranslation().get(hintKey),
        hintStyle: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
        isDense: true,
        filled: true,
        fillColor: ColorsManager.surfacePrimary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderLightGray)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderLightGray)),
      );

  @override
  Widget build(BuildContext context) {
    final type = _question.type;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('reading_question_editor_title'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace16,
              const PrimaryFieldLabel(textKey: 'reading_question_level'),
              verticalSpace8,
              PrimaryChoiceChips<ReadingQuestionLevel>(
                options: ReadingQuestionLevel.values,
                labelOf: (o) => appTranslation().get(o.labelKey),
                isSelected: (o) => o == _question.level,
                onTap: (o) => setState(() => _question = _question.copyWith(level: o, levelRaw: '')),
              ),
              verticalSpace14,
              const PrimaryFieldLabel(textKey: 'reading_question_type'),
              verticalSpace8,
              PrimaryChoiceChips<ReadingQuestionType>(
                options: ReadingQuestionType.values,
                labelOf: (o) => appTranslation().get(o.labelKey),
                isSelected: (o) => o == _question.type,
                onTap: (o) => setState(() => _question = _question.copyWith(type: o)),
              ),
              verticalSpace14,
              const PrimaryFieldLabel(textKey: 'reading_question_text'),
              verticalSpace8,
              TextField(
                controller: _text,
                maxLines: 3,
                style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                decoration: _decoration('reading_question_text_hint'),
              ),
              if (type.needsOptions) ...[
                verticalSpace14,
                const PrimaryFieldLabel(textKey: 'reading_question_options'),
                verticalSpace8,
                TextField(
                  controller: _options,
                  maxLines: 4,
                  style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                  decoration: _decoration('reading_question_options_hint'),
                ),
              ],
              verticalSpace14,
              if (type == ReadingQuestionType.trueFalse) ...[
                const PrimaryFieldLabel(textKey: 'reading_question_answer'),
                verticalSpace8,
                PrimaryChoiceChips<String>(
                  options: const [ReadingTrueFalse.isTrue, ReadingTrueFalse.isFalse],
                  labelOf: (o) => _isEnglish
                      ? (o == ReadingTrueFalse.isTrue ? 'True' : 'False')
                      : o,
                  isSelected: (o) => _answer.text.trim() == o,
                  onTap: (o) => setState(() => _answer.text = o),
                ),
              ] else if (type != ReadingQuestionType.essay) ...[
                const PrimaryFieldLabel(textKey: 'reading_question_answer'),
                verticalSpace8,
                TextField(
                  controller: _answer,
                  maxLines: 2,
                  style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                  decoration: _decoration('reading_question_answer_hint'),
                ),
              ] else ...[
                const PrimaryFieldLabel(textKey: 'reading_question_model_answer'),
                verticalSpace8,
                TextField(
                  controller: _answer,
                  maxLines: 2,
                  style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                  decoration: _decoration('reading_question_model_answer_hint'),
                ),
              ],
              if (_error != null) ...[
                verticalSpace10,
                Text(
                  appTranslation().get(_error!),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.errorColor),
                ),
              ],
              verticalSpace20,
              PrimaryElevatedButton(text: appTranslation().get('save'), onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

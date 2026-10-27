import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/reading_editor_cubit.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_question_group.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_question_sheet.dart';

/// «الأسئلة» tab: three level groups, each with its questions and «+ سؤال».
class ReadingQuestionsTab extends StatelessWidget {
  const ReadingQuestionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReadingEditorCubit.get(context);
    return BlocBuilder<ReadingEditorCubit, ReadingEditorState>(
      buildWhen: (p, c) => p.input.questions != c.input.questions || p.questionErrors != c.questionErrors,
      builder: (context, state) {
        final questions = state.input.questions;
        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appTranslation().get('reading_questions_label'),
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                ),
                Text(
                  appTranslation().get('reading_questions_count').replaceAll('{count}', '${questions.length}'),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
              ],
            ),
            verticalSpace14,
            for (final level in ReadingQuestionLevel.values)
              ReadingQuestionGroup(
                level: level,
                entries: [
                  for (var i = 0; i < questions.length; i++)
                    if (questions[i].level == level) (index: i, question: questions[i]),
                ],
                errors: state.questionErrors,
                canAdd: state.input.canAddQuestion,
                onTapQuestion: (index) => ReadingQuestionSheet.show(context, cubit: cubit, index: index),
                onMove: cubit.moveQuestion,
                onDelete: cubit.removeQuestion,
                onAdd: () => cubit.addQuestion(level),
              ),
          ],
        );
      },
    );
  }
}

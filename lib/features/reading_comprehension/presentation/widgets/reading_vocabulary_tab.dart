import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/reading_editor_cubit.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_vocabulary_tile.dart';

/// «المفردات» tab: word / meaning rows, up to 10.
class ReadingVocabularyTab extends StatelessWidget {
  const ReadingVocabularyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReadingEditorCubit.get(context);
    return BlocBuilder<ReadingEditorCubit, ReadingEditorState>(
      buildWhen: (p, c) => p.input.vocabulary != c.input.vocabulary || p.vocabularyErrors != c.vocabularyErrors,
      builder: (context, state) {
        final vocabulary = state.input.vocabulary;
        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              appTranslation().get('reading_vocab_hint'),
              style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
            ),
            verticalSpace12,
            if (vocabulary.isEmpty)
              NoDataWidget(
                icon: Icons.menu_book_outlined,
                title: appTranslation().get('reading_vocab_empty_title'),
                subtitle: appTranslation().get('reading_vocab_empty_subtitle'),
              ),
            for (var i = 0; i < vocabulary.length; i++)
              ReadingVocabularyTile(
                key: ValueKey('vocab_$i'),
                index: i,
                word: vocabulary[i].word,
                meaning: vocabulary[i].meaning,
                error: state.vocabularyErrors[i],
                onWordChanged: (value) => cubit.updateVocabulary(i, word: value),
                onMeaningChanged: (value) => cubit.updateVocabulary(i, meaning: value),
                onDelete: () => cubit.removeVocabulary(i),
              ),
            verticalSpace8,
            if (state.input.canAddVocabulary)
              OutlinedButton.icon(
                onPressed: cubit.addVocabulary,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  side: BorderSide(color: ColorsManager.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.add_rounded, size: 20, color: ColorsManager.primaryColor),
                label: Text(
                  appTranslation().get('reading_add_vocab'),
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                ),
              ),
          ],
        );
      },
    );
  }
}

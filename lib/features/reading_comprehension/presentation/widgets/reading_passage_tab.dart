import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/reading_editor_cubit.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_paragraph_tile.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_title_section.dart';

/// «القطعة» tab: the title, numbered paragraphs, the word count and an add button.
class ReadingPassageTab extends StatelessWidget {
  const ReadingPassageTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReadingEditorCubit.get(context);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const ReadingTitleSection(),
        verticalSpace14,
        BlocBuilder<ReadingEditorCubit, ReadingEditorState>(
          buildWhen: (p, c) => p.input.passage != c.input.passage || p.passageErrors != c.passageErrors,
          builder: (context, state) {
            final passage = state.input.passage;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appTranslation().get('reading_passage_label'),
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                    ),
                    Text(
                      appTranslation().get('reading_word_count').replaceAll('{count}', '${state.input.wordCount}'),
                      style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                    ),
                  ],
                ),
                verticalSpace10,
                for (var i = 0; i < passage.length; i++)
                  ReadingParagraphTile(
                    key: ValueKey('paragraph_$i'),
                    index: i,
                    total: passage.length,
                    text: passage[i],
                    error: state.passageErrors[i],
                    onChanged: (value) => cubit.updateParagraph(i, value),
                    onMoveUp: i > 0 ? () => cubit.moveParagraph(i, -1) : null,
                    onMoveDown: i < passage.length - 1 ? () => cubit.moveParagraph(i, 1) : null,
                    onDelete: passage.length > 1 ? () => cubit.removeParagraph(i) : null,
                  ),
                if (state.input.canAddParagraph)
                  OutlinedButton.icon(
                    onPressed: cubit.addParagraph,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      side: BorderSide(color: ColorsManager.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: Icon(Icons.add_rounded, size: 20, color: ColorsManager.primaryColor),
                    label: Text(
                      appTranslation().get('reading_add_paragraph'),
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

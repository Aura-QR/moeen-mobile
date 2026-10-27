import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_question_tile.dart';

/// One level section of the questions tab («فهم مباشر» / «استنتاج» / «تفكير ناقد»).
class ReadingQuestionGroup extends StatelessWidget {
  final ReadingQuestionLevel level;

  /// The questions in this level, paired with their index in the full list.
  final List<({int index, ReadingQuestion question})> entries;
  final Map<int, String> errors;
  final bool canAdd;
  final void Function(int index) onTapQuestion;
  final void Function(int index, int delta) onMove;
  final void Function(int index) onDelete;
  final VoidCallback onAdd;

  const ReadingQuestionGroup({
    super.key,
    required this.level,
    required this.entries,
    required this.errors,
    required this.canAdd,
    required this.onTapQuestion,
    required this.onMove,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          appTranslation().get(level.labelKey),
          style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
        ),
        verticalSpace10,
        for (var i = 0; i < entries.length; i++)
          ReadingQuestionTile(
            key: ValueKey('question_${entries[i].index}'),
            order: i + 1,
            question: entries[i].question,
            error: errors[entries[i].index],
            onTap: () => onTapQuestion(entries[i].index),
            onMoveUp: i > 0 ? () => onMove(entries[i].index, -1) : null,
            onMoveDown: i < entries.length - 1 ? () => onMove(entries[i].index, 1) : null,
            onDelete: () => onDelete(entries[i].index),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: canAdd ? onAdd : null,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(appTranslation().get('reading_add_question'), style: TextStylesManager.bold13),
          ),
        ),
        verticalSpace16,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_field_label.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/new_reading_cubit.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_question_count_stepper.dart';

/// The generation options: level, length (with a word-count hint), question
/// count, and language (English subjects only).
class ReadingOptionsSection extends StatelessWidget {
  final NewReadingState state;

  const ReadingOptionsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = NewReadingCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.tune_rounded,
      title: appTranslation().get('reading_options_title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PrimaryFieldLabel(textKey: 'reading_option_level'),
          verticalSpace8,
          PrimaryChoiceChips<ReadingLevel>(
            options: ReadingLevel.values,
            labelOf: (o) => appTranslation().get(o.labelKey),
            isSelected: (o) => o == state.level,
            onTap: cubit.setLevel,
          ),
          verticalSpace14,
          const PrimaryFieldLabel(textKey: 'reading_option_length'),
          verticalSpace8,
          PrimaryChoiceChips<ReadingLength>(
            options: ReadingLength.values,
            labelOf: (o) => appTranslation().get(o.labelKey),
            isSelected: (o) => o == state.length,
            onTap: cubit.setLength,
          ),
          verticalSpace6,
          Text(
            appTranslation().get(state.length.approxWordsKey),
            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
          ),
          verticalSpace14,
          const PrimaryFieldLabel(textKey: 'reading_option_questions'),
          verticalSpace8,
          ReadingQuestionCountStepper(
            value: state.questionsCount,
            onChanged: cubit.setQuestionsCount,
          ),
          if (state.isEnglishSubject) ...[
            verticalSpace14,
            const PrimaryFieldLabel(textKey: 'reading_option_language'),
            verticalSpace8,
            PrimaryChoiceChips<ReadingLanguage>(
              options: ReadingLanguage.values,
              labelOf: (o) => appTranslation().get(o.labelKey),
              isSelected: (o) => o == state.language,
              onTap: cubit.setLanguage,
            ),
          ],
        ],
      ),
    );
  }
}

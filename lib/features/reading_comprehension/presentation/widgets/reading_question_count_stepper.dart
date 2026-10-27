import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';

/// A −/+ stepper bounded to 4–12 generated questions.
class ReadingQuestionCountStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const ReadingQuestionCountStepper({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: value > ReadingLimits.minGeneratedQuestions ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_rounded),
        ),
        horizontalSpace16,
        Text('$value', style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
        horizontalSpace16,
        IconButton.filledTonal(
          onPressed: value < ReadingLimits.maxGeneratedQuestions ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class TahsiliQuestionOptionRow extends StatelessWidget {
  final String letter;
  final TextEditingController controller;
  final bool isCorrect;
  final VoidCallback onSelectAsCorrect;
  final ValueChanged<String> onChanged;

  const TahsiliQuestionOptionRow({
    super.key,
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

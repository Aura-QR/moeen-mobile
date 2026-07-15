import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ManualExamTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  const ManualExamTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      {'id': 'mcq', 'label': appTranslation().get('mcq')},
      {'id': 'true_false', 'label': appTranslation().get('true_false')},
      {'id': 'fill_blank', 'label': appTranslation().get('fill_blank')},
      {'id': 'essay', 'label': appTranslation().get('essay')},
      {'id': 'matching', 'label': appTranslation().get('matching')},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appTranslation().get('question_type'),
          style: TextStylesManager.bold14.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        verticalSpace8,
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: types.map((type) {
            final isSelected = selectedType == type['id'];
            return GestureDetector(
              onTap: () => onTypeSelected(type['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type['label']!,
                  style: TextStylesManager.medium14.copyWith(
                    color: isSelected ? Colors.white : ColorsManager.secondaryText,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

/// A wrap of tappable chips. The caller decides what is selected, so it
/// serves single and multiple choice alike.
class PrimaryChoiceChips<T> extends StatelessWidget {
  final List<T> options;

  /// The text shown for an option, already translated.
  final String Function(T option) labelOf;
  final bool Function(T option) isSelected;
  final ValueChanged<T> onTap;

  const PrimaryChoiceChips({
    super.key,
    required this.options,
    required this.labelOf,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(labelOf(option)),
            selected: isSelected(option),
            onSelected: (_) => onTap(option),
            showCheckmark: false,
            selectedColor: ColorsManager.primaryColor,
            backgroundColor: ColorsManager.background,
            side: BorderSide(color: isSelected(option) ? ColorsManager.primaryColor : ColorsManager.borderColor),
            labelStyle: TextStylesManager.medium13.copyWith(
              color: isSelected(option) ? ColorsManager.white : ColorsManager.mainText,
            ),
          ),
      ],
    );
  }
}

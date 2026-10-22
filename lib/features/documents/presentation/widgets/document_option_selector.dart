import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// A labelled two-or-more-way choice, e.g. «الصيغة»: معلم / معلمة.
class DocumentOptionSelector<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final T selected;
  final String Function(T option) labelKeyOf;
  final ValueChanged<T> onChanged;

  const DocumentOptionSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.labelKeyOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: TextStylesManager.medium13.copyWith(color: ColorsManager.secondaryText)),
        verticalSpace8,
        SegmentedButton<T>(
          showSelectedIcon: false,
          segments: [
            for (final option in options)
              ButtonSegment(
                value: option,
                label: Text(appTranslation().get(labelKeyOf(option)), style: TextStylesManager.medium13),
              ),
          ],
          selected: {selected},
          onSelectionChanged: (values) => onChanged(values.first),
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: ColorsManager.primaryColor,
            selectedForegroundColor: ColorsManager.white,
            foregroundColor: ColorsManager.mainText,
            side: BorderSide(color: ColorsManager.borderColor),
          ),
        ),
      ],
    );
  }
}

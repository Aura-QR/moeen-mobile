import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

class DiagnosticCountRow extends StatelessWidget {
  final String labelKey;
  final int value;
  final List<int> values;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const DiagnosticCountRow({
    super.key,
    required this.labelKey,
    required this.value,
    required this.values,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            appTranslation().get(labelKey),
            style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
          ),
        ),
        DropdownButton<int>(
          value: value,
          dropdownColor: ColorsManager.surfacePrimary,
          style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
          items: [
            for (final v in values)
              DropdownMenuItem<int>(
                value: v,
                child: Text('$v', style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
              ),
          ],
          onChanged: enabled ? (v) => v == null ? null : onChanged(v) : null,
        ),
      ],
    );
  }
}

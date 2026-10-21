import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

/// Items with no evidence yet; tapping one scrolls to it.
class PortfolioMissingChipsWidget extends StatelessWidget {
  final List<String> missing;
  final ValueChanged<String> onTap;

  const PortfolioMissingChipsWidget({super.key, required this.missing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final title in missing)
          ActionChip(
            onPressed: () => onTap(title),
            label: Text(title, style: TextStylesManager.medium12.copyWith(color: ColorsManager.statusWarning)),
            backgroundColor: ColorsManager.statusWarning.withValues(alpha: 0.08),
            side: BorderSide(color: ColorsManager.statusWarning.withValues(alpha: 0.25)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

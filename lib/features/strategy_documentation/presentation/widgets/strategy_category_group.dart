import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/strategy_documentation/data/models/strategy_models.dart';

/// A category heading with its strategies.
class StrategyCategoryGroup extends StatelessWidget {
  final StrategyCategoryModel category;
  final List<StrategySummaryModel> strategies;
  final String? selectedKey;
  final ValueChanged<String> onPick;

  const StrategyCategoryGroup({
    super.key,
    required this.category,
    required this.strategies,
    required this.selectedKey,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 4),
          child: Text(
            category.label,
            style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
          ),
        ),
        for (final strategy in strategies)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              strategy.name,
              style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
            ),
            trailing: strategy.key == selectedKey
                ? Icon(Icons.check_circle_rounded, color: ColorsManager.primaryColor)
                : null,
            onTap: () => onPick(strategy.key),
          ),
      ],
    );
  }
}

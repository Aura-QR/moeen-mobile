import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_palette.dart';

/// A suggested teaching strategy with its definition and steps.
class LearningStyleStrategyCard extends StatelessWidget {
  final StrategyCard strategy;

  const LearningStyleStrategyCard({super.key, required this.strategy});

  @override
  Widget build(BuildContext context) {
    final color = learningStyleColor(strategy.style);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              horizontalSpace8,
              Expanded(
                child: Text(strategy.name, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
              ),
            ],
          ),
          if (strategy.definition.isNotEmpty) ...[
            verticalSpace6,
            Text(strategy.definition, style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText)),
          ],
          if (strategy.steps.isNotEmpty) ...[
            verticalSpace8,
            for (final step in strategy.steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStylesManager.regular13.copyWith(color: color)),
                    Expanded(
                      child: Text(step, style: TextStylesManager.regular13.copyWith(color: ColorsManager.mainText)),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_palette.dart';

/// A horizontal bar per style, showing its share of the class (`percents`).
class LearningStyleBarChart extends StatelessWidget {
  final StyleSummary summary;
  final List<StyleInfo> styles;

  const LearningStyleBarChart({super.key, required this.summary, required this.styles});

  String _roundedPercent(num value) {
    final rounded = value.round();
    return '$rounded%';
  }

  @override
  Widget build(BuildContext context) {
    final order = styles.isNotEmpty ? styles : [for (final key in LearningStyleKeys.all) StyleInfo(key: key, label: key)];
    return Column(
      children: [
        for (final style in order)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(style.label,
                      style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (summary.percents[style.key] ?? 0) / 100,
                      minHeight: 12,
                      backgroundColor: ColorsManager.borderLightGray,
                      color: learningStyleColor(style.key),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: Text(_roundedPercent(summary.percents[style.key] ?? 0),
                      textAlign: TextAlign.end,
                      style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

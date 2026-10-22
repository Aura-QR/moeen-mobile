import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_result.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_band_bars.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_comparison_table.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_stats_grid.dart';

/// The numbers: all the classes together (or the only one), the levels,
/// and the comparison when there are several classes.
class GradeResultsView extends StatelessWidget {
  final GradeAnalysisResult result;

  const GradeResultsView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final overall = result.overall;
    if (overall == null) return const SizedBox.shrink();
    final subtitle = TextStylesManager.bold14.copyWith(color: ColorsManager.mainText);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.isComparison) ...[Text(appTranslation().get('grades_results_all'), style: subtitle), verticalSpace8],
        GradeStatsGrid(stats: overall.stats, totalMark: result.totalMark),
        if (overall.absent.isNotEmpty) ...[
          verticalSpace8,
          Text(
            appTranslation().get('grades_results_absent').replaceAll('{count}', '${overall.absent.length}'),
            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
          ),
        ],
        verticalSpace16,
        Text(appTranslation().get('grades_results_bands'), style: subtitle),
        verticalSpace10,
        GradeBandBars(bands: overall.stats.bands),
        if (result.isComparison) ...[
          verticalSpace10,
          Text(appTranslation().get('grades_results_comparison'), style: subtitle),
          verticalSpace8,
          GradeComparisonTable(classes: result.classes),
        ],
      ],
    );
  }
}

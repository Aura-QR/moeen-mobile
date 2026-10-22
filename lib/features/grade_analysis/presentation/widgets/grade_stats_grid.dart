import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_result.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_stat_card.dart';

/// المتوسط، نسبة النجاح، أعلى وأدنى درجة، الانحراف المعياري، الوسيط.
class GradeStatsGrid extends StatelessWidget {
  final GradeStats stats;
  final double totalMark;

  const GradeStatsGrid({super.key, required this.stats, required this.totalMark});

  @override
  Widget build(BuildContext context) {
    String t(String key) => appTranslation().get(key);
    final outOf = t('grades_out_of').replaceAll('{total}', formatGrade(totalMark));
    final cards = [
      GradeStatCard(
        icon: Icons.functions_rounded,
        label: t('grades_stat_mean'),
        value: formatGrade(stats.mean),
        detail: '${formatGrade(stats.meanPercent)}%',
      ),
      GradeStatCard(
        icon: Icons.verified_outlined,
        label: t('grades_stat_pass_rate'),
        value: '${formatGrade(stats.passRate)}%',
        detail: t(
          'grades_stat_passed_of',
        ).replaceAll('{passed}', '${stats.passed}').replaceAll('{count}', '${stats.count}'),
      ),
      GradeStatCard(
        icon: Icons.arrow_upward_rounded,
        label: t('grades_stat_max'),
        value: formatGrade(stats.max),
        detail: outOf,
      ),
      GradeStatCard(
        icon: Icons.arrow_downward_rounded,
        label: t('grades_stat_min'),
        value: formatGrade(stats.min),
        detail: outOf,
      ),
      GradeStatCard(icon: Icons.ssid_chart_rounded, label: t('grades_stat_stddev'), value: formatGrade(stats.stddev)),
      GradeStatCard(
        icon: Icons.align_vertical_center_rounded,
        label: t('grades_stat_median'),
        value: formatGrade(stats.median),
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: cards,
    );
  }
}

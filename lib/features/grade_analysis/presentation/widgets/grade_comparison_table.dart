import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_result.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_table_cell.dart';

/// The classes side by side, with «الترتيب».
class GradeComparisonTable extends StatelessWidget {
  final List<GradeClassResult> classes;

  const GradeComparisonTable({super.key, required this.classes});

  @override
  Widget build(BuildContext context) {
    final head = TextStylesManager.bold12.copyWith(color: ColorsManager.secondaryText);
    final cell = TextStylesManager.regular13.copyWith(color: ColorsManager.mainText);
    return Table(
      columnWidths: const {0: FlexColumnWidth(2)},
      border: TableBorder(horizontalInside: BorderSide(color: ColorsManager.borderLightGray)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            for (final key in ['grades_col_class', 'grades_col_mean', 'grades_col_pass_rate', 'grades_col_rank'])
              GradeTableCell(appTranslation().get(key), style: head),
          ],
        ),
        for (final result in classes)
          TableRow(
            children: [
              GradeTableCell(result.name, style: cell),
              GradeTableCell('${formatGrade(result.stats.meanPercent)}%', style: cell),
              GradeTableCell('${formatGrade(result.stats.passRate)}%', style: cell),
              GradeTableCell(
                result.rank == null ? '—' : '${result.rank}',
                style: TextStylesManager.bold14.copyWith(
                  color: result.rank == 1 ? ColorsManager.primaryColor : ColorsManager.mainText,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

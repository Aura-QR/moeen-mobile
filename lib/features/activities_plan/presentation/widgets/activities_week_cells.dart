import 'package:flutter/material.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_domain_cell.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_extracurricular_cell.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_periods_cell.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_program_cell.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_text_cell_tile.dart';

/// The cells of a teaching or exam week.
///
/// An official teaching week has a domain, a program, its periods, a non-class
/// program and the occasions; every other week edits each of its columns as text.
class ActivitiesWeekCells extends StatelessWidget {
  final ActivitiesWeekModel week;
  final ActivitiesPlanState state;

  const ActivitiesWeekCells({super.key, required this.week, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    final isOfficialTeaching = state.isOfficial && week.type == ActivitiesWeekType.teaching;
    final grid = state.grid!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isOfficialTeaching) ...[
          ActivitiesDomainCell(week: week, state: state),
          ActivitiesProgramCell(week: week, state: state),
          ActivitiesPeriodsCell(week: week, state: state),
          ActivitiesExtracurricularCell(week: week, state: state),
        ],
        for (final column in grid.columnsOf(week))
          if (!isOfficialTeaching || column.key == ActivitiesColumns.occasion)
            ActivitiesTextCellTile(
              label: column.label,
              text: state.textOf(week, column.key),
              isEdited: state.isEdited(week, column.key),
              onChanged: (text) => cubit.setCell(week.week!, column.key, text),
              onReset: () => cubit.resetCell(week.week!, column.key),
            ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/primary/primary_input_dialog.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_cell_tile.dart';

/// «الحصص»: a whole number from 0 to 20.
class ActivitiesPeriodsCell extends StatelessWidget {
  final ActivitiesWeekModel week;
  final ActivitiesPlanState state;

  const ActivitiesPeriodsCell({super.key, required this.week, required this.state});

  Future<void> _edit(BuildContext context) async {
    final cubit = ActivitiesPlanCubit.get(context);
    final values = await PrimaryInputDialog.show(
      context,
      titleKey: 'activities_plan_edit_periods',
      fields: [
        PrimaryInputField(
          hintKey: 'activities_plan_periods_hint',
          initialValue: state.textOf(week, ActivitiesColumns.periods),
          maxLength: 2,
          keyboardType: TextInputType.number,
        ),
      ],
    );
    if (values != null) cubit.setPeriods(week.week!, values.first);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return ActivitiesCellTile(
      label: state.grid!.columnLabel(ActivitiesColumns.periods),
      text: state.textOf(week, ActivitiesColumns.periods),
      isEdited: state.isEdited(week, ActivitiesColumns.periods),
      onTap: () => _edit(context),
      onReset: () => cubit.resetCell(week.week!, ActivitiesColumns.periods),
    );
  }
}

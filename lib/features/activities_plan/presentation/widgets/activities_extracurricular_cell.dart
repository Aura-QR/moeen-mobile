import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_picker_sheet.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_cell_tile.dart';

/// «الفترات اللاصفية»: one of the 10 non-class programs; empty by default.
/// The plan stores the program's key.
class ActivitiesExtracurricularCell extends StatelessWidget {
  final ActivitiesWeekModel week;
  final ActivitiesPlanState state;

  const ActivitiesExtracurricularCell({super.key, required this.week, required this.state});

  Future<void> _pick(BuildContext context) async {
    final choice = await PrimaryPickerSheet.show<String>(
      context,
      title: appTranslation().get('activities_plan_pick_extracurricular'),
      selected: state.textOf(week, ActivitiesColumns.extracurricular),
      options: [
        PrimaryPickerOption(value: '', label: appTranslation().get('activities_plan_extracurricular_none')),
        for (final program in state.catalogue.extracurricular)
          PrimaryPickerOption(value: program.key, label: program.label),
      ],
    );
    if (choice == null || !context.mounted) return;
    ActivitiesPlanCubit.get(context).setCell(week.week!, ActivitiesColumns.extracurricular, choice);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    final key = state.textOf(week, ActivitiesColumns.extracurricular);
    return ActivitiesCellTile(
      label: state.grid!.columnLabel(ActivitiesColumns.extracurricular),
      text: key.isEmpty ? '' : state.catalogue.extracurricularLabel(key),
      isEdited: state.isEdited(week, ActivitiesColumns.extracurricular),
      onTap: () => _pick(context),
      onReset: () => cubit.resetCell(week.week!, ActivitiesColumns.extracurricular),
    );
  }
}

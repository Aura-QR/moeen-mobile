import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_input_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_picker_sheet.dart';
import 'package:moean/features/activities_plan/data/models/activities_catalogue_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_program_models.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_cell_tile.dart';

/// «البرنامج»: an approved program of the band and domain, or, through the last
/// choice, a locally approved program typed by the teacher.
class ActivitiesProgramCell extends StatelessWidget {
  /// The picker's last choice; no program is named like this.
  static const String _other = '__other__';

  final ActivitiesWeekModel week;
  final ActivitiesPlanState state;

  const ActivitiesProgramCell({super.key, required this.week, required this.state});

  String _subtitle(ActivitiesProgramOption option) {
    final periods = appTranslation().get('activities_plan_periods_count').replaceAll('{n}', '${option.periods}');
    return option.outsideHours ? '$periods · ${appTranslation().get('activities_plan_outside_hours')}' : periods;
  }

  Future<void> _pick(BuildContext context) async {
    final cubit = ActivitiesPlanCubit.get(context);
    final text = state.textOf(week, ActivitiesColumns.program);
    final domain = state.textOf(week, ActivitiesColumns.domain);
    final programs = state.catalogue.programOptions(domain, state.band);
    final choice = await PrimaryPickerSheet.show<String>(
      context,
      title: appTranslation().get('activities_plan_pick_program'),
      selected: ActivitiesCatalogueModel.baseProgram(text),
      options: [
        for (final program in programs)
          PrimaryPickerOption(value: program.label, label: program.label, subtitle: _subtitle(program)),
        PrimaryPickerOption(value: _other, label: appTranslation().get('activities_plan_program_other')),
      ],
    );
    if (choice == null || !context.mounted) return;
    if (choice != _other) {
      cubit.setProgram(week.week!, choice, periods: programs.firstWhere((program) => program.label == choice).periods);
      return;
    }
    final values = await PrimaryInputDialog.show(
      context,
      titleKey: 'activities_plan_program_other',
      fields: [
        PrimaryInputField(
          hintKey: 'activities_plan_program_other_hint',
          initialValue: state.catalogue.isOfficialProgram(text) ? '' : text,
          maxLength: 300,
        ),
      ],
    );
    if (values != null) cubit.setProgram(week.week!, values.first.trim());
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    final text = state.textOf(week, ActivitiesColumns.program);
    return ActivitiesCellTile(
      label: state.grid!.columnLabel(ActivitiesColumns.program),
      text: text,
      isEdited: state.isEdited(week, ActivitiesColumns.program),
      hint: text.isNotEmpty && !state.catalogue.isOfficialProgram(text)
          ? appTranslation().get('activities_plan_local_program')
          : null,
      onTap: () => _pick(context),
      onReset: () => cubit.resetCell(week.week!, ActivitiesColumns.program),
    );
  }
}

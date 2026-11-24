import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_picker_sheet.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_cell_tile.dart';

/// «المجال»: one of the 5 domains, or «الأيام والمناسبات».
class ActivitiesDomainCell extends StatelessWidget {
  final ActivitiesWeekModel week;
  final ActivitiesPlanState state;

  const ActivitiesDomainCell({super.key, required this.week, required this.state});

  Future<void> _pick(BuildContext context) async {
    final domain = await PrimaryPickerSheet.show<String>(
      context,
      title: appTranslation().get('activities_plan_pick_domain'),
      selected: state.textOf(week, ActivitiesColumns.domain),
      options: [
        for (final domain in state.catalogue.officialDomains)
          PrimaryPickerOption(value: domain.key, label: domain.label),
      ],
    );
    if (domain == null || !context.mounted) return;
    ActivitiesPlanCubit.get(context).setCell(week.week!, ActivitiesColumns.domain, domain);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return ActivitiesCellTile(
      label: state.grid!.columnLabel(ActivitiesColumns.domain),
      text: state.catalogue.officialDomainLabel(state.textOf(week, ActivitiesColumns.domain)),
      isEdited: state.isEdited(week, ActivitiesColumns.domain),
      onTap: () => _pick(context),
      onReset: () => cubit.resetCell(week.week!, ActivitiesColumns.domain),
    );
  }
}

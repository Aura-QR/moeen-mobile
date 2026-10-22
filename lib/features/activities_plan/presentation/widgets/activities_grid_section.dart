import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_cell_tile.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_holiday_tile.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_week_card.dart';

/// «جدول الخطة»: the suggested activities week by week, each cell editable.
class ActivitiesGridSection extends StatelessWidget {
  const ActivitiesGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.table_chart_outlined,
      title: appTranslation().get('activities_plan_section_grid'),
      child: BlocBuilder<ActivitiesPlanCubit, ActivitiesPlanState>(
        buildWhen: (previous, current) =>
            previous.gridStatus != current.gridStatus ||
            previous.grid != current.grid ||
            previous.cells != current.cells,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.gridStatus == ActivitiesGridStatus.loading,
          errorState: state.gridStatus == ActivitiesGridStatus.failure,
          emptyState: state.grid == null,
          loadingBuilder: (_) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          errorBuilder: (_) => PrimaryErrorView(message: state.gridError ?? 'generic_error', onRetry: cubit.loadGrid),
          emptyBuilder: (_) => Text(
            appTranslation().get('activities_plan_grid_hint'),
            style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
          ),
          successBuilder: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('activities_plan_grid_note'),
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
              ),
              verticalSpace12,
              for (final week in state.grid!.weeks)
                if (week.isHoliday || week.week == null)
                  ActivitiesHolidayTile(week: week)
                else
                  ActivitiesWeekCard(
                    week: week,
                    cells: [
                      for (final column in state.grid!.columnsOf(week))
                        ActivitiesCellTile(
                          label: column.label,
                          text: state.textOf(week, column.key),
                          isEdited: state.isEdited(week, column.key),
                          onChanged: (text) => cubit.setCell(week.week!, column.key, text),
                          onReset: () => cubit.resetCell(week.week!, column.key),
                        ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

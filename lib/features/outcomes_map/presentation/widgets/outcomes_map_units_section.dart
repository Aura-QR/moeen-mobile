import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_map_editor_cubit.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_ai_progress.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_unit_card.dart';

/// Units list with the «✨ اقترح النواتج» action, progress and «+ وحدة».
class OutcomesMapUnitsSection extends StatelessWidget {
  const OutcomesMapUnitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = OutcomesMapEditorCubit.get(context);
    return BlocBuilder<OutcomesMapEditorCubit, OutcomesMapEditorState>(
      buildWhen: (previous, current) =>
          previous.input.units != current.input.units ||
          previous.unitErrors != current.unitErrors ||
          previous.lessonErrors != current.lessonErrors ||
          previous.unitAiStatus != current.unitAiStatus ||
          previous.isSuggestingAll != current.isSuggestingAll ||
          previous.aiCurrentUnit != current.aiCurrentUnit ||
          previous.aiBusyLesson != current.aiBusyLesson,
      builder: (context, state) {
        final units = state.input.units;
        return PrimarySectionCard(
          icon: Icons.account_tree_outlined,
          title: appTranslation().get('outcomes_map_units_title'),
          trailing: Text(
            '${units.length}/${OutcomesMapLimits.maxUnits}',
            style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: !state.isAiBusy && state.input.hasAnyFillableLesson
                    ? cubit.suggestAllOutcomes
                    : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  side: BorderSide(color: ColorsManager.primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.auto_awesome_rounded, size: 20, color: ColorsManager.primaryColor),
                label: Text(
                  appTranslation().get('outcomes_map_suggest_all'),
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                ),
              ),
              if (state.isSuggestingAll) ...[
                verticalSpace12,
                OutcomesMapAiProgress(current: state.aiCurrentUnit, total: state.aiTotalUnits),
              ],
              verticalSpace12,
              for (var index = 0; index < units.length; index++) ...[
                OutcomesMapUnitCard(unitIndex: index, unit: units[index], state: state),
                if (index < units.length - 1) verticalSpace10,
              ],
              verticalSpace12,
              TextButton.icon(
                onPressed:
                    state.input.canAddUnit && !state.isAiBusy ? cubit.addUnit : null,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(appTranslation().get('outcomes_map_add_unit')),
              ),
            ],
          ),
        );
      },
    );
  }
}

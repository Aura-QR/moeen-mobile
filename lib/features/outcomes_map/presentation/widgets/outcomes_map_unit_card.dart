import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_map_editor_cubit.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_lesson_sheet.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_lesson_tile.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_synced_field.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_unit_status.dart';

/// One expandable unit: its name, AI status, lessons, and add/delete actions.
class OutcomesMapUnitCard extends StatelessWidget {
  final int unitIndex;
  final OutcomeUnit unit;
  final OutcomesMapEditorState state;

  const OutcomesMapUnitCard({
    super.key,
    required this.unitIndex,
    required this.unit,
    required this.state,
  });

  Future<void> _confirmDeleteUnit(BuildContext context, OutcomesMapEditorCubit cubit) async {
    final confirmed = await showPrimaryConfirmDialog(
      context,
      titleKey: 'outcomes_map_delete_unit_title',
      messageKey: 'outcomes_map_delete_unit_confirm',
    );
    if (confirmed) cubit.deleteUnit(unitIndex);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = OutcomesMapEditorCubit.get(context);
    final error = state.unitErrors[unitIndex];
    final isTreeOverflow = state.input.layout == OutcomesMapLayout.tree &&
        unit.outcomesCount > OutcomesMapLimits.treeTableThreshold;

    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: error != null ? ColorsManager.errorColor : ColorsManager.borderLightGray,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsetsDirectional.fromSTEB(14, 4, 8, 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          shape: const Border(),
          leading: Icon(Icons.folder_open_rounded, color: ColorsManager.primaryColor),
          title: Text(
            unit.name.trim().isEmpty
                ? appTranslation().get('outcomes_map_unit_untitled')
                : unit.name.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
          ),
          subtitle: Text(
            '${unit.lessons.length} ${appTranslation().get('outcomes_map_lessons_count')}',
            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
          ),
          trailing: OutcomesMapUnitStatus(
            status: state.unitStatus(unitIndex),
            onRetry: () => cubit.suggestUnit(unitIndex),
          ),
          children: [
            OutcomesMapSyncedField(
              value: unit.name,
              hint: appTranslation().get('outcomes_map_unit_name_hint'),
              onChanged: (value) => cubit.updateUnitName(unitIndex, value),
            ),
            if (error != null) ...[
              verticalSpace6,
              Text(
                error,
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.errorColor),
              ),
            ],
            if (isTreeOverflow) ...[
              verticalSpace8,
              Text(
                appTranslation().get('outcomes_map_tree_table_hint'),
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
              ),
            ],
            verticalSpace10,
            for (var lessonIndex = 0; lessonIndex < unit.lessons.length; lessonIndex++)
              OutcomesMapLessonTile(
                lesson: unit.lessons[lessonIndex],
                isAiBusy: state.aiBusyLesson == LessonRef(unitIndex, lessonIndex),
                errorMessage: state.lessonErrors[LessonRef(unitIndex, lessonIndex).key],
                onTap: () => OutcomesMapLessonSheet.show(
                  context,
                  cubit: cubit,
                  ref: LessonRef(unitIndex, lessonIndex),
                ),
              ),
            verticalSpace8,
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: state.input.canAddLesson(unitIndex) && !state.isAiBusy
                        ? () => cubit.addLesson(unitIndex)
                        : null,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(appTranslation().get('outcomes_map_add_lesson')),
                  ),
                ),
                IconButton(
                  tooltip: appTranslation().get('outcomes_map_delete_unit_title'),
                  onPressed: state.isAiBusy ? null : () => _confirmDeleteUnit(context, cubit),
                  icon: Icon(Icons.delete_outline_rounded, color: ColorsManager.errorColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

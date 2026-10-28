import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_map_editor_cubit.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_outcome_field.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_synced_field.dart';

/// Bottom sheet for editing a lesson's title and up to four outcomes.
class OutcomesMapLessonSheet extends StatelessWidget {
  final LessonRef ref;

  const OutcomesMapLessonSheet({super.key, required this.ref});

  static Future<void> show(
    BuildContext context, {
    required OutcomesMapEditorCubit cubit,
    required LessonRef ref,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: ColorsManager.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: OutcomesMapLessonSheet(ref: ref),
        ),
      );

  Future<void> _confirmDelete(BuildContext context, OutcomesMapEditorCubit cubit) async {
    final confirmed = await showPrimaryConfirmDialog(
      context,
      titleKey: 'outcomes_map_delete_lesson_title',
      messageKey: 'outcomes_map_delete_lesson_confirm',
    );
    if (!confirmed || !context.mounted) return;
    cubit.deleteLesson(ref.unitIndex, ref.lessonIndex);
    AppRouter.pop(null, context);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = OutcomesMapEditorCubit.get(context);
    return BlocBuilder<OutcomesMapEditorCubit, OutcomesMapEditorState>(
      buildWhen: (previous, current) =>
          previous.input != current.input ||
          previous.lessonErrors != current.lessonErrors ||
          previous.aiBusyLesson != current.aiBusyLesson,
      builder: (context, state) {
        final lesson = state.input.lessonAt(ref.unitIndex, ref.lessonIndex);
        if (lesson == null) return const SizedBox.shrink();
        final inset = MediaQuery.viewInsetsOf(context).bottom;
        final error = state.lessonErrors[ref.key];
        final isAiBusy = state.aiBusyLesson == ref;
        final canAddOutcome = state.input.canAddOutcome(ref.unitIndex, ref.lessonIndex);

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + inset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appTranslation().get('outcomes_map_lesson_title'),
                  style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                ),
                if (error != null) ...[
                  verticalSpace6,
                  Text(
                    appTranslation().get(error),
                    style: TextStylesManager.regular12.copyWith(color: ColorsManager.errorColor),
                  ),
                ],
                verticalSpace14,
                OutcomesMapSyncedField(
                  value: lesson.title,
                  label: appTranslation().get('outcomes_map_lesson_name'),
                  hint: appTranslation().get('outcomes_map_lesson_name_hint'),
                  maxLength: OutcomesMapLimits.maxLessonTitleLength,
                  onChanged: (value) =>
                      cubit.updateLessonTitle(ref.unitIndex, ref.lessonIndex, value),
                ),
                verticalSpace14,
                Text(
                  appTranslation().get('outcomes_map_outcomes_label'),
                  style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                ),
                verticalSpace10,
                for (var i = 0; i < lesson.outcomes.length; i++)
                  OutcomesMapOutcomeField(
                    key: ValueKey('outcome-$i'),
                    number: i + 1,
                    value: lesson.outcomes[i],
                    onChanged: (value) =>
                        cubit.updateOutcome(ref.unitIndex, ref.lessonIndex, i, value),
                    onDelete: () => cubit.deleteOutcome(ref.unitIndex, ref.lessonIndex, i),
                  ),
                TextButton.icon(
                  onPressed:
                      canAddOutcome ? () => cubit.addOutcome(ref.unitIndex, ref.lessonIndex) : null,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(appTranslation().get('outcomes_map_add_outcome')),
                ),
                verticalSpace8,
                OutlinedButton.icon(
                  onPressed: lesson.lessonId != null && !state.isAiBusy
                      ? () => cubit.suggestLesson(ref.unitIndex, ref.lessonIndex)
                      : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    side: BorderSide(color: ColorsManager.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: isAiBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.auto_awesome_rounded, size: 18, color: ColorsManager.primaryColor),
                  label: Text(
                    appTranslation().get('outcomes_map_suggest_lesson'),
                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                  ),
                ),
                verticalSpace10,
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, cubit),
                  icon: Icon(Icons.delete_outline_rounded, size: 20, color: ColorsManager.errorColor),
                  label: Text(
                    appTranslation().get('outcomes_map_delete_lesson'),
                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.errorColor),
                  ),
                ),
                verticalSpace10,
                PrimaryElevatedButton(
                  text: appTranslation().get('outcomes_map_done'),
                  onPressed: () => AppRouter.pop(null, context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

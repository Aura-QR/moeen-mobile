import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/lesson_picker_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_search_field.dart';

/// Step 1: a searchable list of curriculum stages.
class LessonPickerStagesView extends StatelessWidget {
  const LessonPickerStagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appTranslation().get('document_pick_stage'),
            style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
          ),
          verticalSpace12,
          const LessonPickerSearchField(),
          verticalSpace12,
          Expanded(
            child: BlocBuilder<LessonPickerCubit, LessonPickerState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.stages != current.stages ||
                  previous.query != current.query,
              builder: (context, state) {
                final stages = state.visibleStages;
                return ConditionalBuilder(
                  loadingState: state.status == LessonPickerStatus.loading,
                  errorState: state.status == LessonPickerStatus.failure,
                  emptyState: stages.isEmpty,
                  errorBuilder: (_) => PrimaryErrorView(
                    message: state.errorMessage ?? 'generic_error',
                    onRetry: LessonPickerCubit.get(context).load,
                  ),
                  emptyBuilder: (_) => NoDataWidget(title: appTranslation().get('document_no_stages')),
                  successBuilder: (_) => ListView.separated(
                    itemCount: stages.length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: ColorsManager.borderLightGray),
                    itemBuilder: (context, index) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.school_rounded, color: ColorsManager.primaryColor),
                      title: Text(
                        stages[index].name,
                        style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                      ),
                      trailing: Icon(Icons.chevron_left_rounded, color: ColorsManager.secondaryText),
                      onTap: () => LessonPickerCubit.get(context).selectStage(stages[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

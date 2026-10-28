import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/lesson_picker_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_search_field.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_step_header.dart';

/// Step 2: the stage's grades.
class LessonPickerGradesView extends StatelessWidget {
  const LessonPickerGradesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonPickerCubit, LessonPickerState>(
      buildWhen: (previous, current) =>
          previous.stage != current.stage || previous.query != current.query,
      builder: (context, state) {
        final cubit = LessonPickerCubit.get(context);
        final grades = state.visibleGrades;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LessonPickerStepHeader(title: state.stage?.name ?? '', onBack: cubit.backToStages),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: const LessonPickerSearchField(),
            ),
            verticalSpace12,
            Expanded(
              child: grades.isEmpty
                  ? NoDataWidget(title: appTranslation().get('document_no_grades'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      itemCount: grades.length,
                      separatorBuilder: (_, _) => Divider(height: 1, color: ColorsManager.borderLightGray),
                      itemBuilder: (context, index) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.groups_rounded, color: ColorsManager.primaryColor),
                        title: Text(
                          grades[index].name,
                          style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                        ),
                        subtitle: grades[index].track == null || grades[index].track!.isEmpty
                            ? null
                            : Text(
                                grades[index].track!,
                                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                              ),
                        trailing: Icon(Icons.chevron_left_rounded, color: ColorsManager.secondaryText),
                        onTap: () => cubit.selectGrade(grades[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

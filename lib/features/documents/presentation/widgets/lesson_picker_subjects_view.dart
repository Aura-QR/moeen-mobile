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

/// Step 3: the grade's subjects.
class LessonPickerSubjectsView extends StatelessWidget {
  const LessonPickerSubjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonPickerCubit, LessonPickerState>(
      buildWhen: (previous, current) =>
          previous.stage != current.stage ||
          previous.grade != current.grade ||
          previous.query != current.query,
      builder: (context, state) {
        final cubit = LessonPickerCubit.get(context);
        final subjects = state.visibleSubjects;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LessonPickerStepHeader(
              title: state.grade?.name ?? '',
              subtitle: state.stage?.name,
              onBack: cubit.backToGrades,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: const LessonPickerSearchField(),
            ),
            verticalSpace12,
            Expanded(
              child: subjects.isEmpty
                  ? NoDataWidget(title: appTranslation().get('document_no_subjects'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      itemCount: subjects.length,
                      separatorBuilder: (_, _) => Divider(height: 1, color: ColorsManager.borderLightGray),
                      itemBuilder: (context, index) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.menu_book_rounded, color: ColorsManager.primaryColor),
                        title: Text(
                          subjects[index].name,
                          style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                        ),
                        trailing: Icon(Icons.chevron_left_rounded, color: ColorsManager.secondaryText),
                        onTap: () => cubit.openSubject(subjects[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

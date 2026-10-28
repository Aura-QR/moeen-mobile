import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/features/documents/presentation/cubit/lesson_picker_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_step_header.dart';

/// Step 4: the subject's lessons, grouped by chapter.
class LessonPickerLessonsView extends StatelessWidget {
  const LessonPickerLessonsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonPickerCubit, LessonPickerState>(
      buildWhen: (previous, current) =>
          previous.lessonsStatus != current.lessonsStatus || previous.chapters != current.chapters,
      builder: (context, state) {
        final cubit = LessonPickerCubit.get(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LessonPickerStepHeader(
              title: state.subject?.name ?? '',
              subtitle: state.grade?.name,
              onBack: cubit.backToSubjects,
            ),
            Expanded(
              child: ConditionalBuilder(
                loadingState: state.lessonsStatus == LessonPickerStatus.loading,
                errorState: state.lessonsStatus == LessonPickerStatus.failure,
                emptyState: state.chapters.isEmpty,
                errorBuilder: (_) => PrimaryErrorView(
                  message: state.errorMessage ?? 'generic_error',
                  onRetry: () => cubit.openSubject(state.subject!),
                ),
                emptyBuilder: (_) => NoDataWidget(title: appTranslation().get('document_no_lessons')),
                successBuilder: (_) => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    for (final chapter in state.chapters) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 4),
                        child: Text(
                          chapter.title,
                          style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
                        ),
                      ),
                      for (final lesson in chapter.lessons)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            lesson.title,
                            style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                          ),
                          trailing: Icon(Icons.add_circle_outline_rounded, color: ColorsManager.primaryColor),
                          onTap: () => Navigator.pop(context, cubit.pick(lesson)),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/documents/data/repositories/curriculum_lessons_repository.dart';
import 'package:moean/features/documents/presentation/cubit/lesson_picker_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_grades_view.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_lessons_view.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_stages_view.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_subjects_view.dart';

/// Picks «الدرس» from the curriculum. Pops with the lesson.
class LessonPickerSheet extends StatelessWidget {
  const LessonPickerSheet({super.key});

  static Future<PickedLessonModel?> show(BuildContext context) {
    return showModalBottomSheet<PickedLessonModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider(
        create: (_) => LessonPickerCubit(CurriculumLessonsRepository())..load(),
        child: const LessonPickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: BlocBuilder<LessonPickerCubit, LessonPickerState>(
          buildWhen: (previous, current) => previous.step != current.step,
          builder: (context, state) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (state.step) {
              LessonPickerStep.stages => const LessonPickerStagesView(),
              LessonPickerStep.grades => const LessonPickerGradesView(),
              LessonPickerStep.subjects => const LessonPickerSubjectsView(),
              LessonPickerStep.lessons => const LessonPickerLessonsView(),
            },
          ),
        ),
      ),
    );
  }
}

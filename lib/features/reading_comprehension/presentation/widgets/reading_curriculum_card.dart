import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_dropdown_field.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/new_reading_cubit.dart';

/// Cascading curriculum dropdowns: Stage → (Track) → Grade → Subject → Lesson.
class ReadingCurriculumCard extends StatelessWidget {
  final NewReadingState state;

  const ReadingCurriculumCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = NewReadingCubit.get(context);
    final tracks = state.availableTracks;
    final grades = state.availableGrades;
    final subjects = state.availableSubjects;
    final lessons = [
      for (final ch in state.filteredChapters)
        for (final l in ch.lessons) l,
    ];

    final hasGrade = state.showGrades && grades.isNotEmpty;
    final hasSubject = state.selectedGrade != null && subjects.isNotEmpty;
    final canPickLesson = state.selectedSubject != null && !state.isLessonsLoading && lessons.isNotEmpty;

    final lessonHint = state.isLessonsLoading
        ? appTranslation().get('reading_lessons_loading')
        : (state.selectedSubject != null && lessons.isEmpty
            ? appTranslation().get('document_no_lessons')
            : appTranslation().get('reading_select_placeholder'));

    return PrimarySectionCard(
      icon: Icons.school_outlined,
      title: appTranslation().get('reading_curriculum_title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConceptMapDropdownField<int>(
            label: appTranslation().get('reading_pick_stage'),
            hint: appTranslation().get('reading_select_placeholder'),
            icon: Icons.school_outlined,
            value: state.selectedStage?.id,
            items: [for (final s in state.stages) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: (id) =>
                id == null ? null : cubit.selectStage(state.stages.firstWhere((s) => s.id == id)),
          ),
          if (tracks.isNotEmpty) ...[
            verticalSpace12,
            ConceptMapDropdownField<String>(
              label: appTranslation().get('reading_pick_track'),
              hint: appTranslation().get('reading_select_placeholder'),
              icon: Icons.alt_route_rounded,
              value: state.selectedTrack,
              items: [for (final t in tracks) DropdownMenuItem(value: t, child: Text(t))],
              onChanged: (t) => t == null ? null : cubit.selectTrack(t),
            ),
          ],
          verticalSpace12,
          ConceptMapDropdownField<int>(
            label: appTranslation().get('reading_pick_grade'),
            hint: appTranslation().get('reading_select_placeholder'),
            icon: Icons.class_outlined,
            value: state.selectedGrade?.id,
            items: [for (final g in grades) DropdownMenuItem(value: g.id, child: Text(g.name))],
            onChanged: hasGrade
                ? (id) => id == null ? null : cubit.selectGrade(grades.firstWhere((g) => g.id == id))
                : null,
          ),
          verticalSpace12,
          ConceptMapDropdownField<int>(
            label: appTranslation().get('reading_pick_subject'),
            hint: appTranslation().get('reading_select_placeholder'),
            icon: Icons.menu_book_outlined,
            value: state.selectedSubject?.id,
            items: [for (final s in subjects) DropdownMenuItem(value: s.id, child: Text(s.name))],
            onChanged: hasSubject
                ? (id) => id == null ? null : cubit.selectSubject(subjects.firstWhere((s) => s.id == id))
                : null,
          ),
          verticalSpace12,
          ConceptMapDropdownField<int>(
            label: appTranslation().get('reading_pick_lesson'),
            hint: lessonHint,
            icon: Icons.auto_stories_outlined,
            isLoading: state.isLessonsLoading,
            value: state.selectedLesson?.id,
            items: [for (final l in lessons) DropdownMenuItem(value: l.id, child: Text(l.title))],
            onChanged: canPickLesson
                ? (id) => id == null ? null : cubit.selectLesson(lessons.firstWhere((l) => l.id == id))
                : null,
          ),
        ],
      ),
    );
  }
}

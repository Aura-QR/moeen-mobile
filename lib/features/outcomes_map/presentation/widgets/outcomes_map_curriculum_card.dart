import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_dropdown_field.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/new_outcomes_map_cubit.dart';

/// Cascading curriculum dropdowns for the new map: Stage → (Track) → Grade → Subject.
class OutcomesMapCurriculumCard extends StatelessWidget {
  final NewOutcomesMapState state;

  const OutcomesMapCurriculumCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = NewOutcomesMapCubit.get(context);
    final tracks = state.availableTracks;
    final grades = state.availableGrades;
    final subjects = state.availableSubjects;
    final placeholder = appTranslation().get('outcomes_map_select_placeholder');

    final hasGrade = state.showGrades && grades.isNotEmpty;
    final hasSubject = state.selectedGrade != null && subjects.isNotEmpty;

    return PrimarySectionCard(
      icon: Icons.school_outlined,
      title: appTranslation().get('outcomes_map_curriculum_title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConceptMapDropdownField<int>(
            label: appTranslation().get('outcomes_map_pick_stage'),
            hint: placeholder,
            icon: Icons.school_outlined,
            value: state.selectedStage?.id,
            items: [
              for (final s in state.stages) DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: (id) =>
                id == null ? null : cubit.selectStage(state.stages.firstWhere((s) => s.id == id)),
          ),
          if (tracks.isNotEmpty) ...[
            verticalSpace12,
            ConceptMapDropdownField<String>(
              label: appTranslation().get('outcomes_map_pick_track'),
              hint: placeholder,
              icon: Icons.alt_route_rounded,
              value: state.selectedTrack,
              items: [for (final t in tracks) DropdownMenuItem(value: t, child: Text(t))],
              onChanged: (t) => t == null ? null : cubit.selectTrack(t),
            ),
          ],
          verticalSpace12,
          ConceptMapDropdownField<int>(
            label: appTranslation().get('outcomes_map_pick_grade'),
            hint: placeholder,
            icon: Icons.class_outlined,
            value: state.selectedGrade?.id,
            items: [
              for (final g in grades) DropdownMenuItem(value: g.id, child: Text(g.name)),
            ],
            onChanged: hasGrade
                ? (id) =>
                    id == null ? null : cubit.selectGrade(grades.firstWhere((g) => g.id == id))
                : null,
          ),
          verticalSpace12,
          ConceptMapDropdownField<int>(
            label: appTranslation().get('outcomes_map_pick_subject'),
            hint: state.isLessonsLoading
                ? appTranslation().get('outcomes_map_lessons_loading')
                : placeholder,
            icon: Icons.menu_book_outlined,
            isLoading: state.isLessonsLoading,
            value: state.selectedSubject?.id,
            items: [
              for (final s in subjects) DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: hasSubject
                ? (id) =>
                    id == null ? null : cubit.selectSubject(subjects.firstWhere((s) => s.id == id))
                : null,
          ),
        ],
      ),
    );
  }
}

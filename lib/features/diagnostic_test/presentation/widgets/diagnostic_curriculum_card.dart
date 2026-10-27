import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_dropdown_field.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_cubit.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

class DiagnosticCurriculumCard extends StatelessWidget {
  final DiagnosticCreateState state;

  const DiagnosticCurriculumCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = DiagnosticCreateCubit.get(context);
    final writing = state.step == DiagnosticStep.writing;
    final tracks = state.availableTracks;
    final showGrades = state.selectedStage != null && (tracks.isEmpty || state.selectedTrack != null);
    final source = state.source;

    return PrimarySectionCard(
      icon: Icons.school_outlined,
      title: appTranslation().get('diagnostic_step_subject'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryDropdownField<CurriculumStageModel>(
            label: appTranslation().get('diagnostic_pick_stage'),
            hint: appTranslation().get('diagnostic_select_placeholder'),
            value: state.selectedStage,
            items: state.stages,
            labelOf: (stage) => stage.name,
            enabled: !writing,
            onChanged: (stage) {
              if (stage != null) cubit.selectStage(stage);
            },
          ),
          if (tracks.isNotEmpty) ...[
            verticalSpace12,
            PrimaryDropdownField<String>(
              label: appTranslation().get('diagnostic_pick_track'),
              hint: appTranslation().get('diagnostic_select_placeholder'),
              value: state.selectedTrack,
              items: tracks,
              labelOf: (track) => track,
              enabled: !writing,
              onChanged: (track) {
                if (track != null) cubit.selectTrack(track);
              },
            ),
          ],
          if (showGrades) ...[
            verticalSpace12,
            PrimaryDropdownField<CurriculumGradeModel>(
              label: appTranslation().get('diagnostic_pick_grade'),
              hint: appTranslation().get('diagnostic_select_placeholder'),
              value: state.selectedGrade,
              items: state.availableGrades,
              labelOf: (grade) => grade.name,
              enabled: !writing,
              onChanged: (grade) {
                if (grade != null) cubit.selectGrade(grade);
              },
            ),
          ],
          if (state.selectedGrade != null) ...[
            verticalSpace12,
            PrimaryDropdownField<CurriculumSubjectModel>(
              label: appTranslation().get('diagnostic_pick_subject'),
              hint: appTranslation().get('diagnostic_select_placeholder'),
              value: state.selectedSubject,
              items: state.availableSubjects,
              labelOf: (subject) => subject.name,
              enabled: !writing,
              onChanged: (subject) {
                if (subject != null) cubit.selectSubject(subject);
              },
            ),
          ],
          if (state.isSourceLoading) ...[
            verticalSpace12,
            LinearProgressIndicator(
              color: ColorsManager.primaryColor,
              backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.12),
            ),
          ] else if (source != null) ...[
            verticalSpace12,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.isReadiness
                        ? appTranslation().get('diagnostic_source_readiness')
                        : appTranslation()
                            .get('diagnostic_source_previous')
                            .replaceAll('{subject}', source.subject)
                            .replaceAll('{grade}', source.sourceGrade ?? ''),
                    style: TextStylesManager.medium13.copyWith(color: ColorsManager.primaryColor),
                  ),
                  if (source.lessonsCount == 0) ...[
                    verticalSpace6,
                    Text(
                      appTranslation().get('diagnostic_no_lessons'),
                      style: TextStylesManager.bold12.copyWith(color: ColorsManager.errorColor),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

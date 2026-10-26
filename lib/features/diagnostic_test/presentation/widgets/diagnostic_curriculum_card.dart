import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_cubit.dart';
import 'package:moean/features/diagnostic_test/presentation/widgets/diagnostic_subject_sheet.dart';
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
    final hasSubject = state.selectedSubject != null;

    return PrimarySectionCard(
      icon: Icons.school_outlined,
      title: appTranslation().get('diagnostic_step_subject'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appTranslation().get('diagnostic_pick_stage'),
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
          ),
          verticalSpace8,
          PrimaryChoiceChips<CurriculumStageModel>(
            options: state.stages,
            labelOf: (stage) => stage.name,
            isSelected: (stage) => state.selectedStage?.id == stage.id,
            onTap: (stage) {
              if (!writing) cubit.selectStage(stage);
            },
          ),
          if (tracks.isNotEmpty) ...[
            verticalSpace16,
            Text(
              appTranslation().get('diagnostic_pick_track'),
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace8,
            PrimaryChoiceChips<String>(
              options: tracks,
              labelOf: (track) => track,
              isSelected: (track) => state.selectedTrack == track,
              onTap: (track) {
                if (!writing) cubit.selectTrack(track);
              },
            ),
          ],
          if (showGrades) ...[
            verticalSpace16,
            Text(
              appTranslation().get('diagnostic_pick_grade'),
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace8,
            PrimaryChoiceChips<CurriculumGradeModel>(
              options: state.availableGrades,
              labelOf: (grade) => grade.name,
              isSelected: (grade) => state.selectedGrade?.id == grade.id,
              onTap: (grade) {
                if (!writing) cubit.selectGrade(grade);
              },
            ),
          ],
          if (state.selectedGrade != null) ...[
            verticalSpace16,
            Text(
              appTranslation().get('diagnostic_pick_subject'),
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace8,
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: writing
                  ? null
                  : () async {
                      final picked = await DiagnosticSubjectSheet.show(
                        context,
                        subjects: state.availableSubjects,
                        selected: state.selectedSubject,
                      );
                      if (picked != null) {
                        await cubit.selectSubject(picked);
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: ColorsManager.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasSubject ? ColorsManager.primaryColor : ColorsManager.borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 20,
                      color: hasSubject ? ColorsManager.primaryColor : ColorsManager.secondaryText,
                    ),
                    horizontalSpace10,
                    Expanded(
                      child: Text(
                        hasSubject ? state.selectedSubject!.name : appTranslation().get('diagnostic_select_placeholder'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (hasSubject ? TextStylesManager.bold14 : TextStylesManager.regular14).copyWith(
                          color: hasSubject ? ColorsManager.mainText : ColorsManager.secondaryText,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, color: ColorsManager.mainText),
                  ],
                ),
              ),
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

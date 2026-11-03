import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_filters_model.dart';
import 'package:moean/features/lab/presentation/cubit/lab_library_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_curriculum_grades_row.dart';
import 'package:moean/features/lab/presentation/widgets/lab_curriculum_subjects_row.dart';
import 'package:moean/features/lab/presentation/widgets/lab_filter_pill.dart';
import 'package:moean/features/lab/presentation/widgets/lab_subject_groups_row.dart';

class LabLibraryFiltersBar extends StatelessWidget {
  final LabLibraryState state;

  const LabLibraryFiltersBar({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final filters = state.filters;
    if (filters == null) return const SizedBox.shrink();

    final cubit = LabLibraryCubit.get(context);

    // Active stage
    LabStageModel? activeStage;
    if (state.selectedStageId != null) {
      for (final s in filters.stages) {
        if (s.id == state.selectedStageId) {
          activeStage = s;
          break;
        }
      }
    }

    // Active grade
    LabGradeModel? activeGrade;
    if (activeStage != null && state.selectedGradeId != null) {
      for (final g in activeStage.grades) {
        if (g.id == state.selectedGradeId) {
          activeGrade = g;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabSubjectGroupsRow(
          subjectGroups: filters.subjectGroups,
          selectedGroup: state.selectedSubjectGroup,
        ),
        verticalSpace8,
        if (filters.stages.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                LabFilterPill(
                  label: appTranslation().get('lab_all_stages'),
                  isSelected: state.selectedStageId == null,
                  onTap: () => cubit.setStage(null),
                ),
                ...filters.stages.map((stage) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: LabFilterPill(
                      label: stage.name,
                      isSelected: state.selectedStageId == stage.id,
                      onTap: () => cubit.setStage(stage.id),
                    ),
                  );
                }),
              ],
            ),
          ),
        if (activeStage != null) ...[
          verticalSpace8,
          LabCurriculumGradesRow(
            activeStage: activeStage,
            selectedGradeId: state.selectedGradeId,
          ),
        ],
        if (activeGrade != null) ...[
          verticalSpace8,
          LabCurriculumSubjectsRow(
            activeGrade: activeGrade,
            selectedSubjectId: state.selectedSubjectId,
          ),
        ],
        if (state.hasActiveFilters) ...[
          verticalSpace8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: cubit.clearFilters,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: ColorsManager.errorColor,
                  ),
                  horizontalSpace4,
                  Text(
                    appTranslation().get('lab_clear_filters'),
                    style: TextStylesManager.medium12.copyWith(
                      color: ColorsManager.errorColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

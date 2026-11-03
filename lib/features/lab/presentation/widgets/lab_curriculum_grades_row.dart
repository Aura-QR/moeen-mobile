import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/lab/data/models/lab_filters_model.dart';
import 'package:moean/features/lab/presentation/cubit/lab_library_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_filter_pill.dart';

class LabCurriculumGradesRow extends StatelessWidget {
  final LabStageModel activeStage;
  final int? selectedGradeId;

  const LabCurriculumGradesRow({
    super.key,
    required this.activeStage,
    required this.selectedGradeId,
  });

  @override
  Widget build(BuildContext context) {
    if (activeStage.grades.isEmpty) return const SizedBox.shrink();

    final cubit = LabLibraryCubit.get(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          LabFilterPill(
            label: appTranslation().get('lab_all_grades'),
            isSelected: selectedGradeId == null,
            onTap: () => cubit.setGrade(null),
          ),
          ...activeStage.grades.map((grade) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: LabFilterPill(
                label: grade.name,
                isSelected: selectedGradeId == grade.id,
                onTap: () => cubit.setGrade(grade.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

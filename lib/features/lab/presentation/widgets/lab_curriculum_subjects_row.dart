import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/lab/data/models/lab_filters_model.dart';
import 'package:moean/features/lab/presentation/cubit/lab_library_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_filter_pill.dart';

class LabCurriculumSubjectsRow extends StatelessWidget {
  final LabGradeModel activeGrade;
  final int? selectedSubjectId;

  const LabCurriculumSubjectsRow({
    super.key,
    required this.activeGrade,
    required this.selectedSubjectId,
  });

  @override
  Widget build(BuildContext context) {
    if (activeGrade.subjects.isEmpty) return const SizedBox.shrink();

    final cubit = LabLibraryCubit.get(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          LabFilterPill(
            label: appTranslation().get('lab_all_subjects'),
            isSelected: selectedSubjectId == null,
            onTap: () => cubit.setSubject(null),
          ),
          ...activeGrade.subjects.map((subject) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: LabFilterPill(
                label: subject.name,
                isSelected: selectedSubjectId == subject.id,
                onTap: () => cubit.setSubject(subject.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

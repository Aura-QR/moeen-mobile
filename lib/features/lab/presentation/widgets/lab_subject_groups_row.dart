import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/lab/data/models/lab_filters_model.dart';
import 'package:moean/features/lab/presentation/cubit/lab_library_cubit.dart';
import 'package:moean/features/lab/presentation/widgets/lab_filter_pill.dart';

class LabSubjectGroupsRow extends StatelessWidget {
  final List<LabSubjectGroupModel> subjectGroups;
  final String? selectedGroup;

  const LabSubjectGroupsRow({
    super.key,
    required this.subjectGroups,
    required this.selectedGroup,
  });

  @override
  Widget build(BuildContext context) {
    if (subjectGroups.isEmpty) return const SizedBox.shrink();

    final cubit = LabLibraryCubit.get(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          LabFilterPill(
            label: appTranslation().get('lab_filter_all'),
            isSelected: selectedGroup == null,
            onTap: () => cubit.setSubjectGroup(null),
          ),
          ...subjectGroups.map((group) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: LabFilterPill(
                label: group.name,
                isSelected: selectedGroup == group.key,
                onTap: () => cubit.setSubjectGroup(group.key),
              ),
            );
          }),
        ],
      ),
    );
  }
}

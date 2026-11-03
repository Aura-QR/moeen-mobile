import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/presentation/widgets/lab_sort_chip.dart';

class LabSortSelector extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;

  const LabSortSelector({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          LabSortChip(
            label: appTranslation().get('lab_sort_popular'),
            value: 'popular',
            icon: Icons.trending_up_rounded,
            isSelected: currentSort == 'popular',
            onSelected: onSortChanged,
          ),
          horizontalSpace8,
          LabSortChip(
            label: appTranslation().get('lab_sort_name'),
            value: 'name',
            icon: Icons.sort_by_alpha_rounded,
            isSelected: currentSort == 'name',
            onSelected: onSortChanged,
          ),
        ],
      ),
    );
  }
}

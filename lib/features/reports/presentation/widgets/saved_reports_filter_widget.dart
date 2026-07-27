import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

class SavedReportsFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const SavedReportsFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': appTranslation().get('filter_all_reports'), 'value': 'الكل'},
      {'label': appTranslation().get('report_weekly'), 'value': 'أسبوعي'},
      {'label': appTranslation().get('report_monthly'), 'value': 'شهري'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter['value'];
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _FilterChip(
            label: filter['label']!,
            isSelected: isSelected,
            onTap: () => onFilterChanged(filter['value']!),
          ),
        );
      }).toList(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderColor.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: TextStylesManager.bold14.copyWith(
            color: isSelected ? Colors.white : ColorsManager.mainText,
          ),
        ),
      ),
    );
  }
}

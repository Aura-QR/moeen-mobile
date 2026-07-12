import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ReportTypeSelectorWidget extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const ReportTypeSelectorWidget({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ReportTypeChip(
          label: appTranslation().get('report_weekly'),
          value: 'اسبوعي',
          selectedValue: selectedType,
          onTap: onChanged,
        ),
        horizontalSpace12,
        _ReportTypeChip(
          label: appTranslation().get('report_monthly'),
          value: 'شهري',
          selectedValue: selectedType,
          onTap: onChanged,
        ),
      ],
    );
  }
}

class _ReportTypeChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedValue;
  final ValueChanged<String> onTap;

  const _ReportTypeChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              size: 16,
              color: isSelected ? ColorsManager.white : ColorsManager.placeholder,
            ),
            horizontalSpace6,
            Text(
              label,
              style: TextStylesManager.bold14.copyWith(
                color: isSelected ? ColorsManager.white : ColorsManager.mainText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

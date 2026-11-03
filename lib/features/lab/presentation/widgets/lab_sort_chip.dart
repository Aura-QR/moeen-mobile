import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class LabSortChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  const LabSortChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor
              : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : ColorsManager.borderLightGray,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? ColorsManager.white
                  : ColorsManager.secondaryText,
            ),
            horizontalSpace6,
            Text(
              label,
              style: TextStylesManager.medium12.copyWith(
                color: isSelected
                    ? ColorsManager.white
                    : ColorsManager.mainText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

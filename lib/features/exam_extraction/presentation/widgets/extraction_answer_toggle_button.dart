import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

class ExtractionAnswerToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const ExtractionAnswerToggleButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : ColorsManager.borderLightGray,
          ),
        ),
        alignment: Alignment.center,
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

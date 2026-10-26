import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

class MyExamsFilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MyExamsFilterTab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
          child: Text(
            label,
            style: isSelected
                ? TextStylesManager.bold14.copyWith(color: ColorsManager.white)
                : TextStylesManager.medium14.copyWith(
                    color: ColorsManager.mainText,
                  ),
          ),
        ),
      ),
    );
  }
}

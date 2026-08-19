import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PrivacyTocItemWidget extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const PrivacyTocItemWidget({
    super.key,
    required this.index,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isSelected ? ColorsManager.primaryColor : Colors.transparent;
    final textColor =
        isSelected ? ColorsManager.white : ColorsManager.mainText;
    final iconColor =
        isSelected ? ColorsManager.white : ColorsManager.placeholder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
            horizontalSpace10,
            Expanded(
              child: Text(
                title,
                style: TextStylesManager.bold14.copyWith(
                  color: textColor,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            horizontalSpace8,
            Icon(
              Icons.arrow_back_ios_rounded,
              size: 14,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}

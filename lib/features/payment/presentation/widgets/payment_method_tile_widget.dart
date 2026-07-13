import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PaymentMethodTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodTileWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withValues(alpha: 0.08)
              : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : ColorsManager.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? ColorsManager.primaryColor
                      : ColorsManager.borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsManager.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            horizontalSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStylesManager.medium14.copyWith(
                      color: ColorsManager.textPrimary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  verticalSpace2,
                  Text(
                    subtitle,
                    style: TextStylesManager.regular12.copyWith(
                      color: ColorsManager.secondaryText,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
            horizontalSpace12,
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? ColorsManager.primaryColor
                  : ColorsManager.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

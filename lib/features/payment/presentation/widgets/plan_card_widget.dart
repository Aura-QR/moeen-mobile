import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/payment/data/models/subscription_plan_model.dart';

class PlanCardWidget extends StatelessWidget {
  final SubscriptionPlanModel plan;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCardWidget({
    super.key,
    required this.plan,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              plan.name,
              style: TextStylesManager.medium14.copyWith(
                color: ColorsManager.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  plan.price,
                  style: TextStylesManager.bold14.copyWith(
                    color: isSelected
                        ? ColorsManager.primaryColor
                        : ColorsManager.textPrimary,
                  ),
                ),
                horizontalSpace4,
                Text(
                  'ر.س',
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

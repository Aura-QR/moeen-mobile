import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/data/models/portfolio_roles_model.dart';

class PortfolioRoleOptionWidget extends StatelessWidget {
  final PortfolioRoleModel role;
  final bool isSelected;
  final VoidCallback onTap;

  const PortfolioRoleOptionWidget({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final count = role.itemTitles.length;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withValues(alpha: 0.08)
              : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderLightGray,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? ColorsManager.primaryColor : ColorsManager.secondaryText,
              size: 20,
            ),
            horizontalSpace12,
            Expanded(
              child: Text(
                role.label,
                style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
              ),
            ),
            Text(
              count == 0
                  ? appTranslation().get('portfolio_role_no_items')
                  : appTranslation().get('portfolio_role_items_count').replaceAll('{n}', '$count'),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

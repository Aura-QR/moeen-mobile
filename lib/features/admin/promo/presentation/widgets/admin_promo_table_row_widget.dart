import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/promo/data/models/admin_promo_models.dart';
import 'package:moean/features/admin/promo/presentation/cubit/admin_promo_cubit.dart';

class AdminPromoTableRowWidget extends StatelessWidget {
  final AdminPromoCodeModel promo;
  final VoidCallback onDelete;

  const AdminPromoTableRowWidget({
    super.key,
    required this.promo,
    required this.onDelete,
  });

  String _targetLabel(String target) {
    switch (target) {
      case 'new_users':
        return appTranslation().get('admin_promo_target_new');
      case 'existing_users':
        return appTranslation().get('admin_promo_target_existing');
      default:
        return appTranslation().get('admin_promo_target_all');
    }
  }

  String _valueDisplay(AdminPromoCodeModel p) {
    final valueStr = p.discountValue.truncateToDouble() == p.discountValue
        ? p.discountValue.toInt().toString()
        : p.discountValue.toStringAsFixed(2);
    return p.discountType == 'percentage'
        ? '$valueStr%'
        : '$valueStr ر.س';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Code + Name on start, Status badge + Actions on end
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Code + Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.code,
                      style: TextStylesManager.bold14.copyWith(
                        color: ColorsManager.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    verticalSpace4,
                    Text(
                      promo.name,
                      style: TextStylesManager.regular12.copyWith(
                        color: ColorsManager.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              horizontalSpace8,
              // Status Badge + Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: promo.isActive
                          ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                          : ColorsManager.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      promo.isActive
                          ? appTranslation().get('admin_promo_status_active')
                          : appTranslation().get('admin_promo_status_inactive'),
                      style: TextStylesManager.bold12.copyWith(
                        color: promo.isActive
                            ? const Color(0xFF16A34A)
                            : ColorsManager.errorColor,
                      ),
                    ),
                  ),
                  horizontalSpace8,
                  // Toggle activate/deactivate
                  IconButton(
                    onPressed: () =>
                        AdminPromoCubit.get(context).togglePromoCode(promo),
                    icon: Icon(
                      promo.isActive
                          ? Icons.toggle_on_rounded
                          : Icons.toggle_off_rounded,
                      color: promo.isActive
                          ? ColorsManager.primaryColor
                          : ColorsManager.textSecondary,
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  horizontalSpace8,
                  // Delete
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: ColorsManager.errorColor,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16, thickness: 0.6),
          // Row 2: Info chips (Wrap avoids overflow)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(
                label: _valueDisplay(promo),
                icon: Icons.discount_outlined,
              ),
              _InfoChip(
                label: _targetLabel(promo.userTarget),
                icon: Icons.flag_outlined,
              ),
              _InfoChip(
                label: '${promo.redemptionsCount}/${promo.maxRedemptions ?? '∞'}',
                icon: Icons.people_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsManager.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorsManager.borderColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ColorsManager.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStylesManager.medium12
                .copyWith(color: ColorsManager.textPrimary),
          ),
        ],
      ),
    );
  }
}

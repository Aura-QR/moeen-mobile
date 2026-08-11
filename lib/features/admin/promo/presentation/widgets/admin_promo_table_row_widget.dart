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

  String _typeLabel(String type) {
    return type == 'percentage'
        ? appTranslation().get('admin_promo_type_percentage')
        : appTranslation().get('admin_promo_type_fixed');
  }

  String _valueDisplay(AdminPromoCodeModel p) {
    return p.discountType == 'percentage'
        ? '${p.discountValue.toStringAsFixed(2)}%'
        : '${p.discountValue.toStringAsFixed(2)} ر.س';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        children: [
          // Row 1: Code + Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              // Code + Name
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    promo.code,
                    style: TextStylesManager.bold14.copyWith(
                      color: ColorsManager.primaryColor,
                    ),
                  ),
                  Text(
                    promo.name,
                    style: TextStylesManager.regular12.copyWith(
                      color: ColorsManager.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          verticalSpace10,
          // Row 2: Type + Value + Target + Usage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Delete
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline_rounded,
                        color: ColorsManager.errorColor, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              // Stats
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InfoChip(
                    label: '${promo.redemptionsCount}/${promo.maxRedemptions ?? '∞'}',
                    icon: Icons.people_outline,
                  ),
                  horizontalSpace8,
                  _InfoChip(
                    label: _targetLabel(promo.userTarget),
                    icon: Icons.flag_outlined,
                  ),
                  horizontalSpace8,
                  _InfoChip(
                    label: _valueDisplay(promo),
                    icon: Icons.discount_outlined,
                  ),
                ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStylesManager.medium12
              .copyWith(color: ColorsManager.textPrimary),
        ),
        const SizedBox(width: 3),
        Icon(icon, size: 13, color: ColorsManager.textSecondary),
      ],
    );
  }
}

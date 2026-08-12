import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/referral/data/models/referral_dashboard_model.dart';

class ReferralHistoryItemWidget extends StatelessWidget {
  final ReferralHistoryItemModel item;

  const ReferralHistoryItemWidget({super.key, required this.item});

  Color _statusColor(String status) {
    switch (status) {
      case 'rewarded':
        return const Color(0xFF22C55E);
      case 'qualified':
        return const Color(0xFF3B82F6);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
      case 'expired':
        return ColorsManager.errorColor;
      default:
        return ColorsManager.textSecondary;
    }
  }

  String _statusLabel(String status) {
    final keyMap = {
      'rewarded': 'referral_status_rewarded',
      'qualified': 'referral_status_qualified',
      'pending': 'referral_status_pending',
      'cancelled': 'referral_status_cancelled',
      'expired': 'referral_status_expired',
    };
    return appTranslation().get(keyMap[status] ?? 'referral_status_pending');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ColorsManager.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item.referredName.isNotEmpty
                    ? item.referredName[0].toUpperCase()
                    : '?',
                style: TextStylesManager.bold16.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
            ),
          ),
          horizontalSpace12,
          // Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.referredName,
                style: TextStylesManager.medium14.copyWith(
                  color: ColorsManager.textPrimary,
                ),
              ),
              verticalSpace2,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.registeredAt.length >= 10
                        ? item.registeredAt.substring(0, 10)
                        : item.registeredAt,
                    style: TextStylesManager.regular12.copyWith(
                      color: ColorsManager.textSecondary,
                    ),
                  ),
                  horizontalSpace4,
                  Icon(Icons.person_add_alt_1_outlined,
                      size: 13, color: ColorsManager.textSecondary),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(item.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(item.status),
              style: TextStylesManager.medium12.copyWith(
                color: _statusColor(item.status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

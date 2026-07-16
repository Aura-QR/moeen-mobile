import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/payment/data/models/payment_model.dart';

class PaymentHistoryItemWidget extends StatelessWidget {
  final PaymentModel payment;

  const PaymentHistoryItemWidget({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(payment.status);
    final planName = payment.order?.service?.name ?? '';
    final date = _formatDate(payment.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusInfo.bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusInfo.label,
                  style: TextStylesManager.bold12.copyWith(
                    color: statusInfo.textColor,
                  ),
                ),
              ),
              if (planName.isNotEmpty)
                Flexible(
                  child: Text(
                    planName,
                    style: TextStylesManager.bold14.copyWith(
                      color: ColorsManager.textPrimary,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          verticalSpace10,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.secondaryText,
                ),
              ),
              Text(
                '${payment.amount} ر.س',
                style: TextStylesManager.bold16.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
            ],
          ),
          verticalSpace6,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _methodLabel(payment.paymentMethod),
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.secondaryText,
                ),
              ),
              horizontalSpace6,
              Icon(
                _methodIcon(payment.paymentMethod),
                size: 15,
                color: ColorsManager.secondaryText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'paid':
        return _StatusInfo(
          label: appTranslation().get('pay_status_paid'),
          bgColor: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF15803D),
        );
      case 'processing':
        return _StatusInfo(
          label: appTranslation().get('pay_status_processing'),
          bgColor: const Color(0xFFE0F2FE),
          textColor: const Color(0xFF0369A1),
        );
      case 'waiting_verification':
        return _StatusInfo(
          label: appTranslation().get('pay_status_waiting_verification'),
          bgColor: const Color(0xFFFEF9C3),
          textColor: const Color(0xFF854D0E),
        );
      case 'failed':
        return _StatusInfo(
          label: appTranslation().get('pay_status_failed'),
          bgColor: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFB91C1C),
        );
      case 'rejected':
        return _StatusInfo(
          label: appTranslation().get('pay_status_rejected'),
          bgColor: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFB91C1C),
        );
      case 'cancelled':
        return _StatusInfo(
          label: appTranslation().get('pay_status_cancelled'),
          bgColor: const Color(0xFFF1F5F9),
          textColor: const Color(0xFF64748B),
        );
      default:
        return _StatusInfo(
          label: appTranslation().get('pay_status_pending'),
          bgColor: const Color(0xFFFEF9C3),
          textColor: const Color(0xFF854D0E),
        );
    }
  }

  String _methodLabel(String method) {
    if (method == 'moyasar') {
      return appTranslation().get('pay_method_online');
    }
    return appTranslation().get('pay_method_bank');
  }

  IconData _methodIcon(String method) {
    return method == 'moyasar'
        ? Icons.credit_card_outlined
        : Icons.account_balance_outlined;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _StatusInfo {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _StatusInfo({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });
}

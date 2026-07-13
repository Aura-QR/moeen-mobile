import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class OrderSummaryWidget extends StatelessWidget {
  final String planName;
  final String amount;

  const OrderSummaryWidget({
    super.key,
    required this.planName,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            appTranslation().get('pay_order_summary') ?? '',
            style: TextStylesManager.bold14.copyWith(
              color: ColorsManager.textPrimary,
            ),
          ),
          verticalSpace12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$amount ر.س',
                  style: TextStylesManager.bold14.copyWith(
                    color: const Color(0xFF8B6914),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  planName,
                  style: TextStylesManager.bold16.copyWith(
                    color: ColorsManager.textPrimary,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          verticalSpace12,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.verified_outlined,
                size: 16,
                color: ColorsManager.primaryColor,
              ),
              horizontalSpace6,
              Flexible(
                child: Text(
                  appTranslation().get('pay_server_amount_note') ?? '',
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

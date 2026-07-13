import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class MoyasarHeaderWidget extends StatelessWidget {
  const MoyasarHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appTranslation().get('pay_online_title'),
                style: TextStylesManager.bold20.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
              verticalSpace4,
              Text(
                appTranslation().get('pay_online_subtitle'),
                style: TextStylesManager.medium12.copyWith(
                  color: ColorsManager.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.credit_card_rounded,
            color: ColorsManager.primaryColor,
            size: 32,
          ),
        ),
      ],
    );
  }
}

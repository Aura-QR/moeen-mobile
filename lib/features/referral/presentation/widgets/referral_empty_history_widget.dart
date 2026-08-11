import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ReferralEmptyHistoryWidget extends StatelessWidget {
  const ReferralEmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 56,
            color: ColorsManager.textSecondary.withValues(alpha: 0.4),
          ),
          verticalSpace12,
          Text(
            appTranslation().get('referral_empty_title'),
            style: TextStylesManager.medium14.copyWith(
              color: ColorsManager.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace6,
          Text(
            appTranslation().get('referral_empty_subtitle'),
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

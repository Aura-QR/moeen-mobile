import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';

class ReferralFooterWidget extends StatelessWidget {
  const ReferralFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PrimaryElevatedButton(
              text: appTranslation().get('referral_footer_btn'),
              onPressed: () => context.push(Routes.checkout),
            ),
          ),
          horizontalSpace16,
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  appTranslation().get('referral_footer_title'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.textPrimary,
                  ),
                  textAlign: TextAlign.end,
                ),
                verticalSpace4,
                Text(
                  appTranslation().get('referral_footer_subtitle'),
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/payment/data/models/subscription_current_model.dart';

class ActiveSubscriptionCardWidget extends StatelessWidget {
  final SubscriptionCurrentModel subscription;

  const ActiveSubscriptionCardWidget({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ColorsManager.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: ColorsManager.primaryColor,
                size: 60,
              ),
              verticalSpace16,
              Text(
                appTranslation().get('pay_subscription_active_already'),
                style: TextStylesManager.bold18.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
              verticalSpace10,
              Text(
                subscription.planTitle,
                style: TextStylesManager.bold16.copyWith(
                  color: ColorsManager.textPrimary,
                ),
              ),
              verticalSpace6,
              Text(
                subscription.expirationSubtitle,
                style: TextStylesManager.regular14.copyWith(
                  color: ColorsManager.secondaryText,
                ),
              ),
              verticalSpace24,
              PrimaryElevatedButton(
                text: appTranslation().get('pay_back_btn'),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

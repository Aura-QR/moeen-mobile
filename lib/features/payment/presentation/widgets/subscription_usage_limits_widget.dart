import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class SubscriptionUsageLimitsWidget extends StatelessWidget {
  const SubscriptionUsageLimitsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.speed_outlined,
                  size: 18,
                  color: ColorsManager.primaryColor,
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: Text(
                  appTranslation().get('pay_usage_limits_title'),
                  style: TextStylesManager.bold16.copyWith(
                    color: ColorsManager.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace10,
          Text(
            appTranslation().get('pay_usage_limits_desc'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
          verticalSpace14,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsManager.scheduleBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorsManager.borderColor.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: ColorsManager.primaryColor,
                      ),
                    ),
                    horizontalSpace10,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          appTranslation().get('pay_usage_limits_reset'),
                          style: TextStylesManager.regular12.copyWith(
                            color: ColorsManager.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace10,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.bookmark_added_outlined,
                        size: 16,
                        color: ColorsManager.primaryColor,
                      ),
                    ),
                    horizontalSpace10,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          appTranslation().get('pay_usage_saved_content'),
                          style: TextStylesManager.regular12.copyWith(
                            color: ColorsManager.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace10,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: ColorsManager.primaryColor,
                      ),
                    ),
                    horizontalSpace10,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          appTranslation().get('pay_usage_failed_attempt'),
                          style: TextStylesManager.regular12.copyWith(
                            color: ColorsManager.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

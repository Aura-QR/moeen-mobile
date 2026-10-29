import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class SubscriptionTermsWidget extends StatelessWidget {
  const SubscriptionTermsWidget({super.key});

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
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: ColorsManager.primaryColor,
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: Text(
                  appTranslation().get('pay_sub_details_title'),
                  style: TextStylesManager.bold16.copyWith(
                    color: ColorsManager.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace14,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appTranslation().get('pay_term_sub_title'),
                  style: TextStylesManager.bold13.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
              horizontalSpace8,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    appTranslation().get('pay_term_sub_desc'),
                    style: TextStylesManager.medium13.copyWith(
                      color: ColorsManager.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          verticalSpace8,
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorsManager.scheduleBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorsManager.borderColor.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsManager.primaryColor,
                        ),
                      ),
                    ),
                    horizontalSpace8,
                    Expanded(
                      child: Text(
                        appTranslation().get('pay_term_sub_before_dec'),
                        style: TextStylesManager.regular12.copyWith(
                          color: ColorsManager.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace6,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsManager.primaryColor,
                        ),
                      ),
                    ),
                    horizontalSpace8,
                    Expanded(
                      child: Text(
                        appTranslation().get('pay_term_sub_after_dec'),
                        style: TextStylesManager.regular12.copyWith(
                          color: ColorsManager.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          verticalSpace14,
          Divider(
            height: 1,
            thickness: 1,
            color: ColorsManager.borderColor.withValues(alpha: 0.5),
          ),
          verticalSpace14,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appTranslation().get('pay_year_sub_title'),
                  style: TextStylesManager.bold13.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
              horizontalSpace8,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    appTranslation().get('pay_year_sub_desc'),
                    style: TextStylesManager.medium13.copyWith(
                      color: ColorsManager.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          verticalSpace14,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsManager.isDark
                  ? ColorsManager.surfaceDark
                  : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorsManager.secondaryColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: ColorsManager.secondaryColor,
                ),
                horizontalSpace10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appTranslation().get('pay_early_renewal_title'),
                        style: TextStylesManager.bold13.copyWith(
                          color: ColorsManager.secondaryColor,
                        ),
                      ),
                      verticalSpace4,
                      Text(
                        appTranslation().get('pay_early_renewal_desc'),
                        style: TextStylesManager.regular12.copyWith(
                          color: ColorsManager.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

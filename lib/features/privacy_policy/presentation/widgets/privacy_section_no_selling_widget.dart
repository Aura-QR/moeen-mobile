import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_header_widget.dart';

class PrivacySectionNoSellingWidget extends StatelessWidget {
  const PrivacySectionNoSellingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrivacySectionHeaderWidget(
            title: appTranslation().get('privacy_sec6_title'),
            subtitle: appTranslation().get('privacy_sec6_subtitle'),
            icon: Icons.share_rounded,
            tag: appTranslation().get('privacy_sec6_tag'),
          ),
          verticalSpace16,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.brandGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorsManager.brandGold.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.block_rounded,
                      color: ColorsManager.errorColor,
                      size: 20,
                    ),
                    horizontalSpace8,
                    Expanded(
                      child: Text(
                        appTranslation().get('privacy_sec6_alert_title'),
                        style: TextStylesManager.bold14.copyWith(
                          color: ColorsManager.primaryColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                verticalSpace10,
                Text(
                  appTranslation().get('privacy_sec6_alert_desc'),
                  style: TextStylesManager.regular13.copyWith(
                    color: ColorsManager.mainText,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec6_p1'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.placeholder,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

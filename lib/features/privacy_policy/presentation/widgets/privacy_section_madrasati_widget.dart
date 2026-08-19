import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_madrasati_guarantee_item_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_header_widget.dart';

class PrivacySectionMadrasatiWidget extends StatelessWidget {
  const PrivacySectionMadrasatiWidget({super.key});

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
            title: appTranslation().get('privacy_sec4_title'),
            subtitle: appTranslation().get('privacy_sec4_subtitle'),
            icon: Icons.language_rounded,
            tag: appTranslation().get('privacy_sec4_tag'),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec4_intro'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.mainText,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          verticalSpace16,
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorsManager.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appTranslation().get('privacy_sec4_box_title'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                  textAlign: TextAlign.right,
                ),
                verticalSpace14,
                PrivacyMadrasatiGuaranteeItemWidget(
                  emoji: '🔒',
                  text: appTranslation().get('privacy_sec4_bullet1'),
                ),
                verticalSpace10,
                PrivacyMadrasatiGuaranteeItemWidget(
                  emoji: '🔑',
                  text: appTranslation().get('privacy_sec4_bullet2'),
                ),
                verticalSpace10,
                PrivacyMadrasatiGuaranteeItemWidget(
                  emoji: '🎯',
                  text: appTranslation().get('privacy_sec4_bullet3'),
                ),
                verticalSpace10,
                PrivacyMadrasatiGuaranteeItemWidget(
                  emoji: '✋',
                  text: appTranslation().get('privacy_sec4_bullet4'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

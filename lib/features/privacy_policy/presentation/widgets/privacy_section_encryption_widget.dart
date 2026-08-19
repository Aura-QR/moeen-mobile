import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_encryption_card_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_header_widget.dart';

class PrivacySectionEncryptionWidget extends StatelessWidget {
  const PrivacySectionEncryptionWidget({super.key});

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
            title: appTranslation().get('privacy_sec5_title'),
            subtitle: appTranslation().get('privacy_sec5_subtitle'),
            icon: Icons.lock_outline_rounded,
            tag: appTranslation().get('privacy_sec5_tag'),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec5_intro'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.mainText,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          verticalSpace16,
          PrivacyEncryptionCardWidget(
            title: appTranslation().get('privacy_sec5_card1_title'),
            description: appTranslation().get('privacy_sec5_card1_desc'),
            icon: Icons.lock_outline_rounded,
          ),
          verticalSpace12,
          PrivacyEncryptionCardWidget(
            title: appTranslation().get('privacy_sec5_card2_title'),
            description: appTranslation().get('privacy_sec5_card2_desc'),
            icon: Icons.storage_rounded,
          ),
          verticalSpace12,
          PrivacyEncryptionCardWidget(
            title: appTranslation().get('privacy_sec5_card3_title'),
            description: appTranslation().get('privacy_sec5_card3_desc'),
            icon: Icons.verified_user_outlined,
          ),
        ],
      ),
    );
  }
}

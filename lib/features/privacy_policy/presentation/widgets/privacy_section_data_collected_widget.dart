import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_data_collected_card_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_header_widget.dart';

class PrivacySectionDataCollectedWidget extends StatelessWidget {
  const PrivacySectionDataCollectedWidget({super.key});

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
            title: appTranslation().get('privacy_sec2_title'),
            subtitle: appTranslation().get('privacy_sec2_subtitle'),
            icon: Icons.storage_rounded,
            tag: appTranslation().get('privacy_sec2_tag'),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec2_intro'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.mainText,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          verticalSpace14,
          PrivacyDataCollectedCardWidget(
            title: appTranslation().get('privacy_sec2_card1_title'),
            description: appTranslation().get('privacy_sec2_card1_desc'),
            icon: Icons.person_outline_rounded,
          ),
          verticalSpace10,
          PrivacyDataCollectedCardWidget(
            title: appTranslation().get('privacy_sec2_card2_title'),
            description: appTranslation().get('privacy_sec2_card2_desc'),
            icon: Icons.description_outlined,
          ),
          verticalSpace10,
          PrivacyDataCollectedCardWidget(
            title: appTranslation().get('privacy_sec2_card3_title'),
            description: appTranslation().get('privacy_sec2_card3_desc'),
            icon: Icons.language_rounded,
          ),
          verticalSpace10,
          PrivacyDataCollectedCardWidget(
            title: appTranslation().get('privacy_sec2_card4_title'),
            description: appTranslation().get('privacy_sec2_card4_desc'),
            icon: Icons.memory_rounded,
          ),
          verticalSpace10,
          PrivacyDataCollectedCardWidget(
            title: appTranslation().get('privacy_sec2_card5_title'),
            description: appTranslation().get('privacy_sec2_card5_desc'),
            icon: Icons.drive_folder_upload_outlined,
          ),
          verticalSpace10,
          PrivacyDataCollectedCardWidget(
            title: appTranslation().get('privacy_sec2_card6_title'),
            description: appTranslation().get('privacy_sec2_card6_desc'),
            icon: Icons.groups_2_outlined,
          ),
          verticalSpace10,
          PrivacyDataCollectedCardWidget(
            title: appTranslation().get('privacy_sec2_card7_title'),
            description: appTranslation().get('privacy_sec2_card7_desc'),
            icon: Icons.auto_awesome_outlined,
          ),
          verticalSpace10,
          PrivacyDataCollectedCardWidget(
            title: appTranslation().get('privacy_sec2_card8_title'),
            description: appTranslation().get('privacy_sec2_card8_desc'),
            icon: Icons.insights_rounded,
          ),
          verticalSpace10,
          PrivacyDataCollectedCardWidget(
            title: appTranslation().get('privacy_sec2_card9_title'),
            description: appTranslation().get('privacy_sec2_card9_desc'),
            icon: Icons.quiz_outlined,
          ),
          verticalSpace10,
          PrivacyDataCollectedCardWidget(
            title: appTranslation().get('privacy_sec2_card10_title'),
            description: appTranslation().get('privacy_sec2_card10_desc'),
            icon: Icons.qr_code_2_rounded,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_ai_check_item_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_header_widget.dart';

class PrivacySectionAiUsageWidget extends StatelessWidget {
  const PrivacySectionAiUsageWidget({super.key});

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
            title: appTranslation().get('privacy_sec3_title'),
            subtitle: appTranslation().get('privacy_sec3_subtitle'),
            icon: Icons.memory_rounded,
            tag: appTranslation().get('privacy_sec3_tag'),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec3_intro'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.mainText,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          verticalSpace16,
          PrivacyAiCheckItemWidget(
            text: appTranslation().get('privacy_sec3_check1'),
          ),
          verticalSpace12,
          PrivacyAiCheckItemWidget(
            text: appTranslation().get('privacy_sec3_check2'),
          ),
          verticalSpace12,
          PrivacyAiCheckItemWidget(
            text: appTranslation().get('privacy_sec3_check3'),
          ),
        ],
      ),
    );
  }
}

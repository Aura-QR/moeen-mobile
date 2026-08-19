import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_header_widget.dart';

class PrivacySectionIntroWidget extends StatelessWidget {
  const PrivacySectionIntroWidget({super.key});

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
            title: appTranslation().get('privacy_sec1_title'),
            subtitle: appTranslation().get('privacy_sec1_subtitle'),
            icon: Icons.shield_outlined,
            tag: appTranslation().get('privacy_sec1_tag'),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec1_p1'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.mainText,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          verticalSpace14,
          Text(
            appTranslation().get('privacy_sec1_p2'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.mainText,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          verticalSpace16,
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ColorsManager.primaryColor.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              '💡 ${appTranslation().get('privacy_sec1_highlight')}',
              style: TextStylesManager.bold12.copyWith(
                color: ColorsManager.primaryColor,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

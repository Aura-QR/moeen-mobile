import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_cookie_bullet_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_header_widget.dart';

class PrivacySectionCookiesWidget extends StatelessWidget {
  const PrivacySectionCookiesWidget({super.key});

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
            title: appTranslation().get('privacy_sec8_title'),
            subtitle: appTranslation().get('privacy_sec8_subtitle'),
            icon: Icons.cookie_outlined,
            tag: appTranslation().get('privacy_sec8_tag'),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec8_intro'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.mainText,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          verticalSpace14,
          PrivacyCookieBulletWidget(
            text: appTranslation().get('privacy_sec8_item1'),
          ),
          verticalSpace10,
          PrivacyCookieBulletWidget(
            text: appTranslation().get('privacy_sec8_item2'),
          ),
          verticalSpace10,
          PrivacyCookieBulletWidget(
            text: appTranslation().get('privacy_sec8_item3'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_cookie_bullet_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_header_widget.dart';

class PrivacySectionMeasurementWidget extends StatelessWidget {
  const PrivacySectionMeasurementWidget({super.key});

  Widget _bulletBox(String titleKey, List<String> itemKeys) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appTranslation().get(titleKey),
            style: TextStylesManager.bold14.copyWith(
              color: ColorsManager.primaryColor,
            ),
            textAlign: TextAlign.right,
          ),
          for (final key in itemKeys) ...[
            verticalSpace10,
            PrivacyCookieBulletWidget(text: appTranslation().get(key)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStylesManager.regular13.copyWith(
      color: ColorsManager.mainText,
      height: 1.6,
    );

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
            title: appTranslation().get('privacy_sec9_title'),
            subtitle: appTranslation().get('privacy_sec9_subtitle'),
            icon: Icons.campaign_outlined,
            tag: appTranslation().get('privacy_sec9_tag'),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec9_intro'),
            style: bodyStyle,
            textAlign: TextAlign.right,
          ),
          verticalSpace16,
          _bulletBox('privacy_sec9_pixel_title', [
            'privacy_sec9_pixel_item1',
            'privacy_sec9_pixel_item2',
            'privacy_sec9_pixel_item3',
            'privacy_sec9_pixel_item4',
          ]),
          verticalSpace12,
          _bulletBox('privacy_sec9_server_title', [
            'privacy_sec9_server_item1',
            'privacy_sec9_server_item2',
            'privacy_sec9_server_item3',
          ]),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec9_hashing'),
            style: bodyStyle,
            textAlign: TextAlign.right,
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
                        appTranslation().get('privacy_sec9_never_title'),
                        style: TextStylesManager.bold14.copyWith(
                          color: ColorsManager.primaryColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                for (final key in const [
                  'privacy_sec9_never_item1',
                  'privacy_sec9_never_item2',
                  'privacy_sec9_never_item3',
                  'privacy_sec9_never_item4',
                  'privacy_sec9_never_item5',
                ]) ...[
                  verticalSpace10,
                  PrivacyCookieBulletWidget(text: appTranslation().get(key)),
                ],
              ],
            ),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec9_opt_out'),
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

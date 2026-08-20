import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_header_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacySectionUpdatesContactWidget extends StatelessWidget {
  const PrivacySectionUpdatesContactWidget({super.key});

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (_) {
      try {
        await launchUrl(uri);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = appTranslation().get('privacy_sec9_email');
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
            icon: Icons.mail_outline_rounded,
            tag: appTranslation().get('privacy_sec9_tag'),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec9_p1'),
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
              color: ColorsManager.primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorsManager.primaryColor.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mail_outline_rounded,
                      color: ColorsManager.primaryColor,
                      size: 20,
                    ),
                    horizontalSpace8,
                    Expanded(
                      child: Text(
                        appTranslation().get('privacy_sec9_box_title'),
                        style: TextStylesManager.bold14.copyWith(
                          color: ColorsManager.primaryColor,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                verticalSpace8,
                Text(
                  appTranslation().get('privacy_sec9_box_desc'),
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.placeholder,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.right,
                ),
                verticalSpace16,
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.push(Routes.createTicket),
                      icon: Icon(
                        Icons.mail_outline_rounded,
                        color: ColorsManager.white,
                        size: 18,
                      ),
                      label: Text(
                        appTranslation().get('privacy_sec9_contact_btn'),
                        style: TextStylesManager.bold13.copyWith(
                          color: ColorsManager.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                    ),
                    Material(
                      color: ColorsManager.surfacePrimary,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () => _launchEmail(email),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: ColorsManager.borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: ColorsManager.primaryColor,
                              ),
                              horizontalSpace8,
                              Text(
                                email,
                                style: TextStylesManager.bold13.copyWith(
                                  color: ColorsManager.primaryColor,
                                ),
                              ),
                            ],
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

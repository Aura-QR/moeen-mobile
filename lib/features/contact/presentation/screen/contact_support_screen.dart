import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  Future<void> _launchWhatsApp(String phone) async {
    final Uri appUrl = Uri.parse('whatsapp://send?phone=$phone');
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      final Uri webUrl = Uri.parse('https://wa.me/$phone');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorsManager.mainText),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appTranslation().get('contact_support_title'),
                  style: TextStylesManager.bold24.copyWith(color: ColorsManager.primaryColor, height: 1.4),
                  textAlign: TextAlign.right,
                ),
                verticalSpace12,
                Text(
                  appTranslation().get('contact_support_subtitle'),
                  style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                  textAlign: TextAlign.right,
                ),
                verticalSpace32,
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                    children: [
                      ContactOptionWidget(
                        icon: Icons.chat_bubble_outline,
                        title: appTranslation().get('whatsapp_support_1'),
                        linkText: '966565101406',
                        subtitle: appTranslation().get('fast_communication_support'),
                        onTap: () => _launchWhatsApp('966565101406'),
                      ),
                      ContactOptionWidget(
                        icon: Icons.chat_bubble_outline,
                        title: appTranslation().get('whatsapp_support_2'),
                        linkText: '966567448881',
                        subtitle: appTranslation().get('fast_communication_support'),
                        onTap: () => _launchWhatsApp('966567448881'),
                      ),
                      ContactOptionWidget(
                        icon: Icons.email_outlined,
                        title: appTranslation().get('email_support'),
                        linkText: 'qraura0@gmail.com',
                        subtitle: appTranslation().get('support_email'),
                        onTap: () async {
                          final Uri url = Uri(
                            scheme: 'mailto',
                            path: 'qraura0@gmail.com',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                      ),
                      ContactOptionWidget(
                        icon: Icons.location_on_outlined,
                        title: appTranslation().get('location'),
                        subtitle: appTranslation().get('saudi_arabia'),
                      ),
                      ContactOptionWidget(
                        icon: Icons.access_time,
                        title: appTranslation().get('working_hours'),
                        subtitle: appTranslation().get('working_hours_details'),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.headset_mic_outlined, color: ColorsManager.primaryColor),
                      horizontalSpace12,
                      Expanded(
                        child: Text(
                          appTranslation().get('team_close_to_you'),
                          style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace24,
                PrimaryElevatedButton(
                  text: appTranslation().get('my_past_requests'),
                  onPressed: () {
                    context.push(Routes.myTickets);
                  },
                ),
                verticalSpace24,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactOptionWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? linkText;
  final VoidCallback? onTap;

  const ContactOptionWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.linkText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: ColorsManager.primaryColor, size: 24),
            ),
            verticalSpace12,
            Text(
              title,
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
              textAlign: TextAlign.center,
            ),
            if (linkText != null) ...[
              verticalSpace8,
              Text(
                linkText!,
                style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            verticalSpace8,
            Text(
              subtitle,
              style: TextStylesManager.regular10.copyWith(color: ColorsManager.secondaryText, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

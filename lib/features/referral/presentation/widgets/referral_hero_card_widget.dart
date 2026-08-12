import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralHeroCardWidget extends StatelessWidget {
  final String referralLink;

  const ReferralHeroCardWidget({
    super.key,
    required this.referralLink,
  });

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appTranslation().get('referral_copy_success'),
          textAlign: TextAlign.center,
        ),
        backgroundColor: ColorsManager.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareWhatsapp() async {
    final text = Uri.encodeComponent(
      '${appTranslation().get('referral_screen_title')}\n$referralLink',
    );
    final uri = Uri.parse('https://wa.me/?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            ColorsManager.primaryColor,
            ColorsManager.primaryColor.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    appTranslation().get('referral_screen_badge'),
                    style: TextStylesManager.medium12.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  horizontalSpace6,
                  const Icon(Icons.people_alt_outlined,
                      color: Colors.white, size: 14),
                ],
              ),
            ),
            verticalSpace8,
            // Title
            Text(
              appTranslation().get('referral_screen_title'),
              style: TextStylesManager.bold16.copyWith(
                color: Colors.white,
                height: 1.3,
              ),
              textAlign: TextAlign.end,
            ),
            verticalSpace10,
            // Subtitle
            Text(
              appTranslation().get('referral_screen_subtitle'),
              style: TextStylesManager.regular12.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.3,
              ),
              textAlign: TextAlign.end,
            ),
            verticalSpace10,
            // Link label
            Text(
              appTranslation().get('referral_link_label'),
              style: TextStylesManager.medium12.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            verticalSpace8,
            // Link field
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  // Link text
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        referralLink,
                        style: TextStylesManager.regular12.copyWith(
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ),
                  // Copy button
                  GestureDetector(
                    onTap: () => _copyLink(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded,
                              size: 16, color: ColorsManager.primaryColor),
                          horizontalSpace4,
                          Text(
                            appTranslation().get('referral_copy'),
                            style: TextStylesManager.medium12.copyWith(
                              color: ColorsManager.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace12,
            // WhatsApp share button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _shareWhatsapp,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appTranslation().get('referral_share_whatsapp'),
                        style: TextStylesManager.medium14.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      horizontalSpace8,
                      const Icon(Icons.share_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

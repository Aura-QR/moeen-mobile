import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class VerifyEmailBadgeWidget extends StatelessWidget {
  const VerifyEmailBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorsManager.verifyMailIconBg,
            boxShadow: [
              BoxShadow(
                color: ColorsManager.brandGold.withValues(alpha: 0.2),
                blurRadius: 32,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.mark_email_read_outlined,
              size: 48,
              color: ColorsManager.verifyMailIcon,
            ),
          ),
        ),
        verticalSpace16,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: ColorsManager.verifyMailBadgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                size: 16,
                color: ColorsManager.verifyMailBadgeText,
              ),
              horizontalSpace6,
              Text(
                appTranslation().get('verify_email_badge'),
                style: TextStylesManager.bold12.copyWith(
                  color: ColorsManager.verifyMailBadgeText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

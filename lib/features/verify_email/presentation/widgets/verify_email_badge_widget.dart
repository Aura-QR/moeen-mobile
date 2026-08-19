import 'package:flutter/material.dart';
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
            color: const Color(0xFFFFF8E7),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF5B25A).withValues(alpha: 0.2),
                blurRadius: 32,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.mark_email_read_outlined,
              size: 48,
              color: Color(0xFFC98D14),
            ),
          ),
        ),
        verticalSpace16,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3D6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                size: 16,
                color: Color(0xFFB47D16),
              ),
              horizontalSpace6,
              Text(
                appTranslation().get('verify_email_badge'),
                style: TextStylesManager.bold12.copyWith(
                  color: const Color(0xFFB47D16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

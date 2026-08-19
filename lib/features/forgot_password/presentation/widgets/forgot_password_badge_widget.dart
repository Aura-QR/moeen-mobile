import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ForgotPasswordBadgeWidget extends StatelessWidget {
  const ForgotPasswordBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: ColorsManager.verifyMailBadgeBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsManager.isDark
              ? const Color(0xFF5A481E)
              : const Color(0xFFFDE68A),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.vpn_key_outlined,
            size: 16,
            color: ColorsManager.verifyMailBadgeText,
          ),
          horizontalSpace6,
          Text(
            appTranslation().get('forgot_password_badge'),
            style: TextStylesManager.bold13.copyWith(
              color: ColorsManager.verifyMailBadgeText,
            ),
          ),
        ],
      ),
    );
  }
}

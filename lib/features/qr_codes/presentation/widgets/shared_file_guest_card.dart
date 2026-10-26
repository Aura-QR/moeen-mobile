import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class SharedFileGuestCard extends StatelessWidget {
  const SharedFileGuestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 40,
              color: ColorsManager.primaryColor,
            ),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('qr_login_needed'),
            style: TextStylesManager.bold16.copyWith(
              color: ColorsManager.mainText,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace20,
          PrimaryElevatedButton(
            text: appTranslation().get('qr_login_button'),
            width: 180,
            height: 46,
            onPressed: () => Navigator.pushNamed(context, Routes.login),
          ),
        ],
      ),
    );
  }
}

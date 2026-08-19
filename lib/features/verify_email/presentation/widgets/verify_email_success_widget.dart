import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class VerifyEmailSuccessWidget extends StatelessWidget {
  const VerifyEmailSuccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        verticalSpace20,
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorsManager.verifyBadgeBg,
          ),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorsManager.primaryColor,
                  width: 2.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 22,
                  color: ColorsManager.primaryColor,
                ),
              ),
            ),
          ),
        ),
        verticalSpace20,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: ColorsManager.verifyBadgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: ColorsManager.primaryColor,
              ),
              horizontalSpace6,
              Text(
                appTranslation().get('email_verified_badge'),
                style: TextStylesManager.bold13.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
            ],
          ),
        ),
        verticalSpace16,
        Text(
          appTranslation().get('email_verified_success_title'),
          style: TextStylesManager.bold24.copyWith(
            color: ColorsManager.verifySuccessDark,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace12,
        Text(
          appTranslation().get('email_verified_success_desc'),
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.placeholder,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace32,
        PrimaryElevatedButton(
          text: appTranslation().get('continue_to_platform'),
          height: 52,
          radius: 24,
          backgroundColor: ColorsManager.primaryColor,
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.home,
              (route) => false,
            );
          },
        ),
        verticalSpace12,
        PrimaryElevatedButton(
          text: appTranslation().get('back_to_home'),
          height: 52,
          radius: 24,
          backgroundColor: ColorsManager.surfacePrimary,
          borderSide: BorderSide(
            color: ColorsManager.borderColor,
            width: 1.5,
          ),
          textStyle: TextStylesManager.bold14.copyWith(
            color: ColorsManager.placeholder,
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.home,
              (route) => false,
            );
          },
        ),
        verticalSpace20,
      ],
    );
  }
}

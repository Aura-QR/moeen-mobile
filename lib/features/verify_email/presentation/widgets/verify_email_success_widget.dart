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
        Icon(
          Icons.check_circle_rounded,
          size: 80,
          color: ColorsManager.primaryColor,
        ),
        verticalSpace16,
        Text(
          appTranslation().get('email_verified_success_title'),
          style: TextStylesManager.bold22.copyWith(
            color: const Color(0xFF0A5C49),
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace12,
        Text(
          appTranslation().get('email_verified_success_desc'),
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.placeholder,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace32,
        PrimaryElevatedButton(
          text: appTranslation().get('continue_to_dashboard'),
          height: 52,
          radius: 24,
          backgroundColor: ColorsManager.primaryColor,
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routes.home);
          },
        ),
      ],
    );
  }
}

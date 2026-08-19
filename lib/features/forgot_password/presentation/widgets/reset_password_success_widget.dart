import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class ResetPasswordSuccessWidget extends StatelessWidget {
  const ResetPasswordSuccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 80,
          color: ColorsManager.primaryColor,
        ),
        verticalSpace16,
        Text(
          appTranslation().get('reset_password_success_title'),
          style: TextStylesManager.bold22.copyWith(
            color: ColorsManager.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace12,
        Text(
          appTranslation().get('reset_password_success_subtitle'),
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.placeholder,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace28,
        PrimaryElevatedButton(
          text: appTranslation().get('reset_password_go_to_login'),
          onPressed: () {
            context.pushNamedAndRemoveUntil(Routes.login, (route) => false);
          },
        ),
      ],
    );
  }
}

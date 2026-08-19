import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ForgotPasswordHeaderWidget extends StatelessWidget {
  const ForgotPasswordHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          appTranslation().get('forgot_password_title'),
          style: TextStylesManager.bold26.copyWith(
            color: ColorsManager.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace8,
        Text(
          appTranslation().get('forgot_password_subtitle'),
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.placeholder,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

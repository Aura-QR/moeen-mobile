import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';

class RegisterFooterWidget extends StatelessWidget {
  const RegisterFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(Routes.login),
          child: Text(
            appTranslation().get('login_link'),
            style: TextStylesManager.medium14.copyWith(
              color: ColorsManager.primaryColor,
              decoration: TextDecoration.underline,
              decorationColor: ColorsManager.primaryColor,
            ),
          ),
        ),
        Text(
          appTranslation().get('have_account'),
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.textBody,
          ),
        ),
      ],
    );
  }
}

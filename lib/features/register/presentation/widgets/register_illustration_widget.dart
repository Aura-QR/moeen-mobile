import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class RegisterIllustrationWidget extends StatelessWidget {
  const RegisterIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              AssetsHelper.img2,
              fit: BoxFit.contain,
            ),
          ),
        ),
        horizontalSpace16,
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                appTranslation().get('register_title'),
                style: TextStylesManager.bold26.copyWith(
                  color: ColorsManager.mainText,
                ),
              ),
              verticalSpace8,
              Text(
                appTranslation().get('register_subtitle'),
                style: TextStylesManager.regular14.copyWith(
                  color: ColorsManager.mainText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

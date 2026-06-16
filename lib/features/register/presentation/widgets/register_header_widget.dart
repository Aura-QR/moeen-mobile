import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';

class RegisterHeaderWidget extends StatelessWidget {
  const RegisterHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            AssetsHelper.logo,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        
        
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appTranslation().get('app_name'),
                  style: TextStylesManager.bold22.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
                Text(
                  appTranslation().get('smart_assistant'),
                  style: TextStylesManager.medium14.copyWith(
                    color: ColorsManager.textBody,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

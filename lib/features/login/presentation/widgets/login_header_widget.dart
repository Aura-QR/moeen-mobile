import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    AssetsHelper.logo,
                    width: 55,
                    height: 55,
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
                      style: TextStylesManager.regular10.copyWith(
                        color: ColorsManager.textBody,
                      ),
                    ),
                  ],
                ),
                
              ],
            ),

            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.home_outlined,
                size: 20,
                color: ColorsManager.primaryColor,
              ),
              label: Text(
                appTranslation().get('return_home'),
                style: TextStylesManager.medium14.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

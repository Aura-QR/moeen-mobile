import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class RegisterHeaderWidget extends StatelessWidget {
  const RegisterHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      AssetsHelper.icon,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  horizontalSpace8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appTranslation().get('app_name'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStylesManager.bold22.copyWith(
                            color: ColorsManager.textSecondaryDark,
                          ),
                        ),
                        Text(
                          appTranslation().get('smart_assistant'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStylesManager.medium10.copyWith(
                            color: ColorsManager.textSecondaryDark,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

             

              Text(
                appTranslation().get('register_title'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStylesManager.bold26.copyWith(
                  color: ColorsManager.textSecondaryDark,
                ),
              ),

              verticalSpace8,

              Text(
                appTranslation().get('register_subtitle'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
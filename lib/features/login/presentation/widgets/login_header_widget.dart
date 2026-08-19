import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  AssetsHelper.icon,
                  width: 50,
                  height: 50,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStylesManager.regular10.copyWith(
                        color: ColorsManager.mainText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            context.push(Routes.home);
          },
          icon: Icon(
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
    );
  }
}

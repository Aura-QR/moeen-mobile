import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PrimaryElevatedButton(
 icon: const Icon(Icons.person_add_alt_1_outlined, size: 20,),
            
            text: appTranslation().get('create_account'),
          textStyle: TextStylesManager.bold14.copyWith(
                color: ColorsManager.white,
              ),
 onPressed: (){},
 width: 150,
 
 ),
          Row(
            children: [
            

              Image.asset(
                AssetsHelper.logo,
                width: 45,
                height: 45,
                fit: BoxFit.contain,
              ),
              horizontalSpace6,
                Text(
                appTranslation().get('app_name'),
                style: TextStylesManager.bold20.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
            ],
          ),
          _NotificationButton(),

        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ColorsManager.primaryColor.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: ColorsManager.primaryColor,
            size: 20,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: ColorsManager.secondaryColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorsManager.backgroundColorLight,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class HomeHeroBannerWidget extends StatelessWidget {
  const HomeHeroBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding:  EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    Stack(
  clipBehavior: Clip.none,
  alignment: Alignment.center,
  children: [
    Positioned(
      bottom: 5,
      child: Container(
        width: 100, 
        height: 10, 
        decoration: BoxDecoration(
          color: ColorsManager.goldDark,
          borderRadius: BorderRadius.circular(10), 
        ),
      ),
    ),
    
    Text(
      appTranslation().get('home_hero_title'),
      textAlign: TextAlign.start,
      style: TextStylesManager.bold48.copyWith(
        color: ColorsManager.secondarytext,
      ),
    ),

    Positioned(
      right: -25, 
      top: 20, 
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: ColorsManager.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    ),

    Positioned(
      top: 0,
      left: -20,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: ColorsManager.goldDark,
          shape: BoxShape.circle,
        ),
      ),
    ),
  ],
),
                    verticalSpace20,

                    Text(
                      appTranslation().get('home_hero_subtitle'),
                      textAlign: TextAlign.start,
                      style: TextStylesManager.bold20.copyWith(
                        color:  ColorsManager.secondarytext,
                      ),
                    ),

                    verticalSpace20,

                    Text(
                      appTranslation().get('home_hero_description'),
                      textAlign: TextAlign.start,
                      style: TextStylesManager.medium14.copyWith(
                        color: ColorsManager.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 5,
              child: Image.asset(
                AssetsHelper.img9,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
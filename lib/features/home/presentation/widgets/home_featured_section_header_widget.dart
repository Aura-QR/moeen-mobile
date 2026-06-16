import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class HomeFeaturedSectionHeaderWidget extends StatelessWidget {
  const HomeFeaturedSectionHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
               Icon(
                Icons.auto_awesome_rounded,
                color:  ColorsManager.secondaryColor,
                size: 18,
              ),
              horizontalSpace4,

              Text(
                appTranslation().get('featured_resources'),
                style: TextStylesManager.bold18.copyWith(
                  color: ColorsManager.themeDarkPrimary,
                ),
              ),
              
            ],
          ),
        
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
               
                Text(
                  appTranslation().get('view_all'),
                  style: TextStylesManager.medium14.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
                horizontalSpace4,
                 Icon(
                  Icons.arrow_forward_ios,
                  color: ColorsManager.primaryColor,
                  size: 15,
                ),
              ],
            ),
          ),
          ],
      ),
    );
  }
}

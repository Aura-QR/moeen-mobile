import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class HomeTipOfDayWidget extends StatelessWidget {
  const HomeTipOfDayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
       color: ColorsManager.primaryColor.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appTranslation().get('tip_of_day'),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
                verticalSpace6,
                Text(
                  appTranslation().get('tip_of_day_content'),
                  textAlign: TextAlign.right,
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.textPrimary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          horizontalSpace12,
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child:  Image.asset(AssetsHelper.tips, width: 24, height: 24),
          ),
        ],
      ),
    );
  }
}

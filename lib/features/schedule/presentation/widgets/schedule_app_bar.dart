import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class ScheduleAppBar extends StatelessWidget {
  const ScheduleAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child:  Icon(Icons.arrow_back_ios, color: ColorsManager.primaryColor),
                ),
         Image.asset(
                    AssetsHelper.logo,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                
          Text(
            appTranslation().get('schedule_title'),
            style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.profile);
            },
            child: Icon(Icons.person, color: ColorsManager.primaryColor, size: 28),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';

class ScheduleAppBar extends StatelessWidget {
  const ScheduleAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          Stack(
            alignment: Alignment.topRight,
            children: [
              Icon(Icons.notifications_none, color: ColorsManager.primaryColor, size: 28),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: ColorsManager.statusWarning,
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorsManager.white, width: 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

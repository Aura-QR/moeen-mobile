import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'dart:math' as math; 

class DayTabItem extends StatelessWidget {
  final DayModel day;
  final bool isSelected;
  final VoidCallback onTap;

  const DayTabItem({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none, 
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Positioned(
              bottom: -4, 
              child: Transform.rotate(
                angle: math.pi / 4, 
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor,
                    borderRadius: BorderRadius.circular(3), 
                  ),
                ),
              ),
            ),
            
          Container(
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    appTranslation().get(day.nameKey),
                    style: isSelected
                        ? TextStylesManager.bold14.copyWith(color: ColorsManager.white)
                        : TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                  ),
                ),
                verticalSpace4,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    day.date,
                    style: isSelected
                        ? TextStylesManager.regular12.copyWith(color: ColorsManager.white)
                        : TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
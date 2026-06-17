import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';

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
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appTranslation().get(day.nameKey),
              style: isSelected
                  ? TextStylesManager.bold14.copyWith(color: ColorsManager.white)
                  : TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
            ),
            const SizedBox(height: 4),
            Text(
              day.date,
              style: isSelected
                  ? TextStylesManager.regular12.copyWith(color: ColorsManager.white)
                  : TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

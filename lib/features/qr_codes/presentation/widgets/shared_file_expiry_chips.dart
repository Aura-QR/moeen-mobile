import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class SharedFileExpiryChips extends StatelessWidget {
  final List<int> daysOptions;
  final int selectedDays;
  final ValueChanged<int> onSelected;

  const SharedFileExpiryChips({
    super.key,
    required this.daysOptions,
    required this.selectedDays,
    required this.onSelected,
  });

  String _labelForDays(int days) {
    switch (days) {
      case 7:
        return appTranslation().get('qr_days_7');
      case 30:
        return appTranslation().get('qr_days_30');
      case 90:
        return appTranslation().get('qr_days_90');
      case 365:
        return appTranslation().get('qr_days_365');
      default:
        return '$days يوم';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appTranslation().get('qr_expiry_label'),
          style: TextStylesManager.bold13.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        verticalSpace8,
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: daysOptions.map((days) {
            final isSelected = selectedDays == days;
            return ChoiceChip(
              label: Text(
                _labelForDays(days),
                style: isSelected
                    ? TextStylesManager.bold12.copyWith(color: Colors.white)
                    : TextStylesManager.medium12.copyWith(
                        color: ColorsManager.mainText,
                      ),
              ),
              selected: isSelected,
              selectedColor: ColorsManager.primaryColor,
              backgroundColor: ColorsManager.surfacePrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected
                      ? ColorsManager.primaryColor
                      : ColorsManager.borderLightGray,
                ),
              ),
              onSelected: (_) => onSelected(days),
            );
          }).toList(),
        ),
      ],
    );
  }
}

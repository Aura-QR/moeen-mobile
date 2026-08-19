import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PrivacyDataCollectedCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PrivacyDataCollectedCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: ColorsManager.primaryColor,
                size: 20,
              ),
              horizontalSpace8,
              Expanded(
                child: Text(
                  title,
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          verticalSpace8,
          Text(
            description,
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.placeholder,
              height: 1.5,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

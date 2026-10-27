import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class NafsDisclaimerNote extends StatelessWidget {
  const NafsDisclaimerNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: ColorsManager.primaryColor,
          ),
          horizontalSpace10,
          Expanded(
            child: Text(
              appTranslation().get('nafs_disclaimer_note'),
              style: TextStylesManager.medium12.copyWith(
                color: ColorsManager.mainText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

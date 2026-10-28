import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class TahsiliDisclaimerNote extends StatelessWidget {
  final String? notice;

  const TahsiliDisclaimerNote({
    super.key,
    this.notice,
  });

  @override
  Widget build(BuildContext context) {
    final text = (notice != null && notice!.isNotEmpty)
        ? notice!
        : appTranslation().get('tahsili_notice');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorsManager.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: ColorsManager.primaryColor,
          ),
          horizontalSpace8,
          Expanded(
            child: Text(
              text,
              style: TextStylesManager.medium12.copyWith(
                color: ColorsManager.secondaryText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

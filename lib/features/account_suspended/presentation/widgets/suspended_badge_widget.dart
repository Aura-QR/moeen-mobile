import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class SuspendedBadgeWidget extends StatelessWidget {
  const SuspendedBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: ColorsManager.suspendedBadgeBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsManager.suspendedBadgeBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: ColorsManager.suspendedBadgeText,
          ),
          horizontalSpace6,
          Text(
            appTranslation().get('account_suspended_badge'),
            style: TextStylesManager.bold13.copyWith(
              color: ColorsManager.suspendedBadgeText,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class LabWebviewErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const LabWebviewErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsManager.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: ColorsManager.errorColor,
          ),
          verticalSpace16,
          Text(
            appTranslation().get('lab_load_error'),
            style: TextStylesManager.medium14.copyWith(
              color: ColorsManager.mainText,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace20,
          PrimaryElevatedButton(
            text: appTranslation().get('retry'),
            onPressed: onRetry,
            width: 160,
            height: 44,
            icon: const Icon(Icons.refresh_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

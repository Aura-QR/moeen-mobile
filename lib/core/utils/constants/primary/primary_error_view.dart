import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// Full-screen error with a retry button.
/// [message] is a translation key or an API message.
class PrimaryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PrimaryErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorsManager.errorColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 44, color: ColorsManager.errorColor),
            ),
            verticalSpace16,
            Text(
              appTranslation().get(message),
              textAlign: TextAlign.center,
              style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
            ),
            verticalSpace20,
            PrimaryElevatedButton(
              text: appTranslation().get('retry'),
              onPressed: onRetry,
              width: 180,
              height: 46,
              icon: const Icon(Icons.refresh_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

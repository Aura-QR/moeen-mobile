import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class NafsGeneratingView extends StatelessWidget {
  const NafsGeneratingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primaryColor),
                ),
              ),
            ),
            verticalSpace24,
            Text(
              appTranslation().get('nafs_generating_title'),
              textAlign: TextAlign.center,
              style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace10,
            Text(
              appTranslation().get('nafs_generating_hint'),
              textAlign: TextAlign.center,
              style: TextStylesManager.regular13.copyWith(
                color: ColorsManager.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

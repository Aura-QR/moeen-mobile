import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class TahsiliGeneratingView extends StatelessWidget {
  const TahsiliGeneratingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primaryColor),
                  ),
                ),
              ),
            ),
            verticalSpace20,
            Text(
              appTranslation().get('tahsili_generating_title'),
              style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
              textAlign: TextAlign.center,
            ),
            verticalSpace8,
            Text(
              appTranslation().get('tahsili_generating_hint'),
              style: TextStylesManager.regular13.copyWith(
                color: ColorsManager.secondaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';

class ChoseAppUsageCard extends StatelessWidget {
  const ChoseAppUsageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.extensionUsage),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              ColorsManager.primaryColor.withValues(alpha: 0.12),
              ColorsManager.secondaryColor.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ColorsManager.primaryColor.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // ── Icon Container ────────────────────────────────────────────
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.play_circle_outline_rounded,
                color: ColorsManager.primaryColor,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            // ── Text Column ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appTranslation().get('usage_card_title'),
                    style: TextStylesManager.bold16.copyWith(
                      color: ColorsManager.mainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appTranslation().get('usage_card_subtitle'),
                    style: TextStylesManager.regular13.copyWith(
                      color: ColorsManager.secondaryText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Arrow ─────────────────────────────────────────────────────
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ColorsManager.primaryColor,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

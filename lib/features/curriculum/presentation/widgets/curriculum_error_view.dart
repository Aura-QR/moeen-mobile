import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class CurriculumErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const CurriculumErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Colors.red),
            verticalSpace12,
            Text(message,
                textAlign: TextAlign.center,
                style: TextStylesManager.regular14
                    .copyWith(color: ColorsManager.secondaryText)),
            verticalSpace16,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyPickerView extends StatelessWidget {
  final String? message;
  const EmptyPickerView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 64,
                color: ColorsManager.primaryColor.withValues(alpha: 0.4)),
            verticalSpace16,
            Text(
              message ?? 'اختر المرحلة والصف والمادة لعرض التوزيع',
              textAlign: TextAlign.center,
              style: TextStylesManager.regular14
                  .copyWith(color: ColorsManager.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

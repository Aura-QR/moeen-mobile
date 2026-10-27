import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// Displays an AI error or 429 rate-limit message with a retry button.
class ConceptMapAiErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ConceptMapAiErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.errorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorsManager.errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: ColorsManager.errorColor,
              ),
              horizontalSpace8,
              Expanded(
                child: Text(
                  appTranslation().get(message),
                  style: TextStylesManager.regular13.copyWith(
                    color: ColorsManager.errorColor,
                  ),
                ),
              ),
            ],
          ),
          verticalSpace6,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                appTranslation().get('retry'),
                style: TextStylesManager.bold13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

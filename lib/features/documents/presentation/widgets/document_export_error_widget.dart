import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// A failed export's message with «إعادة المحاولة».
class DocumentExportErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const DocumentExportErrorWidget({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: ColorsManager.errorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: ColorsManager.errorColor, size: 20),
          horizontalSpace8,
          Expanded(
            child: Text(
              appTranslation().get(message),
              style: TextStylesManager.medium13.copyWith(color: ColorsManager.errorColor),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: ColorsManager.errorColor),
            child: Text(appTranslation().get('retry')),
          ),
        ],
      ),
    );
  }
}

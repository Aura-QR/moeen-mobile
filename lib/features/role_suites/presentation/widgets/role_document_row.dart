import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';
import 'package:moean/features/role_suites/presentation/widgets/role_ai_badge.dart';
import 'package:moean/features/role_suites/presentation/widgets/role_sensitive_tag.dart';

/// One document row in a role's category: label, «✨» badge, sensitive tag, and «فتح».
class RoleDocumentRow extends StatelessWidget {
  final RoleDocumentSummary document;
  final bool isOpening;
  final bool isBusy;
  final VoidCallback onOpen;

  const RoleDocumentRow({
    super.key,
    required this.document,
    required this.isOpening,
    required this.isBusy,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      document.label,
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                    ),
                    if (document.ai) const RoleAiBadge(),
                  ],
                ),
                if (document.sensitive) ...[
                  verticalSpace6,
                  const RoleSensitiveTag(),
                ],
                if (document.description.isNotEmpty) ...[
                  verticalSpace4,
                  Text(
                    document.description,
                    style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                  ),
                ],
              ],
            ),
          ),
          horizontalSpace10,
          OutlinedButton(
            onPressed: isBusy ? null : onOpen,
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorsManager.primaryColor,
              side: BorderSide(color: ColorsManager.primaryColor.withValues(alpha: 0.45)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isOpening
                ? ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 16, height: 16),
                    child: CircularProgressIndicator(strokeWidth: 2, color: ColorsManager.primaryColor),
                  )
                : Text(
                    appTranslation().get('role_docs_open'),
                    style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
                  ),
          ),
        ],
      ),
    );
  }
}

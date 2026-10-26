import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';
import 'package:moean/features/role_suites/presentation/widgets/role_document_row.dart';

/// One category section in `/tools/roles/{role}` with its documents.
class RoleCategorySection extends StatelessWidget {
  final RoleCategoryModel category;
  final String? openingDocKey;
  final ValueChanged<String> onOpen;

  const RoleCategorySection({
    super.key,
    required this.category,
    required this.openingDocKey,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (category.label.isNotEmpty) ...[
            Text(
              category.label,
              style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace8,
          ],
          for (final doc in category.documents)
            RoleDocumentRow(
              document: doc,
              isOpening: openingDocKey == doc.key,
              isBusy: openingDocKey != null,
              onOpen: () => onOpen(doc.key),
            ),
        ],
      ),
    );
  }
}

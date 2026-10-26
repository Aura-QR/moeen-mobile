import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/document_tools.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';

/// A Hader document tagged with the element, with «فتح» and «نقل».
class PerformanceDocumentTile extends StatelessWidget {
  final PerformanceDocumentModel document;
  final VoidCallback onOpen;
  final VoidCallback onMove;

  const PerformanceDocumentTile({super.key, required this.document, required this.onOpen, required this.onMove});

  @override
  Widget build(BuildContext context) {
    final createdAt = document.createdAt;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 4, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        children: [
          Icon(
            documentToolFor(document.type)?.icon ?? Icons.description_outlined,
            color: ColorsManager.primaryColor,
          ),
          horizontalSpace10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
                ),
                Text(
                  [
                    appTranslation().get(DocumentTypes.labelKey(document.type)),
                    if (createdAt != null) isoDate(createdAt.toLocal()),
                  ].join(' · '),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onOpen, child: Text(appTranslation().get('performance_open_document'))),
          TextButton(onPressed: onMove, child: Text(appTranslation().get('performance_move_document'))),
        ],
      ),
    );
  }
}

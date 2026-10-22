import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/document_tools.dart';
import 'package:moean/features/documents/presentation/widgets/document_status_badge.dart';

enum DocumentCardAction { duplicate, delete }

/// A row in «مستنداتي»: title, type, status and last edit, with a menu.
class DocumentCardWidget extends StatelessWidget {
  final DocumentModel document;
  final bool isBusy;
  final VoidCallback onTap;
  final ValueChanged<DocumentCardAction> onAction;

  const DocumentCardWidget({
    super.key,
    required this.document,
    required this.isBusy,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final updatedAt = document.updatedAt;
    return Material(
      color: ColorsManager.surfacePrimary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 4, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorsManager.borderLightGray),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  documentToolFor(document.type)?.icon ?? Icons.description_outlined,
                  color: ColorsManager.primaryColor,
                ),
              ),
              horizontalSpace12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                    ),
                    verticalSpace6,
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          appTranslation().get(DocumentTypes.labelKey(document.type)),
                          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                        ),
                        DocumentStatusBadge(isFinal: document.isFinal),
                        if (updatedAt != null)
                          Text(
                            appTranslation().get('document_last_edited').replaceAll('{date}', isoDate(updatedAt.toLocal())),
                            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isBusy)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                PopupMenuButton<DocumentCardAction>(
                  onSelected: onAction,
                  icon: Icon(Icons.more_vert_rounded, color: ColorsManager.secondaryText),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: DocumentCardAction.duplicate,
                      child: Text(appTranslation().get('document_duplicate')),
                    ),
                    PopupMenuItem(
                      value: DocumentCardAction.delete,
                      child: Text(
                        appTranslation().get('delete'),
                        style: const TextStyle(color: ColorsManager.errorColor),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

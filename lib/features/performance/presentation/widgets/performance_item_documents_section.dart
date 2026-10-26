import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/document_tools.dart';
import 'package:moean/features/documents/presentation/widgets/document_element_sheet.dart';
import 'package:moean/features/performance/presentation/cubit/performance_cubit.dart';
import 'package:moean/features/performance/presentation/widgets/performance_document_tile.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';

/// «من مستنداتك في حضّر»: documents tagged with the element, counted
/// without being attached.
class PerformanceItemDocumentsSection extends StatelessWidget {
  final PerformanceItemModel item;

  const PerformanceItemDocumentsSection({super.key, required this.item});

  Future<void> _open(BuildContext context, PerformanceDocumentModel document) async {
    final tool = documentToolFor(document.type);
    if (tool == null) {
      showPrimarySnackBar(context, 'document_type_unsupported');
      return;
    }
    final cubit = PerformanceCubit.get(context);
    await Navigator.pushNamed(context, tool.route, arguments: document.id);
    cubit.refresh();
  }

  Future<void> _move(BuildContext context, PerformanceDocumentModel document) async {
    final cubit = PerformanceCubit.get(context);
    final changed = await DocumentElementSheet.showForDocument(context, documentId: document.id, element: item.itemKey);
    if (changed) cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.folder_copy_outlined,
      title: appTranslation().get('performance_hader_documents'),
      child: item.documents.isEmpty
          ? Text(
              appTranslation().get('performance_no_documents'),
              style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
            )
          : Column(
              children: [
                for (final document in item.documents) ...[
                  PerformanceDocumentTile(
                    document: document,
                    onOpen: () => _open(context, document),
                    onMove: () => _move(context, document),
                  ),
                  verticalSpace8,
                ],
              ],
            ),
    );
  }
}

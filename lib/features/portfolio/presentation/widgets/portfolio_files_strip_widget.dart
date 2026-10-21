import 'package:flutter/material.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_confirm_dialog.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_file_thumbnail_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// The item's evidence as a reorderable row of thumbnails.
class PortfolioFilesStripWidget extends StatelessWidget {
  final PortfolioItemModel item;

  const PortfolioFilesStripWidget({super.key, required this.item});

  Future<void> _delete(BuildContext context, PortfolioFileModel file) async {
    final cubit = PortfolioEditorCubit.get(context);
    final confirmed = await showPortfolioConfirmDialog(
      context,
      titleKey: 'portfolio_delete_evidence',
      messageKey: 'portfolio_delete_evidence_confirm',
    );
    if (confirmed) cubit.deleteFile(item.id, file.id);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PortfolioEditorCubit.get(context);
    return SizedBox(
      height: 96,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: false,
        itemCount: item.files.length,
        onReorderItem: (oldIndex, newIndex) => cubit.reorderFiles(item, oldIndex, newIndex),
        itemBuilder: (context, index) {
          final file = item.files[index];
          return PortfolioFileThumbnailWidget(
            key: ValueKey(file.id),
            file: file,
            index: index,
            onOpen: () => launchUrl(Uri.parse(file.url), mode: LaunchMode.externalApplication),
            onDelete: () => _delete(context, file),
            onImageError: cubit.refresh,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';

/// One piece of evidence. Tap opens it, long-press deletes it, and the
/// handle in the corner drags it to a new position.
class PortfolioFileThumbnailWidget extends StatelessWidget {
  final PortfolioFileModel file;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  /// Signed URLs expire after 60 minutes; a failed image reloads the portfolio.
  final VoidCallback onImageError;

  const PortfolioFileThumbnailWidget({
    super.key,
    required this.file,
    required this.index,
    required this.onOpen,
    required this.onDelete,
    required this.onImageError,
  });

  @override
  Widget build(BuildContext context) {
    final icon = file.isLink ? Icons.link_rounded : Icons.picture_as_pdf_rounded;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: GestureDetector(
        onTap: onOpen,
        onLongPress: onDelete,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 96,
            color: ColorsManager.primaryColor.withValues(alpha: 0.06),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (file.isImage)
                  Image.network(
                    file.url,
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    errorBuilder: (_, _, _) => IconButton(
                      onPressed: onImageError,
                      icon: Icon(Icons.refresh_rounded, color: ColorsManager.secondaryText),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: file.isLink ? ColorsManager.statusWaiting : ColorsManager.errorColor, size: 30),
                        Text(
                          file.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStylesManager.regular10.copyWith(color: ColorsManager.mainText),
                        ),
                      ],
                    ),
                  ),
                PositionedDirectional(
                  top: 4,
                  start: 4,
                  child: ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: ColorsManager.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.drag_indicator_rounded, size: 16, color: ColorsManager.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

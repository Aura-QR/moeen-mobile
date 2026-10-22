import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/documents/data/models/document_model.dart';

/// A photo in «الشواهد», with a remove button.
class DocumentImageTile extends StatelessWidget {
  final DocumentImageModel image;
  final VoidCallback onRemove;

  const DocumentImageTile({super.key, required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final bytes = image.bytes;
    final url = image.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: ColorsManager.primaryColor.withValues(alpha: 0.06)),
          if (bytes != null)
            Image.memory(bytes, fit: BoxFit.cover, cacheWidth: 400)
          else if (url != null && url.isNotEmpty)
            Image.network(
              url,
              fit: BoxFit.cover,
              cacheWidth: 400,
              errorBuilder: (_, _, _) => Icon(Icons.broken_image_outlined, color: ColorsManager.secondaryText),
            ),
          PositionedDirectional(
            top: 6,
            end: 6,
            child: Material(
              color: ColorsManager.black.withValues(alpha: 0.5),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.close_rounded, size: 16, color: ColorsManager.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

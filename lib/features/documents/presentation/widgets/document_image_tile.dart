import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/widgets/document_image_preview.dart';

/// A photo in «الشواهد», with a remove button.
class DocumentImageTile extends StatelessWidget {
  final DocumentImageModel image;
  final VoidCallback onRemove;

  const DocumentImageTile({super.key, required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DocumentImagePreview(image: image),
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

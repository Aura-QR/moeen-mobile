import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/documents/data/models/document_model.dart';

/// A document photo filling its box: the picked bytes, or the signed URL.
class DocumentImagePreview extends StatelessWidget {
  final DocumentImageModel image;

  const DocumentImagePreview({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    final bytes = image.bytes;
    final url = image.url;
    return Stack(
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
      ],
    );
  }
}

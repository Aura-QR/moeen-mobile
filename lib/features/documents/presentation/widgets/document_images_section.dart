import 'package:flutter/material.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_file_source_sheet.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_upload_rules.dart';
import 'package:moean/features/documents/presentation/widgets/document_add_image_tile.dart';
import 'package:moean/features/documents/presentation/widgets/document_image_tile.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';

/// «الشواهد»: up to [maxImages] photos from the camera or the gallery.
class DocumentImagesSection extends StatelessWidget {
  final List<DocumentImageModel> images;
  final bool isUploading;
  final ValueChanged<DeviceFileSource> onPick;
  final ValueChanged<int> onRemove;
  final int maxImages;

  const DocumentImagesSection({
    super.key,
    required this.images,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
    this.maxImages = DocumentUploadRules.maxImagesPerDocument,
  });

  Future<void> _add(BuildContext context) async {
    final source = await PrimaryFileSourceSheet.show(
      context,
      titleKey: 'document_add_photo',
      sources: const [DeviceFileSource.camera, DeviceFileSource.gallery],
    );
    if (source != null) onPick(source);
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = images.length < maxImages;
    return PrimarySectionCard(
      icon: Icons.photo_library_outlined,
      title: appTranslation().get('document_section_images'),
      trailing: Text(
        '${images.length}/$maxImages',
        style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          for (var i = 0; i < images.length; i++)
            DocumentImageTile(
              key: ValueKey(images[i].storagePath),
              image: images[i],
              onRemove: () => onRemove(i),
            ),
          if (canAdd) DocumentAddImageTile(isUploading: isUploading, onTap: () => _add(context)),
        ],
      ),
    );
  }
}

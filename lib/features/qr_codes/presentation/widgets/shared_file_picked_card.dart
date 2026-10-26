import 'package:flutter/material.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/data/utils/format_bytes.dart';

class SharedFilePickedCard extends StatelessWidget {
  final DevicePickedPath file;
  final VoidCallback onChange;

  const SharedFilePickedCard({
    super.key,
    required this.file,
    required this.onChange,
  });

  IconData _iconForExt(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'gif':
      case 'heic':
        return Icons.image_outlined;
      case 'mp4':
      case 'mov':
      case 'webm':
        return Icons.video_file_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart_outlined;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconForExt(file.extension),
              color: ColorsManager.primaryColor,
              size: 24,
            ),
          ),
          horizontalSpace12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.name,
                  style: TextStylesManager.bold13.copyWith(
                    color: ColorsManager.mainText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpace4,
                Text(
                  formatBytes(file.byteSize),
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.sync,
              color: ColorsManager.primaryColor,
              size: 20,
            ),
            onPressed: onChange,
          ),
        ],
      ),
    );
  }
}

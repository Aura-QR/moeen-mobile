import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_page_model.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_cubit.dart';

class ExtractionPdfTile extends StatelessWidget {
  final ExtractionPageModel page;

  const ExtractionPdfTile({
    super.key,
    required this.page,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorsManager.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: ColorsManager.errorColor,
              size: 28,
            ),
          ),
          horizontalSpace12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.name,
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.mainText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpace4,
                Text(
                  _formatSize(page.byteSize),
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: ColorsManager.errorColor,
              size: 20,
            ),
            onPressed: () => ExtractionPagesCubit.get(context).removePage(0),
          ),
        ],
      ),
    );
  }
}

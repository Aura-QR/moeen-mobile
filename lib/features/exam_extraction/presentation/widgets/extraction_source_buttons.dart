import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_cubit.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_source_button_item.dart';

class ExtractionSourceButtons extends StatelessWidget {
  const ExtractionSourceButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ExtractionSourceButtonItem(
            icon: Icons.camera_alt_outlined,
            label: appTranslation().get('exam_extract_camera'),
            onTap: () => ExtractionPagesCubit.get(context).addFromCamera(),
          ),
        ),
        horizontalSpace8,
        Expanded(
          child: ExtractionSourceButtonItem(
            icon: Icons.photo_library_outlined,
            label: appTranslation().get('exam_extract_gallery'),
            onTap: () => ExtractionPagesCubit.get(context).addFromGallery(),
          ),
        ),
        horizontalSpace8,
        Expanded(
          child: ExtractionSourceButtonItem(
            icon: Icons.picture_as_pdf_outlined,
            label: appTranslation().get('exam_extract_pdf'),
            onTap: () => ExtractionPagesCubit.get(context).pickPdf(),
          ),
        ),
      ],
    );
  }
}

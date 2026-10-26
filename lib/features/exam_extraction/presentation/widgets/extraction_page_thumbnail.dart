import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_page_model.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_cubit.dart';

class ExtractionPageThumbnail extends StatelessWidget {
  final int index;
  final ExtractionPageModel page;

  const ExtractionPageThumbnail({
    super.key,
    required this.index,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorsManager.borderLightGray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              page.bytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => ExtractionPagesCubit.get(context).removePage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ColorsManager.errorColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

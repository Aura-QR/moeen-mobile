import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

class CurriculumPdfFooter extends StatelessWidget {
  final int pageNumber;
  final int totalPages;

  const CurriculumPdfFooter({
    super.key,
    required this.pageNumber,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'منصة مُعين التعليمية',
            style: TextStylesManager.regular10.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
          Text(
            'صفحة $pageNumber من $totalPages',
            style: TextStylesManager.bold10.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

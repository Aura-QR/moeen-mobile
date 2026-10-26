import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/performance/presentation/performance_format.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';

/// The portfolio title, the self-rating summary and «تصدير».
class PerformanceHeaderCard extends StatelessWidget {
  final PerformanceModel performance;
  final VoidCallback onExport;

  const PerformanceHeaderCard({super.key, required this.performance, required this.onExport});

  @override
  Widget build(BuildContext context) {
    final rating = performance.rating;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(performance.title, style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText)),
          if (performance.roleLabel.isNotEmpty) ...[
            verticalSpace4,
            Text(
              performance.roleLabel,
              style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
            ),
          ],
          if (rating.rated > 0 && rating.average != null) ...[
            verticalSpace14,
            Text(
              appTranslation()
                  .get('performance_rating_summary')
                  .replaceAll('{avg}', formatScore(rating.average!))
                  .replaceAll('{max}', '${performance.ratingMax}')
                  .replaceAll('{points}', formatScore(rating.points))
                  .replaceAll('{out_of}', '${rating.outOf}'),
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
            ),
            if (rating.rated < rating.elements) ...[
              verticalSpace4,
              Text(
                appTranslation()
                    .get('performance_rated_count')
                    .replaceAll('{rated}', '${rating.rated}')
                    .replaceAll('{elements}', '${rating.elements}'),
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
              ),
            ],
          ],
          verticalSpace16,
          PrimaryElevatedButton(
            text: appTranslation().get('performance_export'),
            icon: const Icon(Icons.file_download_outlined),
            onPressed: onExport,
          ),
        ],
      ),
    );
  }
}

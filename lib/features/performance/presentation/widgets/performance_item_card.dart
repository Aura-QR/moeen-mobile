import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/document_element_label.dart';
import 'package:moean/features/performance/presentation/widgets/performance_rating_stars.dart';
import 'package:moean/features/performance/presentation/widgets/performance_state_chip.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';

/// One element: number, title, weight, evidence state and rating. Dimmed
/// when it's left out of the file.
class PerformanceItemCard extends StatelessWidget {
  final PerformanceItemModel item;
  final int ratingMax;
  final VoidCallback onTap;

  const PerformanceItemCard({super.key, required this.item, required this.ratingMax, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: item.included ? 1 : 0.55,
      child: Material(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorsManager.borderLightGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.number != null) ...[
                      Text(
                        elementNumberLabel(item.number!),
                        style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                      ),
                      horizontalSpace8,
                    ],
                    if (item.weight != null)
                      Text(
                        appTranslation().get('performance_weight').replaceAll('{n}', '${item.weight}'),
                        style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                      ),
                    const Spacer(),
                    if (!item.included)
                      Text(
                        appTranslation().get('performance_excluded'),
                        style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                      ),
                    Icon(Icons.chevron_left_rounded, color: ColorsManager.secondaryText),
                  ],
                ),
                verticalSpace6,
                Text(item.title, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                verticalSpace10,
                Row(
                  children: [
                    PerformanceStateChip(state: item.state, count: item.evidenceCount),
                    const Spacer(),
                    if (item.isRatable) PerformanceRatingStars(rating: item.selfRating, max: ratingMax, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

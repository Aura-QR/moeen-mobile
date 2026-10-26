import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/performance/presentation/cubit/performance_cubit.dart';
import 'package:moean/features/performance/presentation/widgets/performance_rating_stars.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';

/// «التقييم الذاتي»: tap a star to rate, tap it again to clear.
class PerformanceItemRatingCard extends StatelessWidget {
  final PerformanceItemModel item;
  final int ratingMax;
  final bool isSaving;

  const PerformanceItemRatingCard({super.key, required this.item, required this.ratingMax, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.star_outline_rounded,
      title: appTranslation().get('performance_self_rating'),
      trailing: isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : null,
      child: Column(
        children: [
          PerformanceRatingStars(
            rating: item.selfRating,
            max: ratingMax,
            size: 34,
            onRate: isSaving ? null : (value) => PerformanceCubit.get(context).rate(item, value),
          ),
          Text(
            appTranslation().get('performance_self_rating_hint'),
            textAlign: TextAlign.center,
            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
          ),
        ],
      ),
    );
  }
}

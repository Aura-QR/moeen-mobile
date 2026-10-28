import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/tahsili/data/models/tahsili_models.dart';
import 'package:moean/features/tahsili/presentation/cubit/tahsili_cubit.dart';

class TahsiliQuestionsCountSlider extends StatelessWidget {
  final int count;
  final TahsiliLimits limits;

  const TahsiliQuestionsCountSlider({
    super.key,
    required this.count,
    required this.limits,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = TahsiliCubit.get(context);
    final minVal = limits.min.toDouble();
    final maxVal = limits.max > limits.min ? limits.max.toDouble() : (limits.min + 1).toDouble();
    final currentVal = count.toDouble().clamp(minVal, maxVal);

    return PrimarySectionCard(
      icon: Icons.tune_rounded,
      title: appTranslation().get('tahsili_questions_count'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appTranslation().get('tahsili_questions_count_label'),
                style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count ${appTranslation().get('nafs_questions_unit')}',
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                ),
              ),
            ],
          ),
          verticalSpace8,
          Slider(
            value: currentVal,
            min: minVal,
            max: maxVal,
            divisions: (maxVal - minVal).toInt() > 0 ? (maxVal - minVal).toInt() : 1,
            activeColor: ColorsManager.primaryColor,
            inactiveColor: ColorsManager.borderLightGray,
            onChanged: (val) => cubit.setQuestionsCount(val.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${limits.min}',
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
              ),
              Text(
                '${limits.max}',
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

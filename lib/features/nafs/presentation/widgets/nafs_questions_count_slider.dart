import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_cubit.dart';

class NafsQuestionsCountSlider extends StatelessWidget {
  final int count;
  final bool isRealExam;

  const NafsQuestionsCountSlider({
    super.key,
    required this.count,
    required this.isRealExam,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = NafsCubit.get(context);

    return PrimarySectionCard(
      icon: Icons.format_list_numbered_rounded,
      title: appTranslation().get('nafs_questions_count'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isRealExam
                  ? ColorsManager.primaryColor.withValues(alpha: 0.08)
                  : ColorsManager.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRealExam
                    ? ColorsManager.primaryColor.withValues(alpha: 0.4)
                    : ColorsManager.borderLightGray,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 20,
                  color: isRealExam ? ColorsManager.primaryColor : ColorsManager.secondaryText,
                ),
                horizontalSpace10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appTranslation().get('nafs_like_real_exam'),
                        style: TextStylesManager.bold13.copyWith(
                          color: isRealExam ? ColorsManager.primaryColor : ColorsManager.mainText,
                        ),
                      ),
                      verticalSpace2,
                      Text(
                        appTranslation().get('nafs_like_real_exam_hint'),
                        style: TextStylesManager.regular12.copyWith(
                          color: ColorsManager.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isRealExam,
                  activeTrackColor: ColorsManager.primaryColor.withValues(alpha: 0.5),
                  onChanged: cubit.toggleRealExam,
                ),
              ],
            ),
          ),
          verticalSpace12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appTranslation()
                    .get('nafs_questions_count_label')
                    .replaceAll('{n}', '$count'),
                style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: count > 5 ? ColorsManager.primaryColor : ColorsManager.secondaryText,
                    onPressed: count > 5 ? () => cubit.setQuestionsCount(count - 1) : null,
                  ),
                  Text(
                    '$count',
                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: count < 25 ? ColorsManager.primaryColor : ColorsManager.secondaryText,
                    onPressed: count < 25 ? () => cubit.setQuestionsCount(count + 1) : null,
                  ),
                ],
              ),
            ],
          ),
          Slider(
            value: count.toDouble(),
            min: 5,
            max: 25,
            divisions: 20,
            activeColor: ColorsManager.primaryColor,
            inactiveColor: ColorsManager.borderLightGray,
            onChanged: (val) => cubit.setQuestionsCount(val.round()),
          ),
        ],
      ),
    );
  }
}

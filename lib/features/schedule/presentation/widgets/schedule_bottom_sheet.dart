import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/widgets/status_strip.dart';
import 'package:moean/features/schedule/presentation/widgets/action_button_widget.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_cubit.dart';

class ScheduleBottomSheet extends StatelessWidget {
  final ClassModel classModel;

  const ScheduleBottomSheet({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ColorsManager.borderLightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          verticalSpace24,
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorsManager.brandMint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.menu_book,
                  color: ColorsManager.primaryColor,
                  size: 32,
                ),
              ),
              horizontalSpace16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (classModel.lessonTitle != null)
                      Text(
                        classModel.lessonTitle!,
                        style: TextStylesManager.bold14
                            .copyWith(color: ColorsManager.mainText),
                      ),
                    verticalSpace8,
                    Row(
                      children: [
                        Text(
                          classModel.classroomId,
                          style: TextStylesManager.regular12
                              .copyWith(color: ColorsManager.secondaryText),
                        ),
                        const Spacer(),
                        StatusIcon(status: classModel.status, size: 24),
                      ],
                    ),
                  ],
                ),
              ),
              horizontalSpace16,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    appTranslation().get(classModel.periodKey),
                    style: TextStylesManager.regular12
                        .copyWith(color: ColorsManager.primaryColor),
                  ),
                  Text(
                    '${appTranslation().get('period_label')} ${classModel.periodNumber}',
                    style: TextStylesManager.bold16
                        .copyWith(color: ColorsManager.mainText),
                  ),
                  Row(
                    children: [
                      Text(
                        classModel.classroomId,
                        style: TextStylesManager.regular12
                            .copyWith(color: ColorsManager.secondaryText),
                      ),
                      horizontalSpace4,
                      Icon(
                        Icons.school,
                        size: 14,
                        color: ColorsManager.secondaryText,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          verticalSpace24,
          Text(
            appTranslation().get('action_choose_prep'),
            style: TextStylesManager.regular14
                .copyWith(color: ColorsManager.mainText),
          ),
          verticalSpace16,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionButtonWidget(
                  titleKey: 'action_enrichment',
                  icon: Icons.star_border,
                  color: ColorsManager.brandGold,
                  onTap: () {
                    ScheduleCubit.get(context).prepareLesson(
                      classModel: classModel,
                      selectedModules: ['enrichment'],
                    );
                    Navigator.pop(context);
                  },
                ),
                horizontalSpace8,
                ActionButtonWidget(
                  titleKey: 'action_exam',
                  icon: Icons.assignment_outlined,
                  color: ColorsManager.statusSuccess,
                  onTap: () {
                    ScheduleCubit.get(context).prepareLesson(
                      classModel: classModel,
                      selectedModules: ['exam'],
                    );
                    Navigator.pop(context);
                  },
                ),
                horizontalSpace8,
                ActionButtonWidget(
                  titleKey: 'action_worksheet',
                  icon: Icons.description_outlined,
                  color: ColorsManager.statusWaiting,
                  onTap: () {
                    ScheduleCubit.get(context).prepareLesson(
                      classModel: classModel,
                      selectedModules: ['assignment'], // or homework, mapped based on API supported modules
                    );
                    Navigator.pop(context);
                  },
                ),
                horizontalSpace8,
                ActionButtonWidget(
                  titleKey: 'action_presentation',
                  icon: Icons.personal_video,
                  color: ColorsManager.primaryColor,
                  isOutlined: true,
                  onTap: () {
                    ScheduleCubit.get(context).prepareLesson(
                      classModel: classModel,
                      selectedModules: [], // maybe not supported directly by API but we trigger it
                    );
                    Navigator.pop(context);
                  },
                ),
                horizontalSpace8,
                ActionButtonWidget(
                  titleKey: 'action_prepare_moean',
                  icon: Icons.auto_awesome,
                  color: ColorsManager.white,
                  backgroundColor: ColorsManager.primaryColor,
                  onTap: () {
                    ScheduleCubit.get(context).prepareLesson(
                      classModel: classModel,
                      selectedModules: ['assignment', 'enrichment', 'homework', 'exam'],
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          verticalSpace24,
        ],
      ),
    );
  }
}

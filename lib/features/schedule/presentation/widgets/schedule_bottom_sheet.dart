import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/widgets/status_strip.dart';
import 'package:moean/features/schedule/presentation/widgets/action_button_widget.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_cubit.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final ClassModel classModel;

  const ScheduleBottomSheet({super.key, required this.classModel});

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final List<String> _selectedModules = [];

  void _toggleModule(String module) {
    setState(() {
      if (_selectedModules.contains(module)) {
        _selectedModules.remove(module);
      } else {
        _selectedModules.add(module);
      }
    });
  }

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
                    if (widget.classModel.lessonTitle != null)
                      Text(
                        widget.classModel.lessonTitle!,
                        style: TextStylesManager.bold14
                            .copyWith(color: ColorsManager.mainText),
                      ),
                    verticalSpace8,
                    Row(
                      children: [
                        Text(
                          widget.classModel.classroomId,
                          style: TextStylesManager.regular12
                              .copyWith(color: ColorsManager.secondaryText),
                        ),
                        const Spacer(),
                        StatusIcon(status: widget.classModel.status, size: 24),
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
                    appTranslation().get(widget.classModel.periodKey),
                    style: TextStylesManager.regular12
                        .copyWith(color: ColorsManager.primaryColor),
                  ),
                  Text(
                    '${appTranslation().get('period_label')} ${widget.classModel.periodNumber}',
                    style: TextStylesManager.bold16
                        .copyWith(color: ColorsManager.mainText),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.classModel.classroomId,
                        style: TextStylesManager.regular12
                            .copyWith(color: ColorsManager.secondaryText),
                      ),
                      horizontalSpace4,
                      Icon(
                        Icons.school,
                        size: 14,
                        color: ColorsManager.primaryColor,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButtonWidget(
                titleKey: 'action_enrichment',
                icon: Icons.star_border,
                color: _selectedModules.contains('enrichment') ? ColorsManager.white : ColorsManager.brandGold,
                backgroundColor: _selectedModules.contains('enrichment') ? ColorsManager.brandGold : null,
                onTap: () => _toggleModule('enrichment'),
              ),
              ActionButtonWidget(
                titleKey: 'action_exam',
                icon: Icons.assignment_outlined,
                color: _selectedModules.contains('exam') ? ColorsManager.white : ColorsManager.statusSuccess,
                backgroundColor: _selectedModules.contains('exam') ? ColorsManager.statusSuccess : null,
                onTap: () => _toggleModule('exam'),
              ),
              ActionButtonWidget(
                titleKey: 'action_activity',
                icon: Icons.directions_walk_outlined,
                color: _selectedModules.contains('activity') ? ColorsManager.white : ColorsManager.statusActivity,
                backgroundColor: _selectedModules.contains('activity') ? ColorsManager.statusActivity : null,
                onTap: () => _toggleModule('activity'),
              ),
              ActionButtonWidget(
                titleKey: 'action_homework',
                icon: Icons.home_work_outlined,
                color: _selectedModules.contains('homework') ? ColorsManager.white : ColorsManager.statusWaiting,
                backgroundColor: _selectedModules.contains('homework') ? ColorsManager.statusWaiting : null,
                onTap: () => _toggleModule('homework'),
              ),
            ],
          ),
          verticalSpace24,
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                ScheduleCubit.get(context).prepareLesson(
                  classModel: widget.classModel,
                  selectedModules: _selectedModules,
                );
                Navigator.pop(context);
              },
              child: Text(
                appTranslation().get('action_prepare_moean'),
                style: TextStylesManager.bold16.copyWith(color: ColorsManager.white),
              ),
            ),
          ),
          verticalSpace24,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/widgets/status_strip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:moean/features/schedule/presentation/widgets/schedule_bottom_sheet.dart';

class ClassCard extends StatefulWidget {
  final ClassModel classModel;

  const ClassCard({super.key, required this.classModel});

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showActions(BuildContext context) {
    final cubit = ScheduleCubit.get(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: ScheduleBottomSheet(classModel: widget.classModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLesson = widget.classModel.lessonTitle != null;
    final bool isActivity =
        widget.classModel.status == ClassStatus.activity;

    return GestureDetector(
      onTap: isActivity ? null : () => _showActions(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isExpanded
              ? ColorsManager.brandMint.withValues(alpha: 0.2)
              : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isExpanded
                ? ColorsManager.primaryColor
                : ColorsManager.borderLightGray,
            width: _isExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isActivity) ...[
                  GestureDetector(
                    onTap: hasLesson ? _toggleExpand : null,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _isExpanded
                            ? ColorsManager.brandMint
                            : ColorsManager.scheduleBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: _isExpanded
                            ? ColorsManager.primaryColor
                            : ColorsManager.secondaryText,
                        size: 20,
                      ),
                    ),
                  ),
                  horizontalSpace12,
                ],
                StatusIcon(status: widget.classModel.status, size: 28),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      appTranslation().get(widget.classModel.periodKey),
                      style: TextStylesManager.regular12
                          .copyWith(color: ColorsManager.primaryColor),
                    ),
                    Text(
                      widget.classModel.lessonTitle ??
                          appTranslation().get('no_lesson_title'),
                      style: TextStylesManager.bold18
                          .copyWith(color: ColorsManager.mainText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                          color: ColorsManager.secondaryText,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (!isActivity) ...[
              verticalSpace16,
              Row(
                children: [
                  Icon(
                    Icons.format_list_numbered,
                    size: 16,
                    color: ColorsManager.secondaryText,
                  ),
                  horizontalSpace4,
                  Text(
                    '${appTranslation().get('period_label')} ${widget.classModel.periodNumber}',
                    style: TextStylesManager.regular12
                        .copyWith(color: ColorsManager.secondaryText),
                  ),
                ],
              ),
            ],
            if (_isExpanded && hasLesson) ...[
              verticalSpace16,
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorsManager.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorsManager.borderLightGray),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      color: ColorsManager.primaryColor,
                      size: 20,
                    ),
                    horizontalSpace8,
                    Expanded(
                      child: Text(
                        widget.classModel.lessonTitle!,
                        style: TextStylesManager.regular12
                            .copyWith(color: ColorsManager.mainText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

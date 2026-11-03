import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/lab/data/models/admin_lab_models.dart';
import 'package:moean/features/admin/lab/presentation/cubit/admin_lab_cubit.dart';
import 'package:moean/features/admin/lab/presentation/widgets/admin_lab_status_badge.dart';

class AdminRequestCard extends StatelessWidget {
  final AdminLabRequestModel request;

  const AdminRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminLabCubit.get(context);

    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: request.isOpen
              ? ColorsManager.primaryColor.withValues(alpha: 0.4)
              : ColorsManager.borderLightGray,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.lessonTitle != null
                      ? appTranslation().get('admin_lab_lesson').replaceAll('{title}', request.lessonTitle!)
                      : request.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                ),
              ),
              horizontalSpace8,
              AdminLabStatusBadge(
                label: request.isOpen
                    ? appTranslation().get('admin_lab_status_open')
                    : appTranslation().get('admin_lab_status_done'),
                isGreen: !request.isOpen,
                isAlert: false,
              ),
            ],
          ),
          verticalSpace8,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsManager.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              request.message,
              style: TextStylesManager.regular13.copyWith(color: ColorsManager.mainText),
            ),
          ),
          if (request.teacherName != null && request.teacherName!.isNotEmpty) ...[
            verticalSpace8,
            Text(
              appTranslation().get('admin_lab_teacher').replaceAll('{name}', request.teacherName!),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
          ],
          verticalSpace12,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => cubit.toggleRequestStatus(request),
                style: OutlinedButton.styleFrom(
                  foregroundColor: request.isOpen ? ColorsManager.successColor : ColorsManager.placeholder,
                  side: BorderSide(
                    color: request.isOpen ? ColorsManager.successColor : ColorsManager.placeholder,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  request.isOpen
                      ? appTranslation().get('admin_lab_mark_done')
                      : appTranslation().get('admin_lab_mark_open'),
                  style: TextStylesManager.bold12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';

enum ClassCardAction { edit, delete }

/// A row in «فصولي»: name, grade and subject, and the number of students.
class ClassCardWidget extends StatelessWidget {
  final SchoolClassModel schoolClass;
  final bool isBusy;
  final VoidCallback onTap;
  final ValueChanged<ClassCardAction> onAction;

  const ClassCardWidget({
    super.key,
    required this.schoolClass,
    required this.isBusy,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final details = [schoolClass.grade, schoolClass.subject].where((text) => text.isNotEmpty).join(' · ');
    return Material(
      color: ColorsManager.surfacePrimary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 4, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorsManager.borderLightGray),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.groups_2_outlined, color: ColorsManager.primaryColor),
              ),
              horizontalSpace12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schoolClass.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                    ),
                    verticalSpace6,
                    Text(
                      [
                        if (details.isNotEmpty) details,
                        appTranslation().get('class_students_count').replaceAll('{count}', '${schoolClass.studentsCount}'),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                    ),
                  ],
                ),
              ),
              if (isBusy)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                PopupMenuButton<ClassCardAction>(
                  onSelected: onAction,
                  icon: Icon(Icons.more_vert_rounded, color: ColorsManager.secondaryText),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: ClassCardAction.edit, child: Text(appTranslation().get('edit'))),
                    PopupMenuItem(
                      value: ClassCardAction.delete,
                      child: Text(
                        appTranslation().get('delete'),
                        style: const TextStyle(color: ColorsManager.errorColor),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

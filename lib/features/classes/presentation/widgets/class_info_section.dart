import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/presentation/cubit/class_editor_cubit.dart';

/// «بيانات الفصل»: name, grade and subject.
class ClassInfoSection extends StatelessWidget {
  const ClassInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ClassEditorCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.class_outlined,
      title: appTranslation().get('class_section_info'),
      child: Column(
        children: [
          PrimaryTextField(
            controller: cubit.nameController,
            label: appTranslation().get('class_field_name'),
            hint: appTranslation().get('class_field_name_hint'),
            maxLength: ClassLimits.maxClassNameLength,
          ),
          verticalSpace12,
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.gradeController,
                  label: appTranslation().get('strategy_field_grade'),
                  hint: appTranslation().get('strategy_field_grade_hint'),
                  maxLength: ClassLimits.maxFieldLength,
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.subjectController,
                  label: appTranslation().get('strategy_field_subject'),
                  hint: appTranslation().get('strategy_field_subject_hint'),
                  maxLength: ClassLimits.maxFieldLength,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

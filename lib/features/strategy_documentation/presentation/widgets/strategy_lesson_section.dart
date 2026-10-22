import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/presentation/widgets/document_picker_tile.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_sheet.dart';
import 'package:moean/features/strategy_documentation/presentation/cubit/strategy_documentation_cubit.dart';

/// «بيانات الحصة».
class StrategyLessonSection extends StatelessWidget {
  const StrategyLessonSection({super.key});

  Future<void> _pickLesson(BuildContext context) async {
    final cubit = StrategyDocumentationCubit.get(context);
    final lesson = await LessonPickerSheet.show(context);
    if (lesson != null) cubit.pickLesson(lesson);
  }

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final cubit = StrategyDocumentationCubit.get(context);
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (date != null) cubit.setExecutionDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = StrategyDocumentationCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.class_outlined,
      title: appTranslation().get('strategy_section_lesson'),
      child: Column(
        children: [
          PrimaryTextField(
            controller: cubit.lessonController,
            label: appTranslation().get('strategy_field_lesson'),
            hint: appTranslation().get('strategy_field_lesson_hint'),
            maxLength: 255,
            suffixIcon: IconButton(
              tooltip: appTranslation().get('document_pick_lesson'),
              onPressed: () => _pickLesson(context),
              icon: Icon(Icons.menu_book_rounded, color: ColorsManager.primaryColor),
            ),
          ),
          verticalSpace12,
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.subjectController,
                  label: appTranslation().get('strategy_field_subject'),
                  hint: appTranslation().get('strategy_field_subject_hint'),
                  maxLength: 120,
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.gradeController,
                  label: appTranslation().get('strategy_field_grade'),
                  hint: appTranslation().get('strategy_field_grade_hint'),
                  maxLength: 120,
                ),
              ),
            ],
          ),
          verticalSpace12,
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.classController,
                  label: appTranslation().get('strategy_field_class'),
                  hint: appTranslation().get('strategy_field_class_hint'),
                  maxLength: 60,
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.studentsController,
                  label: appTranslation().get('strategy_field_students'),
                  hint: appTranslation().get('strategy_field_students_hint'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩]'))],
                  maxLength: 3,
                ),
              ),
            ],
          ),
          verticalSpace12,
          BlocSelector<StrategyDocumentationCubit, StrategyDocumentationState, DateTime?>(
            selector: (state) => state.executionDate,
            builder: (context, date) => DocumentPickerTile(
              icon: Icons.event_outlined,
              hint: appTranslation().get('strategy_field_date'),
              value: date == null ? null : isoDate(date),
              onTap: () => _pickDate(context, date),
            ),
          ),
        ],
      ),
    );
  }
}
